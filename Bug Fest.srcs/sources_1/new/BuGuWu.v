`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2023 10:41:15 PM
// Design Name: 
// Module Name: BuGuWu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BuGuWu(
        input clk,
        input p,
        //input start,
        //output [15:0]led,
        input collision,
        input [9:0]h,
        input [9:0]v,
        output [3:0]bug,
        output stop,
        output count
    );
    wire [7:0]rand, new_rand;
    wire count_con;
    wire [9:0]move;
    wire slow, slow2, bug_wire;
    //wire [8:0] bug_position;
    wire [8:0] rhigh, rlow;
    assign count_con = move<=10'd0;
    RandomNumber(.clk(clk),.rnd(rand));
    wire [8:0]low, high, out;
    assign low = 9'd128;
    assign high = 9'd256;
    wire [14:0]f;
    FDRE #(.INIT(1'b1)) r1 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[0]), .Q(new_rand[0]));
    FDRE #(.INIT(1'b1)) r2 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[1]), .Q(new_rand[1]));
    FDRE #(.INIT(1'b1)) r3 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[2]), .Q(new_rand[2]));
    FDRE #(.INIT(1'b1)) r4 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[3]), .Q(new_rand[3]));
    FDRE #(.INIT(1'b1)) r5 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[4]), .Q(new_rand[4]));
    FDRE #(.INIT(1'b1)) r6 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[5]), .Q(new_rand[5]));
    FDRE #(.INIT(1'b1)) r7 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[6]), .Q(new_rand[6]));
    FDRE #(.INIT(1'b1)) r8 (.C(clk), .R(1'b0), .CE(count_con|f[7]), .D(rand[7]), .Q(new_rand[7]));
    TwoToOneMux(.s(new_rand[4]),.i0(low),.i1(high),.y(out));
    wire [8:0]less;
    assign slow = (v==10'd479)&(h==10'd639);
    assign slow2 = (v==10'd480)&(h==10'd640);
    assign less = out+new_rand[4:0];
    //assign new_rand = +rand[4:0];
    
    wire flash;
    
    FDRE #(.INIT(1'b0)) bugf (.C(clk), .R(1'b0), .CE(((collision&~flash)|f[7])), .D(~flash), .Q(flash));
    
    
    countUD15L ffl (.up((flash)&(slow|slow2)),.dw(1'b0),.clkin(clk),.Din(15'd0),.LD(f[7]),.reset(1'b0),.Q(f));    
    
    //wire [14:0]ff;
    //countUD15L ff2 (.up(f[7]&(slow|slow2)),.dw(1'b0),.clkin(clk),.Din(15'd0),.LD(ff[4]),.reset(1'b0),.Q(ff));
    
    
    
    countUD15L #(.INIT(15'd700)) b1 (.up(1'b0),.dw(~flash&(slow|slow2)&p),.clkin(clk),.Din(10'd700),.LD(count_con|f[7]),.reset(1'b0),.Q(move));
    //assign bug = {4{((move>h)&((h+10'd8)>=move))&((v<=(10'd107))&(v>=10'd100))}};
    assign bug = {4{((move>h)&((h+10'd8)>=move))&((v<=less+10'd7)&(v>=(less))&~(flash&f[3]))}};
    assign stop = flash;
    assign count = f[7];
    
endmodule
