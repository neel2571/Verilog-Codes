module strollo1(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
 wire t1,t2,t3,t4,t5,t6;
  
 assign t1 = x1^x2;
 assign t2 = x3|x4;
 assign t3 = t1^t2;
 assign t4 = t1&t2;
 assign t5 = x1&x2;
 
 assign sum =t3;// Sum
 assign carry = t4|t5; // Carry Out

endmodule