module strollo2(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
 wire t1,t2,t3,t4,t5,t6;

 assign t1 = x3&x4;
 assign t2 = x3 | x4;
 assign t3 = t1|x2;
 assign t4 = x1^t3;
 assign t5 = t4 & t2;
 assign t6 = x1 & t3;
 assign sum = t4 ^ t2;
 assign carry = t5|t6;
  

endmodule