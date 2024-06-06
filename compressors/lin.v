module lin(x1,x2,x3,x4,sum,carry);
 output sum,carry;
 input x1,x2,x3,x4;
  
 wire i1,i2,s;
  
 assign i1=x1^x2;//input1 of mux
 assign i2=~i1;//input 2 of mux
 assign s=x3^x4; // select line of mux
 assign sum=(i1&(~s))|(i2&s);//Sum or output of mux
 assign carry = (~(~(~(x1&x2))&(~(x3&x4)))&(~(i1&i2))); // Carry Out

endmodule