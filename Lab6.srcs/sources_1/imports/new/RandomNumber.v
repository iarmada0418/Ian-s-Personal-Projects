`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2023 03:48:50 PM
// Design Name: 
// Module Name: RandomNumber
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


module RandomNumber(
    input clk,
    output [7:0] rnd
    );
    wire a;
    FDRE #(.INIT(1'b1) ) ff0 (.C(clk), .CE(1'b1), .R(1'b0), .D(a), .Q(rnd[0]));
    FDRE #(.INIT(1'b0) ) ff1 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[0]), .Q(rnd[1]));
    FDRE #(.INIT(1'b0) ) ff2 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[1]), .Q(rnd[2]));
    FDRE #(.INIT(1'b0) ) ff3 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[2]), .Q(rnd[3]));
    FDRE #(.INIT(1'b0) ) ff4 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[3]), .Q(rnd[4]));
    FDRE #(.INIT(1'b0) ) ff5 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[4]), .Q(rnd[5]));
    FDRE #(.INIT(1'b0) ) ff6 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[5]), .Q(rnd[6]));
    FDRE #(.INIT(1'b0) ) ff7 (.C(clk), .CE(1'b1), .R(1'b0), .D(rnd[6]), .Q(rnd[7]));
    assign a = rnd[0] ^ rnd[5] ^ rnd[6] ^ rnd[7];

endmodule
