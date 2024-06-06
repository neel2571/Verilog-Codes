module yang2(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
 wire t1,t2,t3,t4,t5,t6,t8;

 assign t1 = x1^x2;
 assign t2 = x3 | x4;
 assign t3 = t1^t2;
 assign t4 = x3&x4;
 assign t5 = x1&x2;
 assign t6 = t1&t2;
 nor(t8,t4,t5,t6);
 assign sum = t3 | t4;
 assign carry = ~t8;
endmodule