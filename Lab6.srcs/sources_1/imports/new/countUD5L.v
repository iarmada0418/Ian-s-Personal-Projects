`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 03:58:50 PM
// Design Name: 
// Module Name: countUD5L
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


module countUD5L #(parameter INIT = 5'd0)(
    input clkin,
    input up,
    input dw,
    input LD,
    input reset,
    input [4:0] Din,
    output [4:0] Q,
    output UTC,
    output DTC
    );
    wire [4:0]D;
    wire [4:0]x;
    wire [4:0]y;
    wire b;

assign x[0] = ~Q[0];
assign x[1] = Q[1]^Q[0];
assign x[2] = Q[2]^(Q[1]&Q[0]);
assign x[3] = Q[3]^(Q[2]&Q[1]&Q[0]);
assign x[4] = Q[4]^(Q[3]&Q[2]&Q[1]&Q[0]);

assign y[0] = ~Q[0];
assign y[1] = Q[1]^(~Q[0]);
assign y[2] = Q[2]^(~Q[1]&~Q[0]);
assign y[3] = Q[3]^(~Q[2]&~Q[1]&~Q[0]);
assign y[4] = Q[4]^(~Q[3]&~Q[2]&~Q[1]&~Q[0]);

assign D[0] = (x[0]&up&~dw)|(y[0]&~up&dw)|(LD&Din[0]);
assign D[1] = (x[1]&up&~dw)|(y[1]&~up&dw)|(LD&Din[1]);
assign D[2] = (x[2]&up&~dw)|(y[2]&~up&dw)|(LD&Din[2]);
assign D[3] = (x[3]&up&~dw)|(y[3]&~up&dw)|(LD&Din[3]);
assign D[4] = (x[4]&up&~dw)|(y[4]&~up&dw)|(LD&Din[4]);

assign b = LD|(up^dw);

FDRE #(.INIT(INIT[0]) ) ff0 (.C(clkin), .CE(b), .R(reset), .D(D[0]), .Q(Q[0]));
FDRE #(.INIT(INIT[1]) ) ff1 (.C(clkin), .CE(b), .R(reset), .D(D[1]), .Q(Q[1]));
FDRE #(.INIT(INIT[2]) ) ff2 (.C(clkin), .CE(b), .R(reset), .D(D[2]), .Q(Q[2]));
FDRE #(.INIT(INIT[3]) ) ff3 (.C(clkin), .CE(b), .R(reset), .D(D[3]), .Q(Q[3]));
FDRE #(.INIT(INIT[4]) ) ff4 (.C(clkin), .CE(b), .R(reset), .D(D[4]), .Q(Q[4]));

assign UTC = Q[4]&Q[3]&Q[2]&Q[1]&Q[0];
assign DTC = ~Q[4]&~Q[3]&~Q[2]&~Q[1]&~Q[0];
endmodule
