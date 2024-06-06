`include "ahma.v"


module tb_;
reg a,b,c,d;
wire S,C;


 
ahma C1(
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .S(S),
    .C(C)
);



initial begin
    $dumpfile("tb_.vcd");
    $dumpvars(0, tb_);
end

initial begin
    a=1'b0; b=1'b0; c=1'b0; d=1'b0;
    #20;
    a=1'b0;b=1'b0;c=1'b0;d=1'b1;
    #20;
    a=1'b0;b=1'b0;c=1'b1;d=1'b0;
    #20;
    a=1'b0;b=1'b0;c=1'b1;d=1'b1;
    #20;
    a=1'b0;b=1'b1;c=1'b0;d=1'b0;
    #20;
    a=1'b0;b=1'b1;c=1'b0;d=1'b1;
    #20;
    a=1'b0;b=1'b1;c=1'b1;d=1'b0;
    #20;
    a=1'b0;b=1'b1;c=1'b1;d=1'b1;
    #20;
    a=1'b1;b=1'b0;c=1'b0;d=1'b0;
    #20;
    a=1'b1;b=1'b0;c=1'b0;d=1'b1;
    #20;
    a=1'b1;b=1'b0;c=1'b1;d=1'b0;
    #20;
    a=1'b1;b=1'b0;c=1'b1;d=1'b1;
    #20;
    a=1'b1;b=1'b1;c=1'b0;d=1'b0;
    #20;
    a=1'b1;b=1'b1;c=1'b0;d=1'b1;
    #20;
    a=1'b1;b=1'b1;c=1'b1;d=1'b0;
    #20;
    a=1'b1;b=1'b1;c=1'b1;d=1'b1;
    #20;
end

endmodule

