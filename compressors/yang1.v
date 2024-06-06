`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2021 16:51:25
// Design Name: 
// Module Name: yang1
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


module yang1 (x1,x2,x3,x4, sum, carry);
input x1,x2,x3,x4;
output  sum, carry;

assign sum = ~((~x3|~(x1&x2))&~(~((x1|x2)&~(x1&x2))^(~(x3^x4))));
assign carry = ~((~(x3^x4 )|~((x1 |x2 )&~(x1 &x2 )))&(~(x1 &x2 ))&(~x3 |~x4 ));
endmodule

