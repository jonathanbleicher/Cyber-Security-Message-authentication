/*------------------------------------------------------------------------------
 * File          : framer.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   : recieves components of the message, frames them and passes on 
 *                 a framed message along with a modified version for 
 *                 authentication
 *------------------------------------------------------------------------------*/

module framer
(
    input  logic         start,
    input  logic         reset,
    input  logic [31:0]  timestamp,
    input  logic [8:0]   length,
    input  logic [473:0] message,
    output logic [511:0] framed_message,
    output logic [511:0] modified_framed_message
);
  
    logic [511:0] framed_message_reg;
    logic [511:0] modified_framed_message_reg;

    always @(posedge start or posedge reset) begin
        if(reset)begin
            framed_message = 0;
            modified_framed_message = 0;
        end 
        else begin
            framed_message_reg = {timestamp, length, message};
            modified_framed_message_reg = framed_message_reg + 1;
        end
    end
    assign framed_message = framed_message_reg;
    assign modified_framed_message = modified_framed_message_reg;

    endmodule
