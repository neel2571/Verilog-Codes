`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2019 14:07:39
// Design Name: 
// Module Name: top_fp_mul_N32_M23_E8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define N       32
`define E       8
`define MA      23

// indices of components of IEEE 754 FP
`define SIGN   	31
`define EXP    	30:23
`define M    	22:0

`define P    	24    // number of bits for mantissa (including 
`define G    	23    // guard bit index
`define R    	22    // round bit index
`define S    	21:0  // sticky bits range

`define BIAS   	127


module yang1_fp_32_mul(input  wire clk,
			  input  wire[`N-1:0] a1,
              input  wire[`N-1:0] b1,
              output reg[`N-1:0] y);

      reg [`P-2:0] m;
      reg [`E-1:0] e;
      reg s;
      
      wire [`P*2-1:0] product;
  	  reg [`P*2-1:0] product1;
      reg G;
      reg R;
      reg S;
      reg normalized;
    
    
      reg [`N-1:0] a,b;
      wire [`N-1:0] y1;
  yang1_multiplier_8bit M1(.clk(clk),.A({1'b1, a[`R:`R-6]}),.B({1'b1, b[`R:`R-6]}),.out(product));
  
    
      always @(posedge clk) begin
          a = {a1};
          b = {b1};
          y = y1; 
      end
    
    
      always @(*) begin
          // $monitor("product = %b, S = %b, s = %b, m = %b, e = %b", product, S,s,m,e);
          // mantissa is product of a and b's mantissas, 
          // with a 1 added as the MSB to each
		 product1=product;
    
          // get sticky bits by ORing together all bits right of R
          S = |product1[`S]; 
    
          // if the MSB of the resulting product is 0
          // normalize by shifting right    
          normalized = product1[2*`MA+1];
          
        if(!normalized) product1 = product1 << 1; 
          else product1 = product1;
          
    
          // sign is xor of signs
          s = a[`SIGN] ^ b[`SIGN];

          // mantissa is upper 22-bits of product w/ nearest-even rounding
        m = product1[2*`MA:`MA+1] + (product1[`G] & (product1[`R] | S));

          // exponent is sum of a and b's exponents, minus the bias 
          // if the mantissa was shifted, increment the exponent to balance it
          e = a[`EXP] + b[`EXP] - `BIAS + normalized;
    
      end
    
      // output is concatenation of sign, exponent, and mantissa    
      assign y1 = {s, e, m};
    
    endmodule 


module half_adder(a,b,sum,carry);
input a,b;
output sum,carry;

assign sum = a^b;
assign carry = a&b;

endmodule

module full_adder(a, b, c, sum, carry);
	input a, b, c;
	output sum, carry;

	assign sum = a^b^c;
	assign carry = (a&b)|(b&c)|(c&a);
endmodule

// Full Adder


// Exact 4-2 compressor

module exact_comp(x1,x2,x3,x4,cin,cout,sum,carry);
input x1,x2,x3,x4,cin;
output cout,sum,carry;

assign sum= x1^x2^x3^ x4^cin;
assign cout= (x1&x2)|(x3&x2)|(x1&x3);
assign carry= ((x1^x2^x3)&x4)|((x1^x2^x3)&cin)|(cin&x4);  


endmodule


// Pro 1 approximate compressor

module yang1 (x1,x2,x3,x4, sum, carry);
input x1,x2,x3,x4;
output  sum, carry;

assign sum = 1;
assign carry = ((x1 & x3) | (x3 & x4) | (x4 & x1));
endmodule

// Now we are starting the top level module

module yang1_multiplier_8bit(A,B,clk,out);
input [7:0] A,B;
reg [7:0] A_temp,B_temp;
wire [`P*2-1:0] out_temp;
	input clk;
	wire s1,c1,s2,c2,s3,c3,s4,c4,s5,c5,co1,co2,co3,co4,co5,co6,co7,co8,s11,c11,s12,c12,s13,c13,s21,c21;
	wire s22,c22,s23,c23,s24,c24,s25,c25,ls11,lc11,ls12,lc12,ls13,lc13,ls14,lc14,ls21,lc21,ls22,lc22,ls23,lc23,ls24,lc24,ls25,lc25;
	wire fs1,fc1,fs2,fc2,fs3,fc3,fs4,fc4,fs5,fc5,fs6,fc6,fs7,fc7,fs8,fc8,fs9,fc9,fs10,fc10,fs11,fc11,fs12,fc12,fs13,fc13,fs14,fc14,fs15,fc15,fs16,fc16;
	
	
	output reg [`P*2-1:0] out;
	wire [7:0] P[7:0]; 	
	always @(posedge clk)
begin
A_temp<=A;
B_temp<=B;
out<=out_temp;
end	

//-------------------------- 8 bit approximate multiplier in CN configuration ----------------------------------------------
//--------------------------  Partial product generation ------------------------------------------------------------------- 

	genvar i;
	generate
		for(i = 0; i < 8; i = i +1) 
         begin:part_product
			assign P[i][0] = A_temp[0] & B_temp[i] ;
			assign P[i][1] = A_temp[1] & B_temp[i] ;
			assign P[i][2] = A_temp[2] & B_temp[i] ;
			assign P[i][3] = A_temp[3] & B_temp[i] ;
			assign P[i][4] = A_temp[4] & B_temp[i] ;
			assign P[i][5] = A_temp[5] & B_temp[i] ;
			assign P[i][6] = A_temp[6] & B_temp[i] ;
			assign P[i][7] = A_temp[7] & B_temp[i] ;
		end
	endgenerate

//-------------------- First stage of PP reduction from 8 to 4 in C-N configuration -----------------------------------------

half_adder h1(.a(P[0][4]),.b(P[1][3]),.sum(s1),.carry(c1));
half_adder h2(.a(P[4][2]),.b(P[5][1]),.sum(s2),.carry(c2));
half_adder h3(.a(P[6][3]),.b(P[7][2]),.sum(s3),.carry(c3));

full_adder f1(.a(P[5][3]), .b(P[6][2]), .c(P[7][1]), .sum(fs1), .carry(fc1));


yang1 l11(.x1(P[0][5]), .x2(P[1][4]), .x3(P[2][3]), .x4(P[3][2]), .sum(ls11), .carry(lc11));
yang1 l12(.x1(P[0][6]), .x2(P[1][5]), .x3(P[2][4]), .x4(P[3][3]), .sum(ls12), .carry(lc12));
yang1 l13(.x1(P[0][7]), .x2(P[1][6]), .x3(P[2][5]), .x4(P[3][4]), .sum(ls13), .carry(lc13));
yang1 l14(.x1(P[4][3]), .x2(P[5][2]), .x3(P[6][1]), .x4(P[7][0]), .sum(ls14), .carry(lc14));


exact_comp e11(.x1(P[1][7]),.x2(P[2][6]),.x3(P[3][5]),.x4(P[4][4]),.cin(1'b0),.cout(co1),.sum(s11),.carry(c11));
exact_comp e12(.x1(P[2][7]),.x2(P[3][6]),.x3(P[4][5]),.x4(P[5][4]),.cin(co1),.cout(co2),.sum(s12),.carry(c12));
exact_comp e13(.x1(P[3][7]),.x2(P[4][6]),.x3(P[5][5]),.x4(P[6][4]),.cin(co2),.cout(co3),.sum(s13),.carry(c13));

full_adder f2(.a(P[4][7]), .b(P[5][6]), .c(co3),  .sum(fs2), .carry(fc2));

//------------------- Second stage of PP reduction from 4 to 2 in C-N configuration ------------------------------------------
half_adder h4(.a(P[0][2]),.b(P[1][1]),.sum(s4),.carry(c4));
yang1 l21(.x1(P[0][3]), .x2(P[1][2]), .x3(P[2][1]), .x4(P[3][0]), .sum(ls21), .carry(lc21));
yang1 l22(.x1(s1), .x2(P[2][2]), .x3(P[3][1]), .x4(P[4][0]), .sum(ls22), .carry(lc22));
yang1 l23(.x1(ls11), .x2(c1), .x3(P[4][1]), .x4(P[5][0]), .sum(ls23), .carry(lc23));
yang1 l24(.x1(ls12), .x2(lc11), .x3(s2), .x4(P[6][0]), .sum(ls24), .carry(lc24));
yang1 l25(.x1(ls13), .x2(lc12), .x3(ls14), .x4(c2), .sum(ls25), .carry(lc25));


exact_comp e21(.x1(s11),.x2(lc13),.x3(fs1),.x4(lc14),.cin(1'b0),.cout(co4),.sum(s21),.carry(c21));
exact_comp e22(.x1(s12),.x2(c11),.x3(s3),.x4(fc1),.cin(co4),.cout(co5),.sum(s22),.carry(c22));
exact_comp e23(.x1(s13),.x2(c12),.x3(P[7][3]),.x4(c3),.cin(co5),.cout(co6),.sum(s23),.carry(c23));
exact_comp e24(.x1(fs2),.x2(c13),.x3(P[6][5]),.x4(P[7][4]),.cin(co6),.cout(co7),.sum(s24),.carry(c24));
exact_comp e25(.x1(P[5][7]),.x2(fc2),.x3(P[6][6]),.x4(P[7][5]),.cin(co7),.cout(co8),.sum(s25),.carry(c25));

full_adder f3(.a(P[6][7]), .b(P[7][6]), .c(co8), .sum(fs3), .carry(fc3));


//----------------- Third stage of carry propagation addition of two final rows in C-N configuration --------------------------
half_adder h5(.a(P[0][1]),.b(P[1][0]),.sum(s5),.carry(c5));
full_adder f4(.a(s4),.b(P[2][0]),.c(c5),.sum(fs4),.carry(fc4));
full_adder f5(.a(ls21),.b(c4),.c(fc4),.sum(fs5),.carry(fc5));
full_adder f6(.a(ls22),.b(lc21),.c(fc5),.sum(fs6),.carry(fc6));
full_adder f7(.a(ls23),.b(lc22),.c(fc6),.sum(fs7),.carry(fc7));
full_adder f8(.a(ls24),.b(lc23),.c(fc7),.sum(fs8),.carry(fc8));
full_adder f9(.a(ls25),.b(lc24),.c(fc8),.sum(fs9),.carry(fc9));
full_adder f10(.a(s21),.b(lc25),.c(fc9),.sum(fs10),.carry(fc10));
full_adder f11(.a(s22),.b(c21),.c(fc10),.sum(fs11),.carry(fc11));
full_adder f12(.a(s23),.b(c22),.c(fc11),.sum(fs12),.carry(fc12));
full_adder f13(.a(s24),.b(c23),.c(fc12),.sum(fs13),.carry(fc13));
full_adder f14(.a(s25),.b(c24),.c(fc13),.sum(fs14),.carry(fc14));
full_adder f15(.a(fs3),.b(c25),.c(fc14),.sum(fs15),.carry(fc15));
full_adder f16(.a(P[7][7]),.b(fc3),.c(fc15),.sum(fs16),.carry(fc16));


//----------------------- Concatenation of sum and carry bits ------------------------------------------------------------------

assign out_temp = {fc16,fs16,fs15,fs14,fs13,fs12,fs11,fs10,fs9,fs8,fs7,fs6,fs5,fs4,s5,P[0][0],32'b0}; 



endmodule