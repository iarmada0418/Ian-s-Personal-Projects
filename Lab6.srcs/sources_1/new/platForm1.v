`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2023 03:01:52 PM
// Design Name: 
// Module Name: platForm1
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


module platForm1(
        input clk,
        //input start,
        //output [15:0]led,
        input [9:0]h,
        input [9:0]v,
        input [9:0]a,
        input ppcol,
        input stop,
        input p,
        output [3:0]plat1,
        output [3:0]plat2,
        output [3:0]plat3,
        output [9:0]plen,
        output [9:0]plen2,
        output [9:0]plen3,
        output [9:0]move1, 
        output [9:0]move2, 
        output [9:0]move3
        //output [9:0]Q
    );
    //wire [9:0] start, location;
    wire [9:0]move, move2, move3;
    wire slow;
    wire count_con, count_con2, count_con3;
    assign count_con = move<=10'd0;
    assign count_con2 = move2<=10'd0;
    assign count_con3 = move3<=10'd0;
    assign slow = (v==10'd524)&(h==10'd799);
    //assign start = 10'd385;
    //assign location = start - move;
    
    wire [7:0]rand, rand2, rand3, new_rand, new_rand2, new_rand3;
    RandomNumber(.clk(clk),.rnd(rand));
    RandomNumber(.clk(clk),.rnd(rand2));
    RandomNumber(.clk(clk),.rnd(rand3));
    FDRE #(.INIT(1'b0)) r1 [7:0](.C({8{clk}}), .R({8{1'b0}}), .CE({8{count_con}}), .D(rand), .Q(new_rand));
    FDRE #(.INIT(1'b0)) r2 [7:0](.C({8{clk}}), .R({8{1'b0}}), .CE({8{count_con2}}), .D(rand2), .Q(new_rand2));
    FDRE #(.INIT(1'b0)) r3 [7:0](.C({8{clk}}), .R({8{1'b0}}), .CE({8{count_con3}}), .D(rand3), .Q(new_rand3));
    wire [9:0]p1,p2,p3;
    
//    assign p1 = 8'd128+new_rand[4:0];
//    assign p2 = 8'd128+new_rand2[4:0];
//    assign p3 = 8'd128+new_rand3[4:0];
    
    assign p1 = {1'b0,new_rand[7], ~new_rand[7], 2'b00, new_rand[4:2],2'b00};
    assign p2 = {1'b0,new_rand2[7], ~new_rand2[7], 2'b00, new_rand2[4:2],2'b00};
    assign p3 = {1'b0,new_rand3[7], ~new_rand3[7], 2'b00, new_rand3[4:2],2'b00};
    
    assign plen = p1;
    assign plen2 = p2;
    assign plen3 = p3;
    
    wire start;
    
    FDRE #(.INIT(1'b0)) str (.C(clk), .R(1'b0), .CE(count_con), .D(1'b1), .Q(start));
    //#(.INIT(15'd200))
    countUD15L hor (.up(1'b0),.dw(p&slow&~ppcol&~stop),.clkin(clk),.Din({15{start}}&15'd900 | {15{~start}}&15'd200),.LD(count_con),.reset(1'b0),.Q(move));
    //assign plat = {4{((h>10'd385)&(h<10'd550))&((v<=10'd207)&(v>=10'd200))}};
    assign plat1 = {4{((move>h)&((h+p1)>=move))&((v<=10'd207)&(v>=10'd200))}};
    
    countUD15L hor2 (.up(1'b0),.dw(p&slow&~ppcol&~stop),.clkin(clk),.Din({15{start}}&15'd900 | {15{~start}}&15'd500),.LD(count_con2),.reset(1'b0),.Q(move2));
    assign plat2 = {4{((move2>h)&((h+p2)>=move2))&((v<=10'd207)&(v>=10'd200))}};
    
    countUD15L hor3 (.up(1'b0),.dw(p&slow&~ppcol&~stop),.clkin(clk),.Din({15{start}}&15'd900 | {15{~start}}&15'd800),.LD(count_con3),.reset(1'b0),.Q(move3));
    assign plat3 = {4{((move3>h)&((h+p3)>=move3))&((v<=10'd207)&(v>=10'd200))}};
    //assign plat = {4{((location>h)&((h+10'd165)>=location))&((v<=10'd207)&(v>=10'd200))}};
    //assign led = move;
    //+assign Q = move;
    
    
endmodule
