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

add1bit#(4) add1_0(.a(counter_r),.b(finish_n),.result(counter_w),.number(numbers[37]));
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

wire [50:0] numbers[0:149];

//part1---->division
wire [11:0] Q;
wire [11:0] Q_bar;
wire [10:0] quotient;
wire finish_n; // if finish_n == 1 means it can be divided
wire finish;
wire remainder[0:10][0:1];
wire remainder_bar[0:10][0:1];
wire [9:0] temp1,temp2,temp3,temp4,temp5; 

IV iv_0(.Z(Q_bar[11]),.A(Q[11]),.number(numbers[0]));
AN2 an2_0(.Z(quotient[10]),.A(Q[11]),.B(Q[10]),.number(numbers[1]));
AN2 an2_1(.Z(remainder[10][1]),.A(Q[11]),.B(Q_bar[10]),.number(numbers[2]));
AN2 an2_2(.Z(remainder[10][0]),.A(Q_bar[11]),.B(Q[10]),.number(numbers[3]));

genvar i;
generate
	for(i=0;i<=10;i=i+1) begin
		IV iv_1(.Z(Q_bar[i]),.A(Q[i]),.number(numbers[i+4]));
		IV iv_2(.Z(remainder_bar[i][0]),.A(remainder[i][0]),.number(numbers[i+15]));
		IV iv_3(.Z(remainder_bar[i][1]),.A(remainder[i][1]),.number(numbers[i+26]));
	end
endgenerate

genvar j;
generate
	for(j=0;j<=9;j=j+1) begin
		ND2 nd2_0(.Z(temp1[j]),.A(Q[j]),.B(remainder[j+1][0]),.number(numbers[j+37]));
		ND2 nd2_1(.Z(quotient[j]),.A(temp1[j]),.B(remainder_bar[j+1][1]),.number(numbers[j+47]));
		
		ND2 nd2_2(.Z(temp2[j]),.A(Q_bar[j]),.B(remainder[j+1][0]),.number(numbers[j+57]));
		ND2 nd2_3(.Z(temp3[j]),.A(Q[j]),.B(remainder[j+1][1]),.number(numbers[j+67]));
		ND2 nd2_4(.Z(remainder[j][1]),.A(temp3[j]),.B(temp2[j]),.number(numbers[j+77]));
		
		ND2 nd2_5(.Z(temp4[j]),.A(Q_bar[j]),.B(remainder[j+1][1]),.number(numbers[j+87]));
		ND3 nd3_0(.Z(temp5[j]),.A(Q[j]),.B(remainder_bar[j+1][0]),.C(remainder_bar[j+1][1]),.number(numbers[j+97]));
		ND2 nd2_6(.Z(remainder[j][0]),.A(temp4[j]),.B(temp5[j]),.number(numbers[j+107]));
	end
endgenerate

NR2 nr2_0(.Z(finish_n),.A(remainder[0][0]),.B(remainder[0][1]),.number(numbers[117]));
IV iv1(.Z(finish),.A(finish_n),.number(numbers[118]));
FD2 fd2_0(.Q(o_out_valid),.D(finish),.CLK(clk),.RESET(rst_n),.number(numbers[119]));

//-----------------//

