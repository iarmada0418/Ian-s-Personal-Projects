`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2023 05:06:37 PM
// Design Name: 
// Module Name: ring_counter
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


module ring_counter(
    input clkin, advance,
    output [3:0]ring
    );
FDRE #(.INIT(1'b1) ) ff0 (.C(clkin), .CE(advance), .R(1'b0), .D(ring[3]), .Q(ring[0]));
FDRE #(.INIT(1'b0) ) ff1 (.C(clkin), .CE(advance), .R(1'b0), .D(ring[0]), .Q(ring[1]));
FDRE #(.INIT(1'b0) ) ff2 (.C(clkin), .CE(advance), .R(1'b0), .D(ring[1]), .Q(ring[2]));
FDRE #(.INIT(1'b0) ) ff3 (.C(clkin), .CE(advance), .R(1'b0), .D(ring[2]), .Q(ring[3]));
endmodule
