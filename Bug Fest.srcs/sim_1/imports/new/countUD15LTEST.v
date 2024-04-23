`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2023 11:11:37 AM
// Design Name: 
// Module Name: countUD15LTEST
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


module countUD15LTEST();
    reg clkin;
    reg up_in;
    reg dw_in;
    reg LD_in;
    reg Din_in;
    wire [14:0] Q_in;
    wire UTC_in;
    wire DTC_in;
    
    countUD15L UUT (
     .clkin(clkin),
     .up(up_in),
     .dw(dw_in),
     .reset(1'b0),
     .LD(LD_in),
     .Din(Din_in),
     .Q(Q_in),
     .UTC(UTC_in),
     .DTC(DTC_in)
    );
    // Clock parameters
   parameter PERIOD = 10;
   parameter real DUTY_CYCLE = 0.5;
   parameter OFFSET = 2;

       initial
       begin
              clkin = 1'b0;
          #OFFSET
              clkin = 1'b1;
      forever
         begin
            #(PERIOD-(PERIOD*DUTY_CYCLE)) clkin = ~clkin;
         end
       end
    
    initial
    begin
    up_in = 1'b1;
    dw_in = 1'b0;
    LD_in = 1'b0;
    Din_in = 5'b0;
    #500;
    #500;
    end
endmodule
