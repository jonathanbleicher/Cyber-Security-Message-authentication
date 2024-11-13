/*------------------------------------------------------------------------------
 * File          : chacha_counter.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   : tested, tb does not check wrap around because that takes too long
 *------------------------------------------------------------------------------*/

module counter #(
	parameter CNTR_WIDTH = 32
)(
    input  logic        			clk,
    input  logic        			resetn,
    input  logic        			enable,
    input  logic        			force_bit,
    input  logic [CNTR_WIDTH-1:0] 	force_value,
    output logic [CNTR_WIDTH-1:0] 	counter
);
    always @(posedge clk or posedge resetn) begin
        if (resetn == 1'b0) begin
            counter <= 0;
        end 
        else if (enable == 1'b1) begin
            if(force_bit)begin
                counter <= force_value;
            end
            else begin
                counter <= counter + 1;
            end
        end
        else begin
            counter <= counter;
        end 
    end
endmodule
