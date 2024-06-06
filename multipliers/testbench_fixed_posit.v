`include "base_fixed_posit.v"
`timescale 1ps / 1fs
`define N 10
`define es 4
`define regime 2

module tb_;
reg clk,reset;
reg [`N-1:0]a,b;
reg [`N-1:0]A[0:9999];
reg [`N-1:0]B[0:9999];
wire [`N-1:0]out;
wire pinf,pzero;
integer i;
//integer fa;
 
pmult m1(
    .reset (reset),  
    .a(a),.b(b),.out(out),.pinf(pinf),.pzero(pzero),
    .clk (clk)
);


always  #367.5 clk=~clk;

initial begin
    $readmemb("10_4_2_inputA.txt", A);
    $readmemb("10_4_2_inputB.txt", B);
    //f = $fopen("output.txt","w");
    //fa = $fopen("10_4_2_inputA.txt","r");
    //fb = $fopen("10_4_2_inputB.txt","r");
    $dumpfile("tb_posit.vcd");
    $dumpvars(0, tb_.m1);
end

initial begin
    clk=1'b0;
    #1;
    reset=1'b0;
    #20;
    for (i=0; i<10000; i=i+1)
	begin 
		a = A[i];
		b = B[i];
		#735;
	end

   #50;$finish;
end
endmodule
