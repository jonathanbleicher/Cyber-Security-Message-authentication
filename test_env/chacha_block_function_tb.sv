module tb_chacha_block_function;

  // Constants for parameter values
  localparam KEY_WIDTH = 256;
  localparam NONCE_WIDTH = 96;
  localparam BLOCK_COUNT_WIDTH = 32;
  localparam WIDTH = 32;
  localparam OUT_WIDTH = 512;

  // Inputs
  reg clk;
  reg resetn;
  reg [KEY_WIDTH-1:0] key;
  reg [NONCE_WIDTH-1:0] nonce;
  reg [BLOCK_COUNT_WIDTH-1:0] block_count;
  reg start;

  // Outputs
  wire ready;
  wire valid;
  wire [OUT_WIDTH-1:0] out;

  // Instantiate the module under test
  chacha_block_function #(
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
    .start(start),
    .ready(ready),
    .valid(valid),
    .out(out)
  );

  // Clock generation
  always begin
    #5 clk = ~clk; // Toggle clock every 5 time units
  end

  // Test procedure
  initial begin
    // Initialize signals
    clk = 0;
    resetn = 0;
    key = 256'h00_01_02_03_04_05_06_07_08_09_0a_0b_0c_0d_0e_0f_10_11_12_13_14_15_16_17_18_19_1a_1b_1c_1d_1e_1f;
    nonce = 96'h00_00_00_09_00_00_00_4a_00_00_00_00;
    block_count = 32'h1;
    start = 0;

    // Apply reset
    #10 resetn = 1;

    // Wait for some cycles
    #50;

    // Raise start for one clock cycle to trigger the computation
    start = 1;
    #1 start = 0;

    // Monitor the output
    $monitor("Time=%0t: ready=%b, valid=%b, out=%h", $time, ready, valid, out);

    // Wait for the completion of the computation
    #100;
  end

endmodule
