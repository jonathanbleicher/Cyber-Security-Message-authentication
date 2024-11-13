`timescale 1ns / 1ps

module chacha_top_tb;

  // Parameters
  parameter IN_WIDTH = 512;
  parameter KEY_WIDTH = 256;
  parameter NONCE_WIDTH = 96;
  parameter BLOCK_COUNT_WIDTH = 32;
  parameter WIDTH = 32;
  parameter OUT_WIDTH = 512;

  // Inputs
  reg clk;
  reg resetn;
  reg [KEY_WIDTH-1:0] key;
  reg [NONCE_WIDTH-1:0] nonce;
  reg [BLOCK_COUNT_WIDTH-1:0] block_count;
  reg [IN_WIDTH-1:0] plaintext;
  reg start;

  // Outputs
  wire ready;
  wire valid;
  wire [OUT_WIDTH-1:0] encrypted_msg_out;

  // Instantiate the chacha_top module
  chacha_top #(
    .IN_WIDTH(IN_WIDTH),
    .KEY_WIDTH(KEY_WIDTH),
    .NONCE_WIDTH(NONCE_WIDTH),
    .BLOCK_COUNT_WIDTH(BLOCK_COUNT_WIDTH),
    .WIDTH(WIDTH),
    .OUT_WIDTH(OUT_WIDTH)
  ) uut (
    .clk(clk),
    .resetn(resetn),
    .key(key),
    .nonce(nonce),
    .block_count(block_count),
    .data_in(plaintext),
    .start(start),
    .ready(ready),
    .valid(valid),
    .data_out(encrypted_msg_out)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test vector
  initial begin
    // Initialize inputs
    resetn = 0;
    clk = 0;
    resetn = 0;
    plaintext = 'h1;
    key =  'h00_01_02_03_04_05_06_07_08_09_0a_0b_0c_0d_0e_0f_10_11_12_13_14_15_16_17_18_19_1a_1b_1c_1d_1e_1f;
    nonce = 'h00_00_00_09_00_00_00_4a_00_00_00_00;
    block_count = 32'h1;
    start = 0;

    // Apply reset
    #10 resetn = 1;

    // Wait for some cycles
    #50;

    // Start the encryption process
    start = 1;

    // Monitor the output
    $monitor("Time=%0t: ready=%b, valid=%b, encrypted_msg_out=%h", $time, ready, valid, encrypted_msg_out);

    // Wait for the completion of the encryption
    #100;

    // End the simulation
  end

endmodule
