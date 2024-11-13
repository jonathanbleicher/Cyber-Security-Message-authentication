
/*------------------------------------------------------------------------------
 * File          : chacha_quarter_round.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   : done
 *------------------------------------------------------------------------------*/

module chacha_quarter_round #(
	parameter WIDTH = 32
) (
	input  logic [WIDTH-1:0] a_in,
	input  logic [WIDTH-1:0] b_in,
	input  logic [WIDTH-1:0] c_in,
	input  logic [WIDTH-1:0] d_in,
	output logic [WIDTH-1:0] a_out,
	output logic [WIDTH-1:0] b_out,
	output logic [WIDTH-1:0] c_out,
	output logic [WIDTH-1:0] d_out
	
);
	//local signals
	logic [WIDTH-1:0] a_temp0;
	logic [WIDTH-1:0] b_temp0;
	logic [WIDTH-1:0] c_temp0;
	logic [WIDTH-1:0] d_temp0;
	logic [WIDTH-1:0] d_temp0_t;
	logic [WIDTH-1:0] a_temp1;
	logic [WIDTH-1:0] b_temp1;
	logic [WIDTH-1:0] b_temp1_t;
	logic [WIDTH-1:0] c_temp1;
	logic [WIDTH-1:0] d_temp1;
	logic [WIDTH-1:0] a_temp2;
	logic [WIDTH-1:0] b_temp2;
	logic [WIDTH-1:0] c_temp2;
	logic [WIDTH-1:0] d_temp2;
	logic [WIDTH-1:0] d_temp2_t;
	logic [WIDTH-1:0] a_temp3;
	logic [WIDTH-1:0] b_temp3;
	logic [WIDTH-1:0] b_temp3_t;
	logic [WIDTH-1:0] c_temp3;
	logic [WIDTH-1:0] d_temp3;

	
	//logical row 0
	//a += b; d ^= a; d <<<=16;
	assign a_temp0 = a_in + b_in;
	assign b_temp0 = b_in;
	assign c_temp0 = c_in;
	assign d_temp0_t = d_in ^ a_temp0;
	assign d_temp0 = {d_temp0_t[15:0], d_temp0_t[31:16]};
	
	//logical row 1
	//c += d; b ^= c; b <<<= 12;
	assign a_temp1 = a_temp0;
	assign c_temp1 = c_temp0 + d_temp0;
	assign b_temp1_t = b_temp0 ^ c_temp1;
	assign b_temp1 = {b_temp1_t[19:0], b_temp1_t[31:20]};
	assign d_temp1 = d_temp0;
	
	//logical row 2
	//a += b; d ^= a; d <<< 8;
	assign a_temp2 = a_temp1 + b_temp1;
	assign b_temp2 = b_temp1;
	assign c_temp2 = c_temp1;
	assign d_temp2_t = d_temp1 ^ a_temp2;
	assign d_temp2 = {d_temp2_t[23:0], d_temp2_t[31:24]};
	
	//logical row 3
	//c += d; b ^= c; b <<<= 7;
	assign a_temp3 = a_temp2;
	assign c_temp3 = c_temp2 + d_temp2;
	assign b_temp3_t = b_temp2 ^ c_temp3;
	assign b_temp3 = {b_temp3_t[25:0], b_temp3_t[31:25]};
	assign d_temp3 = d_temp2;

	//output
	assign a_out = a_temp3;
	assign b_out = b_temp3;
	assign c_out = c_temp3;
	assign d_out = d_temp3;

endmodule

