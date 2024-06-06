module akbar2(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
  wire t1,t2;
 nand(t1,x1,x2);
 nand(t2,x3,x4);
 nand(carry,t2,t1);
 assign sum=~((~(x1^x2))&(~(x3^x4)));

endmodule