//part2---->find next number to be divided
wire [11:0] data_in;
wire [11:0] next_data;
wire [11:0] Q_temp;
assign next_data = {1'b0,quotient};

genvar k;
generate
	for(k=0;k<=11;k=k+1) begin
		MUX21H mux0(.Z(data_in[k]),.A(Q[k]),.B(next_data[k]),.CTRL(finish_n),.number(numbers[k+120]));
	end
endgenerate

REGP#(12) regp12(.clk(clk),.rst_n(rst_n),.Q(Q_temp),.D(data_in),.number(numbers[132]));

genvar n;
generate
	for(n=0;n<=11;n=n+1) begin
		MUX21H mux1(.Z(Q[n]),.A(Q_temp[n]),.B(i_n[n]),.CTRL(i_in_valid_pos),.number(numbers[n+133]));
	end
endgenerate

//-----------------//

//part3---->find o_p3
wire [2:0] counter_r,counter_w;

genvar m;
generate
	for(m=0;m<=2;m=m+1) begin
		MUX21H mux3(.Z(counter_r[m]),.A(o_p3[m]),.B(1'b0),.CTRL(i_in_valid_pos),.number(numbers[145+m]));
	end
endgenerate

add1bit#(3) add1_0(.a(counter_r),.b(finish_n),.result(counter_w),.number(numbers[148]));
REGP#(3) regp3(.clk(clk),.rst_n(rst_n),.Q(o_p3),.D(counter_w),.number(numbers[149]));

//-----------------//

reg [50:0] sum;
integer t;
always @(*) begin
	sum = 0;
	for (t=0; t<=149; t=t+1) begin 
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

wire [50:0] numbers[0:210];

//part1---->division
wire [11:0] Q;
wire [11:0] Q_bar;
wire [9:0] quotient;
wire finish_n; // if finish_n == 1 means it can be divided
wire finish;
wire remainder[0:9][0:2];
wire remainder_bar[0:9][0:2];
wire [8:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8,temp9,temp10; 
wire tempA,tempB,tempC,tempD,tempE,tempF;

IV iv_0(.Z(Q_bar[11]),.A(Q[11]),.number(numbers[0]));
IV iv_1(.Z(Q_bar[10]),.A(Q[10]),.number(numbers[1]));
AN3 an3_0(.Z(remainder[9][2]),.A(Q[11]),.B(Q_bar[10]),.C(Q_bar[9]),.number(numbers[2]));
AN2 an2_0(.Z(tempA),.A(Q[11]),.B(Q[10]),.number(numbers[3]));
AN2 an2_1(.Z(tempB),.A(Q[11]),.B(Q[9]),.number(numbers[4]));
OR2 or2_0(.Z(quotient[9]),.A(tempA),.B(tempB),.number(numbers[5]));
AN2 an2_2(.Z(tempC),.A(Q_bar[11]),.B(Q[10]),.number(numbers[6]));
AN2 an2_3(.Z(tempD),.A(Q[10]),.B(Q[9]),.number(numbers[7]));
OR2 or2_1(.Z(remainder[9][1]),.A(tempC),.B(tempD),.number(numbers[8]));
AN3 an3_1(.Z(tempE),.A(Q[11]),.B(Q[10]),.C(Q_bar[9]),.number(numbers[9]));
AN2 an2_4(.Z(tempF),.A(Q_bar[11]),.B(Q[9]),.number(numbers[10]));
OR2 or2_2(.Z(remainder[9][0]),.A(tempE),.B(tempF),.number(numbers[11]));

genvar i;
generate
	for(i=0;i<=9;i=i+1) begin
		IV iv_2(.Z(Q_bar[i]),.A(Q[i]),.number(numbers[i+12]));
		IV iv_3(.Z(remainder_bar[i][0]),.A(remainder[i][0]),.number(numbers[i+22]));
		IV iv_4(.Z(remainder_bar[i][1]),.A(remainder[i][1]),.number(numbers[i+32]));
		IV iv_5(.Z(remainder_bar[i][2]),.A(remainder[i][2]),.number(numbers[i+42]));
	end
endgenerate

genvar j;
generate
	for(j=0;j<=8;j=j+1) begin
		ND2 nd2_0(.Z(temp1[j]),.A(Q[j]),.B(remainder[j+1][1]),.number(numbers[j+52]));
		ND2 nd2_1(.Z(temp2[j]),.A(remainder[j+1][0]),.B(remainder[j+1][1]),.number(numbers[j+61]));
		ND3 nd3_0(.Z(quotient[j]),.A(temp1[j]),.B(temp2[j]),.C(remainder_bar[j+1][2]),.number(numbers[j+70]));
		
		ND2 nd2_2(.Z(temp3[j]),.A(Q[j]),.B(remainder[j+1][2]),.number(numbers[j+79]));
		ND3 nd3_1(.Z(temp4[j]),.A(Q_bar[j]),.B(remainder_bar[j+1][0]),.C(remainder[j+1][1]),.number(numbers[j+88]));
		ND2 nd2_3(.Z(remainder[j][2]),.A(temp3[j]),.B(temp4[j]),.number(numbers[j+97]));
		
		ND3 nd3_2(.Z(temp5[j]),.A(Q_bar[j]),.B(remainder_bar[j+1][0]),.C(remainder[j+1][2]),.number(numbers[j+106]));
		ND2 nd2_4(.Z(temp6[j]),.A(Q[j]),.B(remainder[j+1][0]),.number(numbers[j+115]));
		ND2 nd2_5(.Z(temp7[j]),.A(remainder[j+1][0]),.B(remainder_bar[j+1][1]),.number(numbers[j+124]));
		ND3 nd3_3(.Z(remainder[j][1]),.A(temp5[j]),.B(temp6[j]),.C(temp7[j]),.number(numbers[j+133]));

		ND3 nd3_4(.Z(temp8[j]),.A(Q[j]),.B(remainder_bar[j+1][1]),.C(remainder_bar[j+1][2]),.number(numbers[j+142]));
		ND3 nd3_5(.Z(temp9[j]),.A(remainder[j+1][1]),.B(remainder[j+1][0]),.C(Q_bar[j]),.number(numbers[j+151]));
		ND2 nd2_6(.Z(temp10[j]),.A(remainder[j+1][2]),.B(Q_bar[j]),.number(numbers[j+160]));
		ND3 nd3_6(.Z(remainder[j][0]),.A(temp8[j]),.B(temp9[j]),.C(temp10[j]),.number(numbers[j+169]));
	end
endgenerate

NR3 nr3_0(.Z(finish_n),.A(remainder[0][0]),.B(remainder[0][1]),.C(remainder[0][2]),.number(numbers[178]));
IV iv1(.Z(finish),.A(finish_n),.number(numbers[179]));
FD2 fd2_0(.Q(o_out_valid),.D(finish),.CLK(clk),.RESET(rst_n),.number(numbers[180]));

//-----------------//

//part2---->find next number to be divided
wire [11:0] data_in;
wire [11:0] next_data;
wire [11:0] Q_temp;
assign next_data = {2'b0,quotient};

genvar k;
generate
	for(k=0;k<=11;k=k+1) begin
		MUX21H mux0(.Z(data_in[k]),.A(Q[k]),.B(next_data[k]),.CTRL(finish_n),.number(numbers[k+181]));
	end
endgenerate

REGP#(12) regp12(.clk(clk),.rst_n(rst_n),.Q(Q_temp),.D(data_in),.number(numbers[193]));

genvar n;
generate
	for(n=0;n<=11;n=n+1) begin
		MUX21H mux1(.Z(Q[n]),.A(Q_temp[n]),.B(i_n[n]),.CTRL(i_in_valid_pos),.number(numbers[n+194]));
	end
endgenerate

//-----------------//

//part3---->find o_p5
wire [2:0] counter_r,counter_w;

genvar m;
generate
	for(m=0;m<=2;m=m+1) begin
		MUX21H mux3(.Z(counter_r[m]),.A(o_p5[m]),.B(1'b0),.CTRL(i_in_valid_pos),.number(numbers[m+206]));
	end
endgenerate

add1bit#(3) add1_0(.a(counter_r),.b(finish_n),.result(counter_w),.number(numbers[209]));
REGP#(3) regp3(.clk(clk),.rst_n(rst_n),.Q(o_p5),.D(counter_w),.number(numbers[210]));

//-----------------//

reg [50:0] sum;
integer t;
always @(*) begin
	sum = 0;
	for (t=0; t<=210; t=t+1) begin 
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