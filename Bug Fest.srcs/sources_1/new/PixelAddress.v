`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2023 09:56:09 PM
// Design Name: 
// Module Name: PixelAddress
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


module PixelAddress(
    input clk,
    output [9:0]V,
    output [9:0]H
    );
    wire [9:0] Q1,Q2;
    wire reset1,reset2;
    assign reset1 = Q1==10'd799; //799
    assign reset2 = Q2==10'd525; //524
    countUD15L hor (.up(1'b1),.dw(1'b0),.clkin(clk),.Din(15'd0),.LD(1'b0),.reset(reset1),.Q(Q1));
    countUD15L ver (.up(reset1),.dw(1'b0),.clkin(clk),.Din(15'd0),.LD(1'b0),.reset(reset2&reset1),.Q(Q2));
    FDRE #(.INIT(1'b0)) h[9:0](.C({10{clk}}), .R({10{1'b0}}), .CE({10{1'b1}}), .D(Q1), .Q(H));
    FDRE #(.INIT(1'b0)) v[9:0](.C({10{clk}}), .R({10{1'b0}}), .CE({10{1'b1}}), .D(Q2), .Q(V));

 //   assign V = Q2;
   // assign H = Q1;
endmodule
