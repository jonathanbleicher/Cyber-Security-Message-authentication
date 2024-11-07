/*------------------------------------------------------------------------------
* File          : deframer.sv
* Project       : RTL
* Author        : epjoed
* Creation date : May 23, 2023
* Description   : 
*------------------------------------------------------------------------------*/
module VerifyMessage
(
    input  logic         start,
    input  logic         reset,
    input  logic [511:0] message,
    input  logic [511:0] modified_message,
    input  logic [31:0]  timestamp,
    input  logic [9:0]   threshold,
    output logic [473:0] verified_message,
    output logic         valid
);

    logic [473:0] verified_message_reg;
    logic valid_reg;

    always @(posedge start or posedge reset) begin
        if(reset == 1)begin
            verified_message_reg = 0;
            valid_reg = 0;
        end 
        else begin
            // Check if message + 1 equals message
            if ((message + 1 == message)                    && 
                (message[511:224] >= timestamp - threshold) && 
                (message[511:224] <= timestamp + threshold)) begin
                verified_message_reg = message[511:40];
                valid_reg = 1;
            end
            else begin
                verified_message_reg = 0;
                valid_reg = 0;
            end
        end
    end

    assign verified_message = verified_message_reg;
    assign valid = valid_reg;

endmodule
