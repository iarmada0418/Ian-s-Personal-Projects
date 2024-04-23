`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2023 10:42:37 PM
// Design Name: 
// Module Name: player
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


module playerSlug(
        input up,
        input clk,
        input collision,
        input bug,
        //input start,
        //output [15:0]led,
        input [9:0]move1, 
        input [9:0]move2, 
        input [9:0]move3,
        input [9:0]h,
        input [9:0]v,
        input [9:0]a,
        input [9:0]plen,
        input [9:0]plen2,
        input [9:0]plen3,
        output [3:0]player,
        output flash,
        output b_col,
        output endcol
        //output [1:0]led
    );
    wire slow, slow2, top_pond, top_board;
    wire [9:0]move, moveh;
    
    assign slow = (v==10'd524)&(h==10'd799);
    assign slow2 = (v==10'd523)&(h==10'd798);
    assign top_pond = move>10'd349;
    assign top_board = move <10'd23;
    wire top_plat, bot_plat, top_col, bot_col, pond_col,sidep_col, side_plat1, side_plat2, side_plat3, bug_col, side_board;
    wire side_b;
    wire sidepp_col;
    wire side_bb;
    assign top_plat = v==10'd200;
    assign bot_plat = v==10'd207;
    assign side_board = h==10'd8;
    
    //wire flash;
    wire [14:0]f;
    countUD15L ffl (.up((pond_col|side_bb|(moveh<10'd140))&(slow|slow2)),.dw(1'b0),.clkin(clk),.Din(15'd0),.LD(1'b0),.reset(1'b0),.Q(f));
    
    countUD15L #(.INIT(15'd200)) vert (.up(~up&(slow|slow2)&~top_col&~bot_col&~pond_col&~sidepp_col),
    .dw(~sidepp_col&up&~pond_col&(slow|slow2)&~top_board&~bot_col&~flash),.clkin(clk),.Din(10'd900),
    .LD(1'b0),.reset(1'b0),.Q(move));
    
    countUD15L #(.INIT(15'd140)) hor (.up(1'b0),
    .dw(~side_bb&sidepp_col&(slow)),.clkin(clk),.Din(10'd140),
    .LD(1'b0),.reset(1'b0),.Q(moveh));
    
    //wire [9:0]moveL;
    //countUD15L prside (.up(sidep_col&(slow|slow2)),.dw(1'b0),.clkin(clk),.Din(10'd200),.LD(1'b0),.reset(1'b0),.Q(moveL));
    
    //assign player = {4{
    //((move>=v) & ((v+10'd16)>=move) & (h<=(10'd155))&(h>=(10'd140)) & (~(pond_col&f[5])) & ~sidep_col) |
    //((move>=v) & ((v+10'd16)>=move) & (h<=(move1-10'd16))&(h>=(move1)) & sidep_col)
    //}};
    

    assign side_plat1 = ((10'd155==(move1-plen))|(10'd155==(move2-plen2))|(10'd155==(move3-plen3)));
    //assign led = side_plat1; (move>=v & v+10'd207>=move)&
    FDRE #(.INIT(1'b0)) slugTop (.C(clk), .R(slow), .CE(collision&player&top_plat), .D(1'b1), .Q(top_col));
    FDRE #(.INIT(1'b0)) slugBot (.C(clk), .R(slow), .CE(collision&player&bot_plat), .D(1'b1), .Q(bot_col));
    FDRE #(.INIT(1'b0)) slugPond (.C(clk), .R(slow), .CE(player&top_pond), .D(1'b1), .Q(pond_col));
    
    FDRE #(.INIT(1'b0)) slugRSide (.C(clk), .R(slow), .CE((collision&player&side_plat1)), .D(1'b1), .Q(sidep_col));    
    FDRE #(.INIT(1'b0)) slugrrside (.C(clk), .R(1'b0), .CE(1'b1), .D(sidep_col|sidepp_col), .Q(sidepp_col));
    
    FDRE #(.INIT(1'b0)) slugBug (.C(clk), .R(slow), .CE((bug&player)), .D(1'b1), .Q(bug_col));
    
    
    FDRE #(.INIT(1'b0)) slugBoard (.C(clk), .R(slow), .CE((side_board&player)), .D(1'b1), .Q(side_b));
    FDRE #(.INIT(1'b0)) slugbbb (.C(clk), .R(1'b0), .CE(1'b1), .D(side_b|side_bb), .Q(side_bb));
    
    //& ~(moveh<10'd140&f[5])
    assign player = {4{
    (( (move>=v) & ((v+10'd15)>=move) & (h<=(moveh+10'd15)) & (h>=(moveh)) & ~((side_bb|moveh<10'd140)&f[5]) &~(pond_col&f[5]) ))
    }};
    //& ~(side_b&f[5])
    
    assign b_col = bug_col;
    assign endcol = side_bb;
endmodule
