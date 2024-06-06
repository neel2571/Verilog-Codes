`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2019 12:43:09
// Design Name: 
// Module Name: top_fp_mul_N6_M1_E4
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

`define N       6
`define E       4
`define MA      1

// indices of components of IEEE 754 FP
`define SIGN   	5
`define EXP    	4:1
`define M    	0

`define P    	2    // number of bits for mantissa (including 
`define G    	1    // guard bit index
`define R    	0    // round bit index
`define S    	0:0  // sticky bits range

`define BIAS   	7


module top_fp_mul_N6_M1_E4(input  wire clk,
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