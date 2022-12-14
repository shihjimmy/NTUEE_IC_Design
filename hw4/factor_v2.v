module factor (
	input  clk,
	input  rst_n,
	input  i_in_valid,
	input  [11:0] i_n,
	output [3:0]  o_p2,
	output [2:0]  o_p3,
	output [2:0]  o_p5,
	output        o_out_valid,
	output [50:0] number
);

wire  [50:0] number0, number1, number2,number3,number4;
wire  		 out_valid_2,out_valid_3,out_valid_5;
wire		 ctrl;
assign number = number0 + number1 + number2 + number3 + number4;

factor_of_2 fct2(.clk(clk),.rst_n(rst_n),.i_n(i_n),.i_in_valid_pos(ctrl),.o_p2(o_p2),.o_out_valid(out_valid_2),.number(number0));
factor_of_3 fct3(.clk(clk),.rst_n(rst_n),.i_n(i_n),.i_in_valid_pos(ctrl),.o_p3(o_p3),.o_out_valid(out_valid_3),.number(number1));
factor_of_5 fct5(.clk(clk),.rst_n(rst_n),.i_n(i_n),.i_in_valid_pos(ctrl),.o_p5(o_p5),.o_out_valid(out_valid_5),.number(number2));

AN3 an3(.Z(o_out_valid),.A(out_valid_2),.B(out_valid_3),.C(out_valid_5),.number(number3));
Detect_Posedge DP0(.clk(clk),.rst_n(rst_n),.i_in_valid(i_in_valid),.control(ctrl),.number(number4));

endmodule

module factor_of_2(
	input  clk,
	input  rst_n,
	input 	[11:0] 	i_n,
	input 			i_in_valid_pos,
	output	[3:0]  	o_p2,
	output 			o_out_valid,
	output  [50:0] 	number
);

wire [50:0] numbers[0:43];

//part1---->set MUXs and DFFs and get o_out_valid
wire [11:0] Q,D;
wire [12:0] D_temp;
wire finish,finish_n;

assign D_temp[12] = 1'b1;
assign finish = D_temp[0];

genvar i;
generate
	for(i=0;i<=11;i=i+1) begin
		FD2 fd0(.Q(Q[i]),.D(D[i]),.CLK(clk),.RESET(rst_n),.number(numbers[i]));
		MUX21H mux_en(.Z(D[i]),.A(D_temp[i]),.B(D_temp[i+1]),.CTRL(finish_n),.number(numbers[12+i]));
		MUX21H mux_posedge(.Z(D_temp[i]),.A(Q[i]),.B(i_n[i]),.CTRL(i_in_valid_pos),.number(numbers[24+i]));
	end
endgenerate

IV iv1(.Z(finish_n),.A(finish),.number(numbers[36]));
FD2 fd2_0(.Q(o_out_valid),.D(finish),.CLK(clk),.RESET(rst_n),.number(numbers[43]));

//-----------------//

//part2---->find o_p2
wire [3:0] counter_r,counter_w;

