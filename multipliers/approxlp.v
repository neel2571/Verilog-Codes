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

module approxlp(input  wire clk,
			  input  wire[`N-1:0] a1,
              input  wire[`N-1:0] b1,
              input  wire[1:0] t1,
              output reg[`N-1:0] y);

reg [`N-1:0] a,b;
wire [`N-1:0]y1;
reg normalized;
reg [`P:0] product;
reg s;
reg G;
reg R;
reg S;
reg [1:0]t;
reg [`P-2:0] m;
reg [`E-1:0] e;
reg [`P-2+1:0] sum;
reg [`P-2:0]diff1,diff2;

always @(posedge clk) 

    begin
        a = {a1};
        b = {b1};
        y = y1; 
        t=t1;
    end
always @(*) 

    begin
    
    sum = a[`M]+b[`M];
    diff1 = a[`M]-b[`M];
    diff2 = b[`M]-a[`M];
    if (a[`M]>=b[`M])
    begin
    product={1'b0,a[`M]}+{b[`M],1'b0}+{1'b1,23'b0};
        if(t==2'b10||t==2'b11)
        begin
          if (sum[23]==1) begin
          product=product+a[22:1]-{1'b1,22'b0};
          if(t==2'b11)
            begin
            if (sum[23:22]==2'b11) begin
               product=product+a[22:2]-{1'b1,21'b0}; 
            end 
            else if(diff1[22]==1'b1)begin
               product=product-a[22:2]+{1'b1,21'b0};  
            end
            else begin
               product=product-b[22:2]+{1'b1,20'b0}; 
            end   
            end
          
          end else begin
          product=product-b[21:0];
          if(t==2'b11)
            begin
            if (diff1[22]==1'b1) begin
               product=product+b[22:2]; 
            end 
            else if(sum[23:22]==2'b00)begin
               product=product-b[22:2];  
            end
            else begin
               product=product+a[22:2]-{1'b1,20'b0}; 
            end   
            end  
          end
        end
    end 
    else begin
    product={1'b0,b[`M]}+{a[`M],1'b0}+{1'b1,23'b0};
        if(t==2'b10||t==2'b11)
        begin
          if (sum[23]==1) begin
          product=product+b[22:1]-{1'b1,22'b0};
          if(t==2'b11)
            begin
            if (diff2[22]==1'b1) begin
               product=product-b[22:2]+{1'b1,21'b0}; 
            end 
            else if(diff1[22]==1'b1)begin
               product=product+b[22:2]-{1'b1,21'b0};  
            end
            else begin
               product=product-a[22:2]+{1'b1,20'b0}; 
            end   
            end
          
          end else begin
          product=product-a[21:0];
          if(t==2'b11)
            begin
            if (diff2[22]==1'b1) begin
               product=product+a[22:2]; 
            end 
            else if(sum[23:22]==2'b00)begin
               product=product-a[22:2];  
            end
            else begin
               product=product+b[22:2]-{1'b1,20'b0}; 
            end   
            end  
          end
        end   
    end
    
    // get sticky bits by ORing together all bits right of R
    S = |product[`S]; 

    // if the MSB of the resulting product is 0
    // normalize by shifting right    
    normalized = product[24:23];
        
    if(normalized==2'b01) product = product << 1;
    else if(normalized==2'b10||normalized==2'b11) product=product<<2; 
    else product = product;

    // mantissa is upper 22-bits of product w/ nearest-even rounding
    m = product[22:0];
    s = a[`SIGN] ^ b[`SIGN];
    e = a[`EXP] + b[`EXP] - `BIAS + normalized;


    end

assign y1 = {s, e, m};

endmodule