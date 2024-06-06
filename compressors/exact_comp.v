`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2021 14:38:57
// Design Name: 
// Module Name: exact_comp
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


module exact_comp(x1,x2,x3,x4,cin,cout,sum,carry);
input x1,x2,x3,x4,cin;
output cout,sum,carry;

assign sum= x1^x2^x3^ x4^cin;
assign cout= (x1&x2)|(x3&x2)|(x1&x3);
assign carry= ((x1^x2^x3)&x4)|((x1^x2^x3)&cin)|(cin&x4);  


endmodule

