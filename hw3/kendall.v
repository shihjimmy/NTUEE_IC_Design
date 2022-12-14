`timescale 1ns/1ps

module kendall_rank(kendall, i0_x, i0_y, i1_x, i1_y, i2_x, i2_y, i3_x, i3_y);
//DO NOT CHANGE!
    input  [3:0] i0_x, i0_y, i1_x, i1_y, i2_x, i2_y, i3_x, i3_y;
    output [3:0] kendall;
//---------------------------------------------------
    wire   [0:0] temp1,temp2,temp3,temp4,temp5,temp6;
    wire   [2:0] sum;

    concordant_2 C1(.x1(i0_x),.y1(i0_y),.x2(i1_x),.y2(i1_y),.result(temp1));
    concordant_2 C2(.x1(i0_x),.y1(i0_y),.x2(i2_x),.y2(i2_y),.result(temp2));
    concordant_2 C3(.x1(i0_x),.y1(i0_y),.x2(i3_x),.y2(i3_y),.result(temp3));
    concordant_2 C4(.x1(i1_x),.y1(i1_y),.x2(i2_x),.y2(i2_y),.result(temp4));
    concordant_2 C5(.x1(i1_x),.y1(i1_y),.x2(i3_x),.y2(i3_y),.result(temp5));
    concordant_2 C6(.x1(i2_x),.y1(i2_y),.x2(i3_x),.y2(i3_y),.result(temp6));

    quick_add Add_6(.a(temp1),.b(temp2),.c(temp3),.d(temp4),.e(temp5),.f(temp6),.Sum(sum));
    div_and_sub dv_sb(.Sum(sum), .answer(kendall));

endmodule

module concordant_2(x1, y1, x2, y2, result);
    input  [3:0] x1,y1,x2,y2;
    output [0:0] result;
    
    //find whether x1 > x2 or not
    wire ctrl_1, ctrl_2, bigger_1, equal_1,equal_2;
    comparator_2bits cmp1(.x1(x1[3]), .x2(x1[2]), .y1(x2[3]), .y2(x2[2]), .result(ctrl_1), .equal(equal_1));
    comparator_2bits cmp2(.x1(x1[1]), .x2(x1[0]), .y1(x2[1]), .y2(x2[0]), .result(ctrl_2), .equal(equal_2));
    MUX21H mux_0(.Z(bigger_1), .A(ctrl_1), .B(ctrl_2), .CTRL(equal_1));

    //find whether y1 > y2 or not
    wire ctrl_3, ctrl_4, bigger_2, equal_3, equal_4;
    comparator_2bits cmp3(.x1(y1[3]), .x2(y1[2]), .y1(y2[3]), .y2(y2[2]), .result(ctrl_3), .equal(equal_3));
    comparator_2bits cmp4(.x1(y1[1]), .x2(y1[0]), .y1(y2[1]), .y2(y2[0]), .result(ctrl_4), .equal(equal_4));
    MUX21H mux_1(.Z(bigger_2), .A(ctrl_3), .B(ctrl_4), .CTRL(equal_3));

    //xor report discordant
    EO eo(.Z(result), .A(bigger_1), .B(bigger_2)); 

endmodule

module comparator_2bits(x1,x2,y1,y2,result,equal);
    input  [0:0] x1,x2,y1,y2;
    output [0:0] result,equal;

    wire y1_bar,y2_bar;
    IV iv1(.Z(y1_bar), .A(y1));
    IV iv2(.Z(y2_bar), .A(y2));

    wire res_1,res_2;
    EO eo_1(.Z(res_1), .A(x1), .B(y1));
    EO eo_2(.Z(res_2), .A(x2), .B(y2));
    NR2 nr2(.Z(equal), .A(res_1), .B(res_2));

    wire temp1,temp2,temp3;
    AN2 an2(.Z(temp1), .A(x1), .B(y1_bar));
    AN3 an3_1(.Z(temp2), .A(x1), .B(x2), .C(y2_bar));
    AN3 an3_2(.Z(temp3), .A(x2), .B(y1_bar), .C(y2_bar));
    wire temp1_bar,temp2_bar,temp3_bar;
    IV iv4(.Z(temp1_bar), .A(temp1));
    IV iv5(.Z(temp2_bar), .A(temp2));
    IV iv6(.Z(temp3_bar), .A(temp3));
    ND3 nd3(.Z(result), .A(temp1_bar), .B(temp2_bar), .C(temp3_bar));

endmodule

module quick_add(a,b,c,d,e,f,Sum);
    input  [0:0] a,b,c,d,e,f;
    output [2:0] Sum;

    wire temp1;
    wire [1:0] S1,S2;
    
    FA1 fa0_1(.CO(S1[1]), .S(S1[0]), .A(a), .B(b), .CI(c));
    FA1 fa0_2(.CO(S2[1]), .S(S2[0]), .A(d), .B(e), .CI(f));
    
    HA1 ha1_0(.O(temp1), .S(Sum[0]), .A(S1[0]), .B(S2[0]));
    FA1 fa1_0(.CI(temp1), .S(Sum[1]), .CO(Sum[2]), .A(S1[1]), .B(S2[1]));

endmodule

module div_and_sub(Sum,answer);
    input  [2:0] Sum;
    output [3:0] answer;
    //brute force: list every possibility
    //calculate: answer = 1 - Sum/3
    //0000 -> 0100; 0011 -> 0000; 0110 -> 1100
    //0001 -> 0011; 0100 -> 1111; 0111 -> xxxx
    //0010 -> 0001; 0101 -> 1101;
    wire temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8;
    wire a_bar,b_bar,c_bar;
    IV iv1(.Z(a_bar), .A(Sum[0]));
    IV iv2(.Z(b_bar), .A(Sum[1]));
    IV iv3(.Z(c_bar), .A(Sum[2]));

    DRIVER dr(.Z(answer[3]), .A(Sum[2]));
    
    AN3 an3(.Z(temp1), .A(Sum[0]), .B(b_bar), .C(c_bar));
    AN3 an3_2(.Z(temp2), .A(Sum[2]), .B(b_bar), .C(a_bar));
    OR2 or2_1(.Z(answer[1]), .A(temp1), .B(temp2));

    wire temp3_bar,temp4_bar,temp5_bar;
    AN3 an3_3(.Z(temp3), .A(Sum[1]), .B(a_bar), .C(c_bar));
    AN3 an3_4(.Z(temp4), .A(Sum[0]), .B(b_bar), .C(c_bar));
    AN2 an2_2(.Z(temp5), .A(Sum[2]), .B(b_bar));
    IV iv4(.Z(temp3_bar), .A(temp3));
    IV iv5(.Z(temp4_bar), .A(temp4));
    IV iv6(.Z(temp5_bar), .A(temp5));
    ND3 nd3_1(.Z(answer[0]), .A(temp3_bar), .B(temp4_bar), .C(temp5_bar));

    wire temp6_bar,temp7_bar,temp8_bar;
    AN2 an2_5(.Z(temp6), .A(a_bar), .B(b_bar));
    AN2 an2_3(.Z(temp7), .A(Sum[2]), .B(b_bar));
    AN2 an2_4(.Z(temp8), .A(Sum[2]), .B(a_bar));
    IV iv7(.Z(temp6_bar), .A(temp6));
    IV iv8(.Z(temp7_bar), .A(temp7));
    IV iv9(.Z(temp8_bar), .A(temp8));
    ND3 nd3_2(.Z(answer[2]), .A(temp6_bar), .B(temp7_bar), .C(temp8_bar));

endmodule