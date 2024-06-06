/*`timescale 1ns / 1ps
`define N 8
`define es 2
`define regime 2
module posit(a,psign,pregime,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    output [`regime-1:0]pregime;
    output [`es-1:0]pexp;
    output [`N-`es-`regime-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;
    wire [`regime-1:0]number;
    reg [`regime-1:0]p_regime;

//-----------------------sign----------------------
    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

//-----------------------inf\zero check----------------------
    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

//-----------------------regime----------------------
    assign number = x[`N-2]?~x[`N-2:`N-2-`regime-1]:x[`N-2:`N-2-`regime-1];


always@(*) begin
case(number)
    2'b01 : p_regime = 2'b11;
    default : p_regime = 2'b10;
endcase
end

    assign pregime = x[`N-2]?p_regime-1'b1:~p_regime+1'b1;
//-----------------------expo----------------------
    assign pexp = x[`N-`regime-2:`N-`regime-`es-1];
//-----------------------frac-----------------------
    assign pfrac = x[`N-`regime-`es-2:0];

endmodule
//---------posit multiplication------------------------
module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y;
    wire [`N-1:0]OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es-`regime)-1:0]mult_out;
    reg [`regime-1:0]result_out;
    wire psign;
    wire [`regime-1:0]pregime;
    wire [`regime+`es-1:0]a_exp,b_exp,t_exp;
    wire [`N-`es-`regime-2:0]pfrac;
    wire a_psign,b_psign;
    wire [`regime-1:0]a_pregime,b_pregime;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-`regime-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;

always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;	end
end
    posit a1(x,a_psign,a_pregime,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pregime,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;

//-----------------------sign----------------------
    assign psign = a_psign ^ b_psign;

//-----------------------frac----------------------
    assign mult_out={1'b1,a_pfrac}*{1'b1,b_pfrac};
    //approx_mult m1(.a(a_pfrac),.b(b_pfrac),.c(mult_out),.t1(1),.t2(1),.t3(1));
    assign result[`N-`es-`regime-2:0] = mult_out[2*(`N-`es-`regime)-1]? mult_out[2*(`N-`es-`regime)-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)] : mult_out[2*(`N-`es-`regime)-1-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)-1];

//-----------------------total_exp----------------------
    assign a_exp = {a_pregime,`es'b0} + a_pexp;
    assign b_exp = {b_pregime,`es'b0} + b_pexp;
    assign t_exp = a_exp + b_exp + mult_out[2*(`N-`es-`regime)-1];
    assign pregime = t_exp[`es+`regime-1:`es];

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];

always@(*) begin
case(pregime)
    2'b11 : result_out = 2'b01;
    2'b10 : result_out = 2'b00;
    2'b00 : result_out = 2'b10;
    default : result_out = 2'b11;
endcase
end

    assign result[`N-1] = psign;
    assign result[`N-2:`N-`regime-1] = pregime;
    assign OUT = result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result;
endmodule
*/
/*
`timescale 1ns / 1ps
`define N 10
`define es 4
`define regime 2
`define new 7
module posit(a,psign,pregime,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    output [`regime-1:0]pregime;
    output [`es-1:0]pexp;
    output [`N-`es-`regime-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;
    wire [`regime-1:0]number;
    reg [`regime-1:0]p_regime;

//-----------------------sign----------------------
    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

//-----------------------inf\zero check----------------------
    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

//-----------------------regime----------------------/
     assign number = x[`N-2]?~x[`N-2:`N-2-`regime+1]:x[`N-2:`N-2-`regime+1];
always@(*) begin
case(number)
    2'b01 : p_regime = 2'b11;
    default : p_regime = 2'b10;
endcase
end

    assign pregime = x[`N-2]?p_regime-1'b1:~p_regime+1'b1;
//-----------------------expo----------------------
    assign pexp = x[`N-`regime-2:`N-`regime-`es-1];
//-----------------------frac-----------------------
    assign pfrac = x[`N-`regime-`es-2:0];

endmodule

//---------posit multiplication------------------------
module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y;
    reg [`N-1:0]OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es-`regime)-1:0]mult_out;
    reg [`regime-1:0]result_out;
    reg [`es-1:0]t_out;
    wire psign;
    reg [1:0]uo;
    wire [`regime-1:0]pregime;
    wire [`regime+`es-1:0]a_exp,b_exp,t_exp;
    wire [`N-`es-`regime-2:0]pfrac;
    wire a_psign,b_psign;
    wire [`regime-1:0]a_pregime,b_pregime;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-`regime-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;
    



always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;
	end
end
    posit a1(x,a_psign,a_pregime,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pregime,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;

//-----------------------sign----------------------
    assign psign = a_psign ^ b_psign;

//-----------------------frac----------------------
    assign mult_out={1'b1,a_pfrac}*{1'b1,b_pfrac};
    assign result[`N-`es-`regime-2:0] = mult_out[2*(`N-`es-`regime)-1]? mult_out[2*(`N-`es-`regime)-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)] : mult_out[2*(`N-`es-`regime)-1-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)-1];

//-----------------------total_exp----------------------
    assign a_exp = {a_pregime,`es'b0} + a_pexp;
    assign b_exp = {b_pregime,`es'b0} + b_pexp;
    assign t_exp = a_exp + b_exp + mult_out[2*(`N-`es-`regime)-1];
    assign pregime = t_exp[`es+`regime-1:`es];

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];

   
always@(*) begin

case(pregime)
    2'b11 : begin
        result_out = 2'b01;
        uo = 2'b00;
    end
    2'b10 : begin 
        result_out = 2'b00;
        // t_out[`es-1:0]=4'b0000;
        uo = 2'b10;
        end
    2'b00 : begin
        result_out = 2'b10;
        uo = 2'b00;
    end
    default : begin
        result_out = 2'b11;
        uo = 2'b01;
    end
endcase
end
    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign result[`N-1] = psign;
    assign result[`N-2:`N-`regime-1] = result_out;
    
//    assign OUT = (6'd100000 < t_exp & 6'b110000) ? 10'b0 :(result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
    // assign OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
    always@(*) begin
        case(uo) 
            // 2'b10 : OUT = psign ? 10'b1110000000 : 10'b0010000000;
            2'b10 : OUT = psign ? {1'b1, ~{2'b01, `new'b0} + 1'b1} : {3'b001, `new'b0};
            2'b00: OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
            // 2'b01: OUT =  psign ? 10'b1010000001 : 10'b0101111111;
            2'b01 : OUT = psign ? {1'b1, ~{2'b10, `new'b1} + 1'b1} : {3'b010, `new'b1};
        endcase
    end
endmodule




always@(*) begin
case(pregime)
    2'b11 : result_out = 2'b01;
    2'b10 : result_out = 2'b00;
    2'b00 : result_out = 2'b10;
    default : result_out = 2'b11;
endcase
end



`timescale 1ns / 1ps
`define N 10
`define es 4
`define regime 2
//`define new 7
module posit(a,psign,pregime,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    output [`regime-1:0]pregime;
    output [`es-1:0]pexp;
    output [`N-`es-`regime-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;
    wire [`regime-1:0]number;
    reg [`regime-1:0]p_regime;

//-----------------------sign----------------------
    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

//-----------------------inf\zero check----------------------
    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

//-----------------------regime----------------------/
     assign number = x[`N-2]?~x[`N-2:`N-2-`regime+1]:x[`N-2:`N-2-`regime+1];
	always@(*) begin
	case(number)
   	 2'b01 : p_regime = 2'b11;
    	default : p_regime = 2'b10;
endcase
end

    assign pregime = x[`N-2]?p_regime-1'b1:~p_regime+1'b1;
//-----------------------expo----------------------
    assign pexp = x[`N-`regime-2:`N-`regime-`es-1];
//-----------------------frac-----------------------
    assign pfrac = x[`N-`regime-`es-2:0];

endmodule

//---------posit multiplication------------------------
module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y;
    reg [`N-1:0]OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es-`regime)-1:0]mult_out;
//  reg [`regime-1:0]result_out;
    reg [`es-1:0]t_out;
    wire psign;
    reg [1:0]uo;
    wire [`regime-1:0]pregime;
    wire [`regime+`es-1:0]a_exp,b_exp,t_exp;
    wire [`N-`es-`regime-2:0]pfrac;
    wire a_psign,b_psign;
    wire [`regime-1:0]a_pregime,b_pregime;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-`regime-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;


always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;
	end
end
    posit a1(x,a_psign,a_pregime,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pregime,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;

//-----------------------sign----------------------
    assign psign = a_psign ^ b_psign;

//-----------------------frac----------------------
    assign mult_out={1'b1,a_pfrac}*{1'b1,b_pfrac};
    assign result[`N-`es-`regime-2:0] = mult_out[2*(`N-`es-`regime)-1]? mult_out[2*(`N-`es-`regime)-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)] : mult_out[2*(`N-`es-`regime)-1-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)-1];

//-----------------------total_exp----------------------
    assign a_exp = {a_pregime,`es'b0} + a_pexp;
    assign b_exp = {b_pregime,`es'b0} + b_pexp;
    assign t_exp = a_exp + b_exp + mult_out[2*(`N-`es-`regime)-1];
    assign pregime = t_exp[`es+`regime-1:`es];

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];

   
always@(*) begin

case(pregime)
    2'b11 : begin
        //result_out = 2'b01;
        uo = 2'b00;
    end
    2'b10 : begin 
        //result_out = 2'b01;
        // t_out[`es-1:0]=4'b0000;
        uo = 2'b10;
        end
    2'b00 : begin
        //result_out = 2'b01;
        uo = 2'b00;
    end
    default : begin
        //result_out = 2'b01;
        uo = 2'b00;
    end
endcase
end
    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign result[`N-1] = psign;
    assign result[`N-2:`N-`regime-1] = 2'b01;
//    assign OUT = (6'd100000 < t_exp & 6'b110000) ? 10'b0 :(result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
//    assign OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
    always@(*) begin
        case(uo) 
	        2'b10 : OUT = psign ? 10'b1110000000 : 10'b0010000000;
            //2'b10 : OUT = psign ? {1'b1,~{2'b01, `new'b0} + 1'b1} : {3'b001, `new'b0};
            2'b00: OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
           // 2'b01: OUT =  psign ? 9'b101000001 : 9'b010111111;
            //2'b01 : OUT = psign ? {1'b1,~{2'b10, `new'b1} + 1'b1} : {3'b010, `new'b1};
        endcase
    end
endmodule



`timescale 1ns / 1ps
`define N 6
`define es 2
`define regime 2
//`define new 7
module posit(a,psign,pregime,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    output [`regime-1:0]pregime;
    output [`es-1:0]pexp;
    output [`N-`es-`regime-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;
    wire [`regime-1:0]number;
    reg [`regime-1:0]p_regime;

//-----------------------sign----------------------
    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

//-----------------------inf\zero check----------------------
    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

//-----------------------regime----------------------/
     assign number = x[`N-2]?~x[`N-2:`N-2-`regime+1]:x[`N-2:`N-2-`regime+1];
	always@(*) begin
	case(number)
   	 2'b01 : p_regime = 2'b11;
    	default : p_regime = 2'b10;
endcase
end

    assign pregime = x[`N-2]?p_regime-1'b1:~p_regime+1'b1;
//-----------------------expo----------------------
    assign pexp = x[`N-`regime-2:`N-`regime-`es-1];
//-----------------------frac-----------------------
    assign pfrac = x[`N-`regime-`es-2:0];

endmodule

//---------posit multiplication------------------------
module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y;
    reg [`N-1:0]OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es-`regime)-1:0]mult_out;
    reg [`regime-1:0]result_out;
    reg [`es-1:0]t_out;
    wire psign;
    wire uo;
    wire pregime;
    wire [`regime+`es-1:0]a_exp,b_exp,t_exp;
    wire [`N-`es-`regime-2:0]pfrac;
    wire a_psign,b_psign;
    wire [`regime-1:0]a_pregime,b_pregime;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-`regime-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;



always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;
	end
end
    posit a1(x,a_psign,a_pregime,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pregime,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;

//-----------------------sign----------------------
    assign psign = a_psign ^ b_psign;

//-----------------------frac----------------------
    assign mult_out={1'b1,a_pfrac}*{1'b1,b_pfrac};
    assign result[`N-`es-`regime-2:0] = mult_out[2*(`N-`es-`regime)-1]? mult_out[2*(`N-`es-`regime)-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)] : mult_out[2*(`N-`es-`regime)-1-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)-1];

//-----------------------total_exp----------------------
    assign a_exp = {a_pregime,`es'b0} + a_pexp;
    assign b_exp = {b_pregime,`es'b0} + b_pexp;
    assign t_exp = a_exp + b_exp + mult_out[2*(`N-`es-`regime)-1];
    assign pregime = t_exp[`es];

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign uo = pregime?1'b0:1'b1;

always@(*) begin

case(pregime)
    2'b11 : begin
        result_out = 2'b01;
        uo = 2'b00;
    end
    2'b10 : begin 
        result_out = 2'b01;
        // t_out[`es-1:0]=4'b0000;
        uo = 2'b10;
        end
    2'b00 : begin
        result_out = 2'b01;
        uo = 2'b00;
    end
    default : begin
        result_out = 2'b01;
        uo = 2'b01;
    end
endcase
end
    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign result[`N-1] = psign;
    assign result[`N-2:`N-`regime-1] = 2'b01;
//    assign OUT = (6'd100000 < t_exp & 6'b110000) ? 10'b0 :(result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
    //assign OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
    always@(*) begin
        case(uo) 
	    1'b1 : OUT = psign ? 6'b111000 : 6'b001000;
            //2'b10 : OUT = psign ? {1'b1,~{2'b01, `new'b0} + 1'b1} : {3'b001, `new'b0};
            1'b0: OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
        //    1'b01: OUT =  psign ? 6'b101001 : 6'b010111;
            //2'b01 : OUT = psign ? {1'b1,~{2'b10, `new'b1} + 1'b1} : {3'b010, `new'b1};
        endcase
    end
endmodule


`timescale 1ns / 1ps
`define N 8
`define es 3
`define regime 2
module posit(a,psign,pregime,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    output [`regime-1:0]pregime;
    output [`es-1:0]pexp;
    output [`N-`es-`regime-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;
    wire [`regime-1:0]number;
    reg [`regime-1:0]p_regime;

    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

     assign number = x[`N-2]?~x[`N-2:`N-2-`regime+1]:x[`N-2:`N-2-`regime+1];
	always@(*) begin
	case(number)
    	2'b01 : p_regime = 2'b11;
    	default : p_regime = 2'b10;
endcase
end

    assign pregime = x[`N-2]?p_regime-1'b1:~p_regime+1'b1;
    assign pexp = x[`N-`regime-2:`N-`regime-`es-1];
    assign pfrac = x[`N-`regime-`es-2:0];

endmodule

module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y;
    reg [`N-1:0]OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es-`regime)-1:0]mult_out;
    reg [`regime-1:0]result_out;
    reg [`es-1:0]t_out;
    wire psign;
    reg [1:0]uo;
    wire [`regime-1:0]pregime;
    wire [`regime+`es-1:0]a_exp,b_exp,t_exp;
    wire [`N-`es-`regime-2:0]pfrac;
    wire a_psign,b_psign;
    wire [`regime-1:0]a_pregime,b_pregime;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-`regime-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;



always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;
	end
end
    posit a1(x,a_psign,a_pregime,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pregime,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;
    assign psign = a_psign ^ b_psign;
    assign mult_out[3]= a_pfrac & b_pfrac;
    assign mult_out[2]= ~(mult_out[3]); 
    assign mult_out[1]= a_pfrac ^ b_pfrac;
    assign mult_out[0]= mult_out[3];
    assign result[`N-`es-`regime-2:0] = mult_out[2*(`N-`es-`regime)-1]? mult_out[2*(`N-`es-`regime)-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)] : mult_out[2*(`N-`es-`regime)-1-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)-1];

    assign a_exp = {a_pregime,`es'b0} + a_pexp;
    assign b_exp = {b_pregime,`es'b0} + b_pexp;
    assign t_exp = a_exp + b_exp + mult_out[2*(`N-`es-`regime)-1];
    assign pregime = t_exp[`es+`regime-1:`es];

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];

   
always@(*) begin

case(pregime)
    2'b11 : begin
        result_out = 2'b01;
        uo = 2'b00;
    end
    2'b10 : begin 
        result_out = 2'b00;
        uo = 2'b10;
        end
    2'b00 : begin
        result_out = 2'b10;
        uo = 2'b00;
    end
    default : begin
        result_out = 2'b11;
        uo = 2'b01;
    end
endcase
end
    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign result[`N-1] = psign;
    assign result[`N-2:`N-`regime-1] = result_out;

    always@(*) begin
        case(uo) 
	    2'b10 : OUT = psign ? 8'b11100000 : 8'b00100000;
            2'b00: OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
            2'b01: OUT =  psign ? 8'b10100001 : 8'b01011111;
        endcase
    end
endmodule

`timescale 1ns / 1ps
`define N 6
`define es 2
module posit(a,psign,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    output [`es-1:0]pexp;
    output [`N-`es-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;

//-----------------------sign----------------------
    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

//-----------------------inf\zero check----------------------
    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

//-----------------------expo----------------------
    assign pexp = x[`N-2:`N-`es-1];
//-----------------------frac-----------------------
    assign pfrac = x[`N-`es-2:0];

endmodule

//---------posit multiplication------------------------
module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y,OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es)-1:0]mult_out;
    reg [`es-1:0]t_out;
    wire psign;
    wire [`es-1:0]a_exp,b_exp;
    wire [`es:0]t_exp;
    wire [`N-`es-2:0]pfrac;
    wire a_psign,b_psign;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;
    wire under_over;
    wire uo;



always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;
	end
end
    posit a1(x,a_psign,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;

//-----------------------sign----------------------
    assign psign = a_psign ^ b_psign;

//-----------------------frac----------------------
    assign mult_out={1'b1,a_pfrac}*{1'b1,b_pfrac};
    assign result[`N-`es-2:0] = mult_out[2*(`N-`es)-1]? mult_out[2*(`N-`es)-1-1:2*(`N-`es)-1-(`N-`es-1)] : mult_out[2*(`N-`es)-1-1-1:2*(`N-`es)-1-(`N-`es-1)-1];

//-----------------------total_exp----------------------
    assign a_exp =  a_pexp;
    assign b_exp =  b_pexp;
    assign t_exp = a_exp + b_exp + mult_out[2*(`N-`es)-1];
    assign under_over = t_exp[`es];
    assign uo = under_over?1'b0:1'b1;

    assign result[`N-2:`N-`es-1] = t_exp[`es-1:0];

    assign result[`N-2:`N-`es-1] = t_exp[`es-1:0];
    assign result[`N-1] = psign;
    always@(*) begin
        case(uo) 
	    1'b1 : OUT = psign ? 6'b100000 : 6'b000000;
        1'b0: OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
        endcase
    end

endmodule
 */

