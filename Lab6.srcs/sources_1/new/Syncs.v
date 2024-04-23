`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2023 02:48:32 PM
// Design Name: 
// Module Name: Syncs
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


module Syncs(
    input clk,
    input [9:0]HS,
    input [9:0]VS,
    output Hsync,
    output Vsync,
    output active
    );
    wire hsync, vsync, awire;
    //assign hsync = ~(HS >= 10'd655 & HS <= 10'd750);
    assign hsync = (HS < 10'd654) | (HS > 10'd749);
    assign vsync = ~(VS == 10'd489 | VS == 10'd490);
    
   // assign Hsync = ~(HS>=10'd655&HS<=10'd750);
    //assign Vsync = ~((VS==10'd489)|(VS==10'd490));
    assign awire = (VS<=10'd479) & (HS<=10'd639);
    
    
    FDRE #(.INIT(1'b1)) Hsyn (.C(clk),.R(1'b0),.CE(1'b1), .D(hsync), .Q(Hsync));
    FDRE #(.INIT(1'b1)) Vsyn (.C(clk),.R(1'b0),.CE(1'b1), .D(vsync), .Q(Vsync));
    FDRE #(.INIT(1'b1)) Asyn (.C(clk),.R(1'b0),.CE(1'b1), .D(awire), .Q(active));
   
endmodule
