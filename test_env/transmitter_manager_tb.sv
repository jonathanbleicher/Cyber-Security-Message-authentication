module tb_transmitter_manager;

  reg clk;
  reg resetN;

  // AXI slave signals
  reg [487:0] slave2manager_plaintext_data;
  reg slave2manager_valid;
  wire manager2slave_ready;

  // AXI master signals
  wire [511:0] manager2master_encrypted_data;
  wire manager2master_valid;
  reg master2manager_ready;

  // Key Generator signals
  reg [255:0] keygen2manager_key;
  reg [7:0] keygen2manager_auth_tag;
  wire [255:0] manager2keygen_HC_key;

  // Chacha signals
  reg [511:0] chacha2manager_encrypted_msg;
  reg chacha2manager_valid;
  reg chacha2manager_ready;
  wire [255:0] manager2chacha_key;
  wire manager2chacha_start;
  wire [511:0] manager2chacha_framed_plaintext;
  wire [31:0] manager2chacha_block_count;
  wire [95:0] manager2chacha_nonce;

  // Debug signals
  reg [1:0] state;

  // Instantiate the transmitter_manager module
  transmitter_manager #(
    .PLAINTEXT_WIDTH(488),
    .FRAMED_DATA_WIDTH(512),
    .FRAMER_CNTR_WIDTH(16),
    .FRAMER_AUTH_WIDTH(8),
    .CHACHA_KEY_WIDTH(256),
    .CHACHA_NONCE_WIDTH(96),
    .CHACHA_BLOCK_COUNT_WIDTH(32),
    .CHACHA_WIDTH(32),
    .CHACHA_OUT_WIDTH(512),
    .STAE_BITS_WIDTH(2)
  ) manager (
    .clk(clk),
    .resetN(resetN),
    .slave2manager_plaintext_data(slave2manager_plaintext_data),
    .slave2manager_valid(slave2manager_valid),
    .manager2slave_ready(manager2slave_ready),
    .master2manager_ready(master2manager_ready),
    .manager2master_encrypted_data(manager2master_encrypted_data),
    .manager2master_valid(manager2master_valid),
    .keygen2manager_key(keygen2manager_key),
    .keygen2manager_auth_tag(keygen2manager_auth_tag),
    .manager2keygen_HC_key(manager2keygen_HC_key),
    .chacha2manager_encrypted_msg(chacha2manager_encrypted_msg),
    .chacha2manager_valid(chacha2manager_valid),
    .chacha2manager_ready(chacha2manager_ready),
    .manager2chacha_key(manager2chacha_key),
    .manager2chacha_nonce(manager2chacha_nonce),
    .manager2chacha_start(manager2chacha_start),
    .manager2chacha_framed_plaintext(manager2chacha_framed_plaintext),
    .manager2chacha_block_count(manager2chacha_block_count)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Initial block
  initial begin
    //reset 50ns
    resetN = 0;
    #20;
    slave2manager_plaintext_data = 488'h3;
    slave2manager_valid = 0;
    keygen2manager_key = 256'h6;
    keygen2manager_auth_tag = 8'he4;
    chacha2manager_ready = 0;
    chacha2manager_valid = 0;
    #30;
    resetN = 1;

    //feed first message 100ns
    slave2manager_valid = 1;
    #30;
    slave2manager_valid = 0;
    #20;
    chacha2manager_ready = 1;
    #10;
    chacha2manager_ready = 0;
    #30;
 
    //send first message
    chacha2manager_encrypted_msg = 512'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
    chacha2manager_valid = 1;
    #10;
    chacha2manager_valid = 0;
    master2manager_ready = 1;

    //IDLE
    #50;

    //2nd message
    slave2manager_plaintext_data = 488'h2;
    slave2manager_valid = 1;
    #30;
    slave2manager_valid = 0;
    #40;
    chacha2manager_ready = 1;
    #10;
    chacha2manager_ready = 0;
    #10;

    //send 2nd message
    chacha2manager_encrypted_msg = 512'h35;
    chacha2manager_valid = 1;
    #10;
    chacha2manager_valid = 0;
    master2manager_ready = 1;




    //IDLE
    #50;

    //3rd message
    slave2manager_plaintext_data = 488'h0;
    slave2manager_valid = 1;
    #30;
    slave2manager_valid = 0;
    #40;
    chacha2manager_ready = 1;
    #10;
    chacha2manager_ready = 0;
    #10;

    //send 3rd message
    chacha2manager_encrypted_msg = 512'h99;
    chacha2manager_valid = 1;
    #10;
    chacha2manager_valid = 0;
    master2manager_ready = 1;

    //IDLE
    #50;

    keygen2manager_key = 256'h080;
    keygen2manager_auth_tag = 8'hed;

    //4th message
    slave2manager_plaintext_data = 488'h0;
    slave2manager_valid = 1;
    #30;
    slave2manager_valid = 0;
    #40;
    chacha2manager_ready = 1;
    #10;
    chacha2manager_ready = 0;
    #10;

    //send 4th message
    chacha2manager_encrypted_msg = 512'haa;
    chacha2manager_valid = 1;
    #10;
    chacha2manager_valid = 0;
    master2manager_ready = 1;

    //IDLE
    #50;

    //5th message
    slave2manager_plaintext_data = 488'h0;
    slave2manager_valid = 1;
    #30;
    slave2manager_valid = 0;
    #40;
    chacha2manager_ready = 1;
    #10;
    chacha2manager_ready = 0;
    #10;

    //send 5th message
    chacha2manager_encrypted_msg = 512'h9f;
    chacha2manager_valid = 1;
    #10;
    chacha2manager_valid = 0;
    master2manager_ready = 1;

    //IDLE
    #50;

    //6th message
    slave2manager_plaintext_data = 488'h01;
    slave2manager_valid = 1;
    #30;
    slave2manager_valid = 0;
    #40;
    chacha2manager_ready = 1;
    #10;
    chacha2manager_ready = 0;
    #10;

    //send 6th message
    chacha2manager_encrypted_msg = 512'h62;
    chacha2manager_valid = 1;
    #10;
    chacha2manager_valid = 0;
    master2manager_ready = 1;

    #100;

    // Display the results
    $display("State: %0d", state);
    $display("manager2slave_ready: %b", manager2slave_ready);
    $display("manager2master_encrypted_data: %h", manager2master_encrypted_data);
    $display("manager2master_valid: %b", manager2master_valid);
    $display("manager2keygen_HC_key: %h", manager2keygen_HC_key);
    $display("manager2chacha_key: %h", manager2chacha_key);
    $display("manager2chacha_start: %b", manager2chacha_start);
    $display("manager2chacha_framed_plaintext: %h", manager2chacha_framed_plaintext);
    $display("manager2chacha_block_count: %0d", manager2chacha_block_count);

    // End the simulation
    $stop;
  end

endmodule
