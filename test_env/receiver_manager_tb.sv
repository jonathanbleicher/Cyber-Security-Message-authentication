
`timescale 1ns/1ns

module receiver_manager_tb;

  // Parameters
        localparam PLAINTEXT_WIDTH = 488;
        localparam FRAMED_DATA_WIDTH = 512;
        localparam FRAMER_CNTR_WIDTH = 16;
        localparam FRAMER_AUTH_WIDTH = 8;
        
        //chach
        localparam CHACHA_KEY_WIDTH = 256;
        localparam CHACHA_NONCE_WIDTH = 96;
        localparam CHACHA_BLOCK_COUNT_WIDTH = 32;
        localparam CHACHA_WIDTH = 32;
        localparam CHACHA_OUT_WIDTH = 512;

        //Global

        //local
        localparam STAE_BITS_WIDTH = 2;
        
  // Signals
  reg clk = 0;
  reg resetN = 1;

  reg [FRAMED_DATA_WIDTH-1:0]      slave2manager_cyphertext;
  reg                              slave2manager_valid;
  wire                             manager2slave_ready;

  reg                               master2manager_ready;
  wire [PLAINTEXT_WIDTH-1:0]        manager2master_plaintext;
  wire                              manager2master_valid;

  reg [FRAMED_DATA_WIDTH-1:0]      chacha2manager_decrypted_msg;
  reg                              chacha2manager_valid;
  reg                             chacha2manager_ready;
  wire [CHACHA_KEY_WIDTH-1:0]       manager2chacha_key;
  wire [CHACHA_NONCE_WIDTH-1:0]     manager2chacha_nonce;
  wire                              manager2chacha_start;
  wire [FRAMED_DATA_WIDTH-1:0]      manager2chacha_framed_cyphertext;
  wire [CHACHA_BLOCK_COUNT_WIDTH-1:0] manager2chacha_block_count;

  // Instantiate the receiver_manager module
  receiver_manager #(
    .PLAINTEXT_WIDTH(PLAINTEXT_WIDTH),
    .FRAMED_DATA_WIDTH(FRAMED_DATA_WIDTH)
    // Add other parameters as needed
  ) uut (
    .clk(clk),
    .resetN(resetN),
    .slave2manager_cyphertext(slave2manager_cyphertext),
    .slave2manager_valid(slave2manager_valid),
    .manager2slave_ready(manager2slave_ready),
    .master2manager_ready(master2manager_ready),
    .manager2master_plaintext(manager2master_plaintext),
    .manager2master_valid(manager2master_valid),
    .chacha2manager_decrypted_msg(chacha2manager_decrypted_msg),
    .chacha2manager_valid(chacha2manager_valid),
    .chacha2manager_ready(chacha2manager_ready),
    .manager2chacha_key(manager2chacha_key),
    .manager2chacha_nonce(manager2chacha_nonce),
    .manager2chacha_start(manager2chacha_start),
    .manager2chacha_framed_cyphertext(manager2chacha_framed_cyphertext),
    .manager2chacha_block_count(manager2chacha_block_count)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial block
    initial begin
    resetN = 0;
    slave2manager_cyphertext = 0;
    slave2manager_valid = 0;
    chacha2manager_valid = 0;
    chacha2manager_ready = 0;
    master2manager_ready = 0;

    // Apply reset
    #10 resetN = 1;

    // Scenario
    #20 slave2manager_cyphertext = 512'hA5A5A5A5;  // Example cyphertext
    #20 slave2manager_valid = 1;  
    #50 chacha2manager_ready = 1;                 // Indicate valid data
    #50 chacha2manager_valid = 1;
    chacha2manager_decrypted_msg = 512'b0;  // Indicate decrypted data ready
    #100 master2manager_ready = 1;                // Indicate readiness to master
    #110;
    end

endmodule
