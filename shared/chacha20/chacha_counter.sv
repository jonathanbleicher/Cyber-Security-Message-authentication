/*------------------------------------------------------------------------------
 * File          : chacha_counter.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   :
 *------------------------------------------------------------------------------*/

module chacha_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        enable,
    output logic [31:0] counter
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end 
        else if (enable) begin
            counter <= counter + 1;
        end
    end
endmodule
