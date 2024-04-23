`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2023 06:02:00 PM
// Design Name: 
// Module Name: countUD15L
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


module countUD15L #(parameter INIT = 15'd0)(
    
    input up,
    input dw,
    input clkin,
    input [14:0]Din,
    input LD,
    input reset,
    output [14:0]Q,
    output UTC,
    output DTC
    );
    wire up1, up2, up3, dw1, dw2, dw3;
    countUD5L #(.INIT(INIT[4:0]) )c1 (.clkin(clkin), .reset(reset), .up(up), .dw(dw), .LD(LD), .Din(Din[4:0]), .Q(Q[4:0]) , .UTC(up1), .DTC(dw1));
    countUD5L #(.INIT(INIT[9:5]) )c2 (.clkin(clkin), .reset(reset), .up(up&up1), .dw(dw&dw1), .LD(LD), .Din(Din[9:5]), .Q(Q[9:5]) , .UTC(up2), .DTC(dw2));
    countUD5L #(.INIT(INIT[14:10]) )c3 (.clkin(clkin), .reset(reset), .up(up&up2&up1), .dw(dw&dw2&dw1), .LD(LD), .Din(Din[14:10]), .Q(Q[14:10]) , .UTC(up3), .DTC(dw3));
    
    assign UTC = up1&up2&up3;
    assign DTC = dw1&dw2&dw3;
endmodule

