module sabetz(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
 assign sum = 1;
 assign carry = ((x1 & x3) | ( x3&x4 ) | (x4 & x1));
  
endmodule