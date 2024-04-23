`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2023 06:40:58 PM
// Design Name: 
// Module Name: Background
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


module Background(
        input [9:0]h,
        input [9:0]v,
        input [9:0]a,
        output [3:0]backBoard,
        output [3:0]pond
    );
    //wire [3:0]b;
    //wire p;
    assign backBoard = {4{(v>=10'd0 & v<=10'd479)&(h>=10'd0 & h<=10'd7)
    | (v>=10'd0 & v<=10'd479)&(h>=10'd632 & h<=10'd640)
    | (h>=10'd0 & h<=10'd640)&(v>=10'd0 & v<=10'd7)
    | (h>=10'd0 & h<=10'd640)&(v>=10'd472 & v<=10'd479)}};
    //assign backBoard = {b,b,b,b};
    
    assign pond = {4{(h>=10'd8 & h<=10'd631)&(v>=10'd350 & v<=10'd473)}};
    //assign pond = {p,p,p,p};
    
endmodule