genvar j;
generate
	for(j=0;j<=3;j=j+1) begin
		MUX21H mux3(.Z(counter_r[j]),.A(o_p2[j]),.B(1'b0),.CTRL(i_in_valid_pos),.number(numbers[j+38]));
	end
endgenerate

adders#(4) add4(.a(counter_r),.b({3'b0,finish_n}),.result(counter_w),.number(numbers[37]));
REGP#(4) regp4(.clk(clk),.rst_n(rst_n),.Q(o_p2),.D(counter_w),.number(numbers[42]));

//-----------------//

reg [50:0] sum;
integer n;
always @(*) begin
	sum = 0;
	for (n=0; n<=43; n=n+1) begin 
		sum = sum + numbers[n];
	end
end
assign number = sum;

endmodule

module factor_of_3(
	input  clk,
	input  rst_n,
	input 	[11:0] 	i_n,
	input 			i_in_valid_pos,
	output	[2:0]  	o_p3,
	output 			o_out_valid,
	output  [50:0] 	number
);

wire [50:0] numbers[0:46];

//part1---->shift and add
wire [16:0] Q;
wire [16:0] temp1,temp2,temp3;

adders#(17) add17_0(.a({2'b0,Q[16:2]}),.b(Q),.result(temp1),.number(numbers[0]));
adders#(17) add17_1(.a({4'b0,temp1[16:4]}),.b(temp1),.result(temp2),.number(numbers[1]));
adders#(17) add17_2(.a({8'b0,temp2[16:8]}),.b(temp2),.result(temp3),.number(numbers[2]));

//-----------------//

//part2---->get quotient check whether Q can be divided by 3
wire [10:0] quotient;
wire finish_n; // if finish_n == 1 means it can be divided
wire finish;

AN2 an2(.Z(finish_n),.A(temp3[5]),.B(temp3[4]),.number(numbers[3]));
add1bit#(11) add1_1(.a(temp3[16:6]),.b(finish_n),.result(quotient),.number(numbers[4]));
IV iv1(.Z(finish),.A(finish_n),.number(numbers[5]));
FD2 fd2_0(.Q(o_out_valid),.D(finish),.CLK(clk),.RESET(rst_n),.number(numbers[6]));

//-----------------//

//part3---->find next number to be divided
wire [16:0] data_in;
wire [16:0] temp4,temp5;
wire [16:0] Q_temp;

assign temp4 = {2'b0,quotient,4'b0};
assign temp5 = {1'b0,i_n,4'b0};

genvar k;
generate
	for(k=0;k<=16;k=k+1) begin
		MUX21H mux0(.Z(data_in[k]),.A(Q[k]),.B(temp4[k]),.CTRL(finish_n),.number(numbers[k+7]));
	end
endgenerate

REGP#(17) regp17(.clk(clk),.rst_n(rst_n),.Q(Q_temp),.D(data_in),.number(numbers[24]));

genvar i;
generate
	for(i=0;i<=16;i=i+1) begin
		MUX21H mux1(.Z(Q[i]),.A(Q_temp[i]),.B(temp5[i]),.CTRL(i_in_valid_pos),.number(numbers[i+25]));
	end
endgenerate

//-----------------//

//part4---->find o_p3
wire [2:0] counter_r,counter_w;

genvar j;
generate
	for(j=0;j<=2;j=j+1) begin
		MUX21H mux3(.Z(counter_r[j]),.A(o_p3[j]),.B(1'b0),.CTRL(i_in_valid_pos),.number(numbers[j+42]));
	end
endgenerate

add1bit#(3) add1_0(.a(counter_r),.b(finish_n),.result(counter_w),.number(numbers[45]));
REGP#(3) regp3(.clk(clk),.rst_n(rst_n),.Q(o_p3),.D(counter_w),.number(numbers[46]));

//-----------------//

reg [50:0] sum;
integer t;
always @(*) begin
	sum = 0;
	for (t=0; t<=46; t=t+1) begin 
		sum = sum + numbers[t];
	end
end
assign number = sum;

endmodule

module factor_of_5(
	input  clk,
	input  rst_n,
	input 	[11:0] 	i_n,
	input 			i_in_valid_pos,
	output	[2:0]  	o_p5,
	output 			o_out_valid,
	output  [50:0] 	number
);

wire [50:0] numbers[0:48];

//part1---->shift and add
wire [17:0] Q;
wire [17:0] temp1,temp2,temp3;

adders#(18) add18_0(.a({Q[16:0],1'b0}),.b(Q),.result(temp1),.number(numbers[0]));
adders#(18) add18_1(.a({4'b0,temp1[17:4]}),.b(temp1),.result(temp2),.number(numbers[1]));
adders#(18) add18_2(.a({8'b0,temp2[17:8]}),.b(temp2),.result(temp3),.number(numbers[2]));

//-----------------//

//part2---->get quotient check whether Q can be divided by 5
wire [9:0] quotient;
wire finish_n; // if finish_n == 1 means it can be divided
wire finish;

AN3 an3(.Z(finish_n),.A(temp3[7]),.B(temp3[6]),.C(temp3[5]),.number(numbers[3]));
add1bit#(10) add1_1(.a(temp3[17:8]),.b(finish_n),.result(quotient),.number(numbers[4]));
IV iv1(.Z(finish),.A(finish_n),.number(numbers[5]));
FD2 fd2_0(.Q(o_out_valid),.D(finish),.CLK(clk),.RESET(rst_n),.number(numbers[6]));

//-----------------//

//part3---->find next number to be divided
wire [17:0] data_in;
wire [17:0] temp4,temp5;
wire [17:0] Q_temp;

assign temp4 = {5'b0,quotient,4'b0};
assign temp5 = {2'b0,i_n,4'b0};

genvar k;
generate
	for(k=0;k<=17;k=k+1) begin
		MUX21H mux0(.Z(data_in[k]),.A(Q[k]),.B(temp4[k]),.CTRL(finish_n),.number(numbers[k+7]));
	end
endgenerate

REGP#(18) regp18(.clk(clk),.rst_n(rst_n),.Q(Q_temp),.D(data_in),.number(numbers[25]));

genvar i;
generate
	for(i=0;i<=17;i=i+1) begin
		MUX21H mux1(.Z(Q[i]),.A(Q_temp[i]),.B(temp5[i]),.CTRL(i_in_valid_pos),.number(numbers[i+26]));
	end
endgenerate

//-----------------//

//part4---->find o_p5
wire [2:0] counter_r,counter_w;

genvar j;
generate
	for(j=0;j<=2;j=j+1) begin
		MUX21H mux3(.Z(counter_r[j]),.A(o_p5[j]),.B(1'b0),.CTRL(i_in_valid_pos),.number(numbers[j+44]));
	end
endgenerate

add1bit#(3) add1_0(.a(counter_r),.b(finish_n),.result(counter_w),.number(numbers[47]));
REGP#(3) regp3(.clk(clk),.rst_n(rst_n),.Q(o_p5),.D(counter_w),.number(numbers[48]));

//-----------------//

reg [50:0] sum;
integer t;
always @(*) begin
	sum = 0;
	for (t=0; t<=48; t=t+1) begin 
		sum = sum + numbers[t];
	end
end
assign number = sum;

endmodule

module add1bit#(
	parameter BW = 2
)(
	input  [BW-1:0] a,
	input  b,
	output [BW-1:0] result,
	output [50:0] number
);

wire [50:0] numbers[0:BW-1];
wire [BW:0] temp;

assign temp[0] = b;

genvar i;
generate
	for(i=0;i<BW;i=i+1) begin
		HA1 ha0(.S(result[i]),.O(temp[i+1]),.A(a[i]),.B(temp[i]),.number(numbers[i]));
	end
endgenerate

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<BW; j=j+1) begin 
		sum = sum + numbers[j];
	end
end
assign number = sum;

endmodule

module adders#(
	parameter BW = 2
)(
	input  [BW-1:0] a,
	input  [BW-1:0] b,
	output [BW-1:0] result,
	output [50:0] number
);

wire [BW:0] CI_temp;
wire [50:0] numbers[0:BW-1];

assign CI_temp[0] = 1'b0;

genvar i;
generate
	for(i=0;i<BW;i=i+1) begin
		FA1 fa0(.S(result[i]),.A(a[i]),.B(b[i]),.CI(CI_temp[i]),.CO(CI_temp[i+1]),.number(numbers[i]));
	end
endgenerate

reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<BW; j=j+1) begin 
		sum = sum + numbers[j];
	end
end
assign number = sum;

endmodule

module Detect_Posedge(
	input  clk,
	input  rst_n,
	input  i_in_valid,
	output control,
	output	[50:0] number
);

wire i_valid_pre, pre_bar;
wire [50:0] num1,num2,num3;
assign number = num1 + num2 + num3;

FD2 f0(.Q(i_valid_pre),.D(i_in_valid),.CLK(clk),.RESET(rst_n),.number(num1));
AN2 an2(.Z(control),.A(i_in_valid),.B(pre_bar),.number(num2));
IV iv1(.Z(pre_bar),.A(i_valid_pre),.number(num3));

endmodule

//BW-bit FD2
module REGP#(
	parameter BW = 2
)(
	input clk,
	input rst_n,
	output [BW-1:0] Q,
	input [BW-1:0] D,
	output [50:0] number
);

wire [50:0] numbers [0:BW-1];

genvar i;
generate
	for (i=0; i<BW; i=i+1) begin
		FD2 f0(Q[i], D[i], clk, rst_n, numbers[i]);
	end
endgenerate

//sum number of transistors
reg [50:0] sum;
integer j;
always @(*) begin
	sum = 0;
	for (j=0; j<BW; j=j+1) begin 
		sum = sum + numbers[j];
	end
end
assign number = sum;

endmodule