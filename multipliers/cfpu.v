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

module cfpu (input  wire clk,
			  input  wire[`N-1:0] a1,
              input  wire[`N-1:0] b1,
              output reg[`N-1:0] y);
    
    reg [`N-1:0] a,b,in1,in2;
    wire [`N-1:0] result;
    reg [`N-1:0] y1;
    reg [`P-2:0] m;
    reg [`E-1:0] e;
    reg s;


    always @(posedge clk) begin
        a = {a1};
        b = {b1};
        y = y1; 
    //if the mantissa of b is 0, then we take that mantissa for the output value otherwise we take the mantissa of a 
    case(a[`M])       
        `R'b0:begin
           in1=a;
           in2=b; 
        end
        default:begin
           in1=b;
           in2=a;
        end
    endcase

    end
    // here we take the exact multiplication of the 2 numbers
top_fp_mul_N32_M23_E8 m1(.clk(clk),.a1(a),.b1(b),.y(result)); 
always @(*)begin
    case (in1[22:0])
        //In this if all the bits in the mantissa of in1 is 1, then it is approximately equal to 2 so we increase the exponent by 1 and keep the value 
        //of final mantissa as that of in2. 
       23'b11111111111111111111111 : begin
       s = in1[`SIGN] ^ in2[`SIGN];  // sign bit we xor the sign bits of the operands
       e = in1[`EXP] + in2[`EXP] - `BIAS + 1'b1; //In the exponent bits, we add the exponent bits of the opperand 
       m= in2[`M];
       y1 = {s, e, m};
       end
       //In this if all the bits in the mantissa of in1 is 0, then it is equal to 1 so keep the value of final mantissa as that of in2
       23'b00000000000000000000000 : begin
       s = in1[`SIGN] ^ in2[`SIGN];// // sign bit we xor the sign bits of the operands
       e = in1[`EXP] + in2[`EXP] - `BIAS;//In the exponent bits, we add the exponent bits of the opperand 
       m= in2[`M];
       y1 = {s, e, m};
       end
       // Else we keep the exact result of the multiplier.
        default: begin
       y1=result;
        end
    endcase
end

endmodule


module top_fp_mul_N32_M23_E8(input  wire clk,
			  input  wire[`N-1:0] a1,
              input  wire[`N-1:0] b1,
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