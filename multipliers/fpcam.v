module approx_mult(a,b,c,t1,t2,t3);
  input [15:0]a;
  input [15:0]b;
  input t1,t2,t3;
  output[15:0]c;
  assign c[15]=a[15]^b[15];
  assign c[14:10]=a[14:10]+b[14:10];
  assign c[9:0]=a[9:0]&t1+b[9]&(a[9:0]>>1)&t2+b[8]&(a[9:0]>>2)&t3;
endmodule