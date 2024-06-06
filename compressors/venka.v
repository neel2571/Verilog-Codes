module venka(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
  wire t1,t2,t3,t4,t5;
  
 assign t1 = x1^x2;
 assign t2 = x3^x4;
 assign t3 = x1&x2;
 assign t4 = x3&x4;
 assign t5 = t3&t4;
 
 or(sum,t1,t2,t5);// Sum
 assign carry = t3|t4; // Carry Out

endmodule