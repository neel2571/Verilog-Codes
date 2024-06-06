module akbar1(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
 assign carry=x4;
 assign sum=~((~(x1^x2))&(~(x3^x4)));

endmodule