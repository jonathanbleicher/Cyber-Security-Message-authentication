/*
Notes for using this module:
when the values are ready, and when the module is ready raise start for one clock cycle
This will take X clock cycles to perform
*/
module chacha_block_function #(
    parameter KEY_WIDTH = 256, 
    parameter NONCE_WIDTH = 96,
    parameter BLOCK_COUNT_WIDTH = 32,
    parameter WIDTH = 32,
    parameter OUT_WIDTH = 512,
    parameter DONE_CNTR_WIDTH = 5
)(
    input  logic                         clk,
    input  logic                         resetn,
    input  logic [KEY_WIDTH-1:0]         key,
    input  logic [NONCE_WIDTH-1:0]       nonce,
    input  logic [BLOCK_COUNT_WIDTH-1:0] block_count,
    input  logic                         start,
    output logic                         ready,
    output logic                         valid,
    output logic [OUT_WIDTH-1:0]         out
	
);
    parameter logic [31:0] CONSTANT_0 = 32'h61707865;
    parameter logic [31:0] CONSTANT_1 = 32'h3320646e;
    parameter logic [31:0] CONSTANT_2 = 32'h79622d32;
    parameter logic [31:0] CONSTANT_3 = 32'h6b206574;

    logic [OUT_WIDTH-1:0] state_matrix;
    logic [OUT_WIDTH-1:0] temp_state;
    logic [DONE_CNTR_WIDTH-1:0] done_counter;
    logic                 done_counter_inc;
    logic                 done_counter_resetn;
    logic                 ready_int;
    logic                 valid_int;
    
    logic [WIDTH-1:0] a_in0;
    logic [WIDTH-1:0] b_in0;
    logic [WIDTH-1:0] c_in0;
    logic [WIDTH-1:0] d_in0;
    logic [WIDTH-1:0] a_out0;
    logic [WIDTH-1:0] b_out0;
    logic [WIDTH-1:0] c_out0;
    logic [WIDTH-1:0] d_out0;

    logic [WIDTH-1:0] a_in1;
    logic [WIDTH-1:0] b_in1;
    logic [WIDTH-1:0] c_in1;
    logic [WIDTH-1:0] d_in1;
    logic [WIDTH-1:0] a_out1;
    logic [WIDTH-1:0] b_out1;
    logic [WIDTH-1:0] c_out1;
    logic [WIDTH-1:0] d_out1;

    logic [WIDTH-1:0] a_in2;
    logic [WIDTH-1:0] b_in2;
    logic [WIDTH-1:0] c_in2;
    logic [WIDTH-1:0] d_in2;
    logic [WIDTH-1:0] a_out2;
    logic [WIDTH-1:0] b_out2;
    logic [WIDTH-1:0] c_out2;
    logic [WIDTH-1:0] d_out2;

    logic [WIDTH-1:0] a_in3;
    logic [WIDTH-1:0] b_in3;
    logic [WIDTH-1:0] c_in3;
    logic [WIDTH-1:0] d_in3;
    logic [WIDTH-1:0] a_out3;
    logic [WIDTH-1:0] b_out3;
    logic [WIDTH-1:0] c_out3;
    logic [WIDTH-1:0] d_out3;

    chacha_quarter_round quarter_round0(
        .a_in(a_in0),
        .b_in(b_in0),
        .c_in(c_in0),
        .d_in(d_in0),
        .a_out(a_out0),
        .b_out(b_out0),
        .c_out(c_out0),
        .d_out(d_out0)
    );

    chacha_quarter_round quarter_round1(
        .a_in(a_in1),
        .b_in(b_in1),
        .c_in(c_in1),
        .d_in(d_in1),
        .a_out(a_out1),
        .b_out(b_out1),
        .c_out(c_out1),
        .d_out(d_out1)
    );

    chacha_quarter_round quarter_round2(
        .a_in(a_in2),
        .b_in(b_in2),
        .c_in(c_in2),
        .d_in(d_in2),
        .a_out(a_out2),
        .b_out(b_out2),
        .c_out(c_out2),
        .d_out(d_out2)
    );

    chacha_quarter_round quarter_round3(
        .a_in(a_in3),
        .b_in(b_in3),
        .c_in(c_in3),
        .d_in(d_in3),
        .a_out(a_out3),
        .b_out(b_out3),
        .c_out(c_out3),
        .d_out(d_out3)
    );

    counter#(
        .CNTR_WIDTH(DONE_CNTR_WIDTH)
    ) message_counter_inst(
        .clk(clk),
        .resetn(done_counter_resetn),
        .enable(done_counter_inc),
        .force_bit(1'b0),
        .counter(done_counter)
    );

enum int unsigned { IDLE = 0, EVEN = 2, ODD = 4} state, next_state;

always_comb begin
	  case(state)
		IDLE: begin
                if(start)
                    next_state = EVEN;
        end
		EVEN: begin
                if(!valid_int)
                    next_state = ODD;
        end
		ODD: begin
                if(valid_int)
                    next_state = IDLE;
                else
                    next_state = EVEN;
        end
        default:
            next_state = IDLE;
	  endcase
end

always_comb begin
    case(state)
    IDLE: begin
        temp_state  <= {nonce, block_count, key, CONSTANT_3, CONSTANT_2, CONSTANT_1, CONSTANT_0};
        ready_int <= 1'b1;
        valid_int   <= 1'b0;
        done_counter_inc <= 1'b0;
        if(!resetn)
            done_counter_resetn <= 1'b0;
        else 
            done_counter_resetn <= 1'b1;
    end
    EVEN: begin //columns
        ready_int = 1'b0;
        done_counter_inc <= 1'b1;
        //(0,4,8,12)
        a_in0 <= state_matrix[31:0];
        b_in0 <= state_matrix[159:128];
        c_in0 <= state_matrix[287:256];
        d_in0 <= state_matrix[415:384];
        temp_state[31:0]    <= a_out0;
        temp_state[159:128] <= b_out0;
        temp_state[287:256] <= c_out0;
        temp_state[415:384] <= d_out0;
    
        //(1,5,9,13)
        a_in1 <= state_matrix[63:32];
        b_in1 <= state_matrix[191:160];
        c_in1 <= state_matrix[319:288];
        d_in1 <= state_matrix[447:416];
        temp_state[63:32]    <= a_out1;
        temp_state[191:160] <= b_out1;
        temp_state[319:288] <= c_out1;
        temp_state[447:416] <= d_out1;

        //(3,7,11,15)
        a_in2 <= state_matrix[95:64];
        b_in2 <= state_matrix[223:192];
        c_in2 <= state_matrix[351:320];
        d_in2 <= state_matrix[479:448];
        temp_state[95:64]    <= a_out2;
        temp_state[223:192] <= b_out2;
        temp_state[351:320] <= c_out2;
        temp_state[479:448] <= d_out2;

        //(0,4,8,12)
        a_in3 <= state_matrix[127:96];
        b_in3 <= state_matrix[255:224];
        c_in3 <= state_matrix[383:352];
        d_in3 <= state_matrix[511:480];
        temp_state[127:96]    <= a_out3;
        temp_state[255:224] <= b_out3;
        temp_state[383:352] <= c_out3;
        temp_state[511:480] <= d_out3;
    end
    ODD: begin //diagonal
        //(0,5,10,15)
        a_in0 <= state_matrix[31:0];
        b_in0 <= state_matrix[191:160];
        c_in0 <= state_matrix[351:320];
        d_in0 <= state_matrix[511:480];
        temp_state[31:0]    <= a_out0;
        temp_state[191:160] <= b_out0;
        temp_state[351:320] <= c_out0;
        temp_state[511:480] <= d_out0;

        //(1,6,11,12)
        a_in1 <= state_matrix[63:32];
        b_in1 <= state_matrix[223:192];
        c_in1 <= state_matrix[383:352];
        d_in1 <= state_matrix[415:384];
        temp_state[63:32]    <= a_out1;
        temp_state[223:192] <= b_out1;
        temp_state[383:352] <= c_out1;
        temp_state[415:384] <= d_out1;

        //(2,7,8,13)
        a_in2 <= state_matrix[95:64];
        b_in2 <= state_matrix[255:224];
        c_in2 <= state_matrix[287:256];
        d_in2 <= state_matrix[447:416];
        temp_state[95:64]    <= a_out2;
        temp_state[255:224] <= b_out2;
        temp_state[287:256] <= c_out2;
        temp_state[447:416] <= d_out2;

        //(3,4,9,14)
        a_in3 <= state_matrix[127:96];
        b_in3 <= state_matrix[159:128];
        c_in3 <= state_matrix[319:288];
        d_in3 <= state_matrix[479:448];
        temp_state[127:96]    <= a_out3;
        temp_state[159:128] <= b_out3;
        temp_state[319:288] <= c_out3;
        temp_state[479:448] <= d_out3;

        if(done_counter[4] == 1'b1 && done_counter[1] == 1'b1 && done_counter[0] == 1'b1)begin
            done_counter_inc <= 1'b0;
            done_counter_resetn <= 1'b0;
            valid_int <= 1;
        end
    end
    endcase
end
always_ff@(posedge clk or negedge resetn) begin
	if(!resetn)begin
	    state <= IDLE;
        state_matrix <= {nonce, block_count, key, CONSTANT_3, CONSTANT_2, CONSTANT_1, CONSTANT_0};
    end
	else begin
		state <= next_state;
        state_matrix <= temp_state;
    end 
end

assign out = state_matrix;
assign ready = ready_int;
assign valid = valid_int;

endmodule
    


