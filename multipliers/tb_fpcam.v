`include "fpcam.v"


module tb_;
reg [15:0]a,b;
reg t1,t2,t3;
wire [15:0]c ;

 
approx_mult m1 (.a(a),.b(b),.c(c),.t1(t1),.t2(t2),.t3(t3)

);

initial begin
    $dumpfile("tb2_.vcd");
    $dumpvars(0, tb_);
end

initial begin
    t1=1'b1;
    t2=1'b1;
    t3=1'b1;
    a=16'b0100000000000000;//2
    b=16'b0011100000000000;//0.5
    #20;
    $finish;
end

endmodule
