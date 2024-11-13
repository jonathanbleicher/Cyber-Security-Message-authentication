module chacha_top #(
    parameter IN_WIDTH = 512,
    parameter KEY_WIDTH = 256, 
    parameter NONCE_WIDTH = 96,
    parameter BLOCK_COUNT_WIDTH = 32,
    parameter WIDTH = 32,
    parameter OUT_WIDTH = 512
)(
    input  logic                         clk,
    input  logic                         resetn,
    input  logic [KEY_WIDTH-1:0]         key,
    input  logic [NONCE_WIDTH-1:0]       nonce,
    input  logic [BLOCK_COUNT_WIDTH-1:0] block_count,
    input  logic [IN_WIDTH-1:0]          data_in,
    input  logic                         start,
    output logic                         ready,
    output logic                         valid,
    output logic [OUT_WIDTH-1:0]         data_out
);

wire [OUT_WIDTH-1:0] key_stream;

chacha_block_function#(
    .KEY_WIDTH(KEY_WIDTH), 
    .NONCE_WIDTH(NONCE_WIDTH),
    .BLOCK_COUNT_WIDTH(BLOCK_COUNT_WIDTH),
    .WIDTH(WIDTH),
    .OUT_WIDTH(OUT_WIDTH)
)chacha_block_function_inst(
    .clk(clk),
    .resetn(resetn),
    .key(key),
    .nonce(nonce),
    .block_count(block_count),
    .ready(ready),
    .start(start),
    .valid(valid),
    .out(key_stream)
);

// assign data_out = key_stream ^ plaintext_padded;
assign data_out = key_stream ^ data_in;

endmodule
    


