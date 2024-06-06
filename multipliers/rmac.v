`define N       32
`define E       8
`define MA      23
`define n       1
// indices of components of IEEE 754 FP
`define SIGN   	31
`define EXP    	30:23
`define M    	22:0

`define P    	24    // number of bits for mantissa (including 
`define G    	23    // guard bit index
`define R    	22    // round bit index
`define S    	21:0  // sticky bits range

`define BIAS   	127

module rmac (input  wire clk,
			  input  wire[`N-1:0] a1,
              input  wire[`N-1:0] b1,
              output reg[`N-1:0] y);

    reg [`N-1:0] a,b;
    wire [`N-1:0] result;
    reg [`N-1:0] y1,y2;
    reg [`P-2:0] m;
    reg [`E-1:0] e;
    reg s,c;


    always @(posedge clk) begin
        a = {a1};
        b = {b1};
        y = y1; 

    end
    // here we take the exact multiplication of the 2 numbers
top_fp_mul_N32_M23_E8 m1(.clk(clk),.a1(a),.b1(b),.y(result));
always @(*)begin
    //adding the mantissa of 2 operands as approximation
    {c,m}= a[`M]+b[`M];
    //depening upon value of carry, exponent is normalized
    e = c? a[`EXP] + b[`EXP] - `BIAS + 1'b1: a[`EXP] + b[`EXP] - `BIAS;
    //we check the MSB of the mantissa of both operands
    case (a[22]+b[22])
    // if both are 1, then it check whether there is 1 in the next bit through the value of m
       2'b10 : begin
       s = a[`SIGN] ^ b[`SIGN];
       y2 = {s, e, m};
       y1=m[22]?y2:result; //if msb of m is 0, then there is the max error so exact result is used, else approx result is used
       end
       // if both are 0, then it check whether there is 1 in the next bit through the value of m
       2'b00 : begin
       s = a[`SIGN] ^ b[`SIGN];
       y2 = {s, e, m};
       y1=m[22]?result:y2; //if msb of m is 1, then there is the max error so exact result is used, else approx result is used
       end
       // in all other case, exact result is used
        default: begin
       y1=result;
        end
    endcase
end

endmodule


module top_fp_mul_N32_M23_E8(input  wire clk,
			  input  wire[`N-1:0] a1,
              input  wire[`N-1:0] b1,Des
              output reg[`N-1:0] y);

    reg [`P-2:0] m;
    reg [`E-1:0] e;
    reg s;
    
    reg [`P*2-1:0] product;
    reg G;
    reg R;
    reg S;
    reg normalized;


    reg [`N-1:0] a,b;
    wire [`N-1:0] y1;
  

	always @(posedge clk) begin
        a = {a1};
        b = {b1};
        y = y1; 
	end


	always @(*) begin
        //$monitor("product = %b, S = %b, s = %b, m = %b, e = %b", product, S,s,m,e);
        // mantissa is product of a and b's mantissas, 
        // with a 1 added as the MSB to each
        product = {1'b1, a[`M]} * {1'b1, b[`M]};

        // get sticky bits by ORing together all bits right of R
        S = |product[`S]; 

        // if the MSB of the resulting product is 0
        // normalize by shifting right    
        normalized = product[2*`MA+1];
        
        if(!normalized) product = product << 1; 
        else product = product;
		

        // sign is xor of signs
        s = a[`SIGN] ^ b[`SIGN];

        // mantissa is upper 22-bits of product w/ nearest-even rounding
        m = product[2*`MA:`MA+1] + (product[`G] & (product[`R] | S));

        // exponent is sum of a and b's exponents, minus the bias 
        // if the mantissa was shifted, increment the exponent to balance it
        e = a[`EXP] + b[`EXP] - `BIAS + normalized;

	end

	// output is concatenation of sign, exponent, and mantissa	
	assign y1 = {s, e, m};

endmodule 