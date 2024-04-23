`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2023 09:53:18 PM
// Design Name: 
// Module Name: ToptopL6S23
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


module ToptopL6S23(
   input btnU,  
   input btnD, 
   input btnC,  
   input btnR,  //btnR is the global reset in S23 Lab6
   input btnL,  
   input clkin, 
   output [6:0]seg, 
   output dp, 
   output [3:0]an,
   output [3:0]vgaBlue,
   output [3:0]vgaRed,
   output [3:0]vgaGreen,        
   output Vsync, 
   output Hsync, 
   input [15:0]sw, 
   output [15:0]led
   );
   wire clk,digsel;
   assign dp = 1'b1;
   labVGA_clks not_so_slow (.clkin(clkin), .greset(btnR), .clk(clk), .digsel(digsel));
   wire [9:0]V, H;
   wire [3:0]red, green, blue;
   //wire [9:0]VSW, HSW;
   wire v,h,act;
   wire [3:0]boarder, pond, plat, plat2, plat3, player, bugs;
   PixelAddress p1 (.clk(clk),.H(H),.V(V));
   Syncs s1 (.clk(clk),.HS(H),.VS(V),.Hsync(Hsync),.Vsync(Vsync),.active(act));
   wire ppcol;
   //assign Hsync = HSW;
   //assign Vsync = VSW;
   //assign boarder = (V>=10'd7)&(H>=10'd8)&(;
   wire [9:0]Q_wire, move, move2, move3;
   wire stop_plat;
   //wire flash;
   wire start_game;
   FDRE #(.INIT(1'b0)) play (.C(clk), .R(1'b0), .CE(1'b1), .D(btnC|start_game), .Q(start_game));
   
   Background b1 (.h(H),.v(V),.backBoard(boarder),.pond(pond));
   
   wire [9:0]plen, plen2, plen3;
   
   platForm1 platb (.p(start_game),.clk(clk),.h(H),.v(V),.stop(stop_plat),.plat1(plat),
   .plat2(plat2),.plat3(plat3),.ppcol(ppcol),.plen(plen),.plen2(plen2),.plen3(plen3)
   ,.move1(move),.move2(move2),.move3(move3));
   
   wire bcol;
   
   playerSlug play1 (.up(btnU),.bug(bugs),.plen(plen),.plen2(plen2),.plen3(plen3),.move1(move),.move2(move2),.move3(move3),
   .clk(clk),.h(H),.v(V),.collision(plat|plat2|plat3),.player(player),.endcol(ppcol),.b_col(bcol));
   
   wire count;
   BuGuWu bugu (.p(start_game),.clk(clk),.stop(stop_plat),.h(H),.v(V),.bug(bugs),.collision(bcol),.count(count));
   
   wire [15:0]q_wire;
   wire [3:0]rs, sh;
   ring_counter ring (.clkin(clk), .advance(digsel),.ring(rs));
   countUD15L c1 (.up(count),.dw(1'b0),.clkin(clk),.Din(15'd0),.LD(1'b0),.Q(q_wire));
   Select sel (.N(q_wire),.sel(rs),.H(sh));
   
   hex7seg hex (.n(sh),.seg(seg));
   assign vgaRed   = {4{act}}&((boarder & 4'h0) | (pond & 4'h0) | 
   (plat&~boarder&4'hF)| (plat2&~boarder&4'hF)| (plat3&~boarder&4'hF)| (player&4'hF)| (bugs&~boarder&4'h0));
   
   assign vgaGreen = {4{act}}&((boarder & 4'h0) | (pond & 4'hC) | 
   (plat&~boarder&4'h0)| (plat2&~boarder&4'h0)| (plat3&~boarder&4'hB)| (player&4'hF)| (bugs&~boarder&4'hF));
   
   assign vgaBlue  = {4{act}}&((boarder & 4'hF) | (pond & 4'hF) | 
   (plat&~boarder&4'h0)| (plat2&~boarder&4'hB)| (plat3&~boarder&4'hF)| (player&4'h0)| (bugs&~boarder&4'h0));
   
   assign an[0] = ~rs[0];
   assign an[1] = ~rs[1];
   //assign an[2] = 1'b1;
   //assign an[3] = 1'b1;
   //FDRE #(.INIT(1'b0)) redsynch[3:0] (.C({4{clk}}), .R({4{1'b0}}), .CE({4{1'b1}}), .D(red), .Q(vgaRed));
   //FDRE #(.INIT(1'b0)) greensynch[3:0] (.C({4{clk}}), .R({4{1'b0}}), .CE({4{1'b1}}), .D(green), .Q(vgaGreen));
   //FDRE #(.INIT(1'b0)) bluesynch[3:0] (.C({4{clk}}), .R({4{1'b0}}), .CE({4{1'b1}}), .D(blue), .Q(vgaBlue));

   
endmodule