`timescale 1ns / 1ps
`define N 8
`define es 2
`define regime 2
module posit(a,psign,pexp,pfrac,pzero,pinf);
    input [`N-1:0]a;
    output psign;
    //output [`regime-1:0]pregime;
    output [`es-1:0]pexp;
    output [`N-`es-`regime-2:0]pfrac;
    output pzero;
    output pinf;
    wire [`N-2:0]x;
    //wire [`regime-1:0]number;
    //reg [`regime-1:0]p_regime;

//-----------------------sign----------------------
    assign psign = a[`N-1];
    assign x = psign? ~a[`N-2:0] + 1'b1: a[`N-2:0];

//-----------------------inf\zero check----------------------
    assign pzero = psign ? 1'b0:( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0);
    assign pinf = psign ? ( x[`N-2:0]==`N-1'b0 ? 1'b1:1'b0):1'b0;

//-----------------------regime----------------------/
    /* assign number = x[`N-2]?~x[`N-2:`N-2-`regime+1]:x[`N-2:`N-2-`regime+1];
	always@(*) begin
	case(number)
   	 2'b01 : p_regime = 2'b11;
    	default : p_regime = 2'b10;
endcase
end

    assign pregime = x[`N-2]?p_regime-1'b1:~p_regime+1'b1;*/
//-----------------------expo----------------------
    assign pexp = x[`N-`regime-2:`N-`regime-`es-1];
//-----------------------frac-----------------------
    assign pfrac = x[`N-`regime-`es-2:0];

endmodule

//---------posit multiplication------------------------
module pmult(a,b,out,clk,reset,pinf,pzero);
    input [`N-1:0]a,b;
    input clk,reset;
    output reg [`N-1:0]out;
    output pinf,pzero;
    reg [`N-1:0]x,y;
    reg [`N-1:0]OUT;
    wire [`N-1:0]result;
    wire [2*(`N-`es-`regime)-1:0]mult_out;
    reg [`regime-1:0]result_out;
    reg [`es-1:0]t_out;
    wire psign;
    wire uo;
    wire pregime;
    wire [`es:0]a_exp,b_exp,t_exp;
    wire [`N-`es-`regime-2:0]pfrac;
    wire a_psign,b_psign;
    //wire [`regime-1:0]a_pregime,b_pregime;
    wire [`es-1:0]a_pexp,b_pexp;
    wire [`N-`es-`regime-2:0]a_pfrac,b_pfrac;
    wire a_pzero,a_pinf,b_pzero,b_pinf;



always@(posedge clk) begin
if(reset) begin
    x <= `N'b0;
    y <= `N'b0;
    out <= `N'b0;	end
else begin
    x <= a;
    y <= b;
    out <= OUT;
	end
end
    posit a1(x,a_psign,a_pexp,a_pfrac,a_pzero,a_pinf);
    posit b1(y,b_psign,b_pexp,b_pfrac,b_pzero,b_pinf);
    assign pinf = (a_pinf | b_pinf) ? 1'b1 : 1'b0;
    assign pzero = ~(a_pinf|b_pinf)&(a_pzero|b_pzero) ? 1'b1 : 1'b0;

//-----------------------sign----------------------
    assign psign = a_psign ^ b_psign;

//-----------------------frac----------------------
    assign mult_out={1'b1,a_pfrac}*{1'b1,b_pfrac};
    assign result[`N-`es-`regime-2:0] = mult_out[2*(`N-`es-`regime)-1]? mult_out[2*(`N-`es-`regime)-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)] : mult_out[2*(`N-`es-`regime)-1-1-1:2*(`N-`es-`regime)-1-(`N-`es-`regime-1)-1];

//-----------------------total_exp----------------------
    //assign a_exp = {a_pregime,`es'b0} + a_pexp;
    //assign b_exp = {b_pregime,`es'b0} + b_pexp;
    assign t_exp = a_pexp + b_pexp + mult_out[2*(`N-`es-`regime)-1];
    assign pregime = t_exp[`es];

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign uo = pregime?1'b0:1'b1;

    assign result[`N-`regime-2:`N-`es-`regime-1] = t_exp[`es-1:0];
    assign result[`N-1] = psign;
    assign result[`N-2:`N-`regime-1] = 2'b01;

    always@(*) begin
        case(uo) 
	    1'b1 : OUT = psign ? 8'b11100000 : 8'b00100000;
        1'b0: OUT = (result[`N-1]? {result[`N-1],~result[`N-2:0]+1'b1} : result);
        endcase
    end
endmodule
