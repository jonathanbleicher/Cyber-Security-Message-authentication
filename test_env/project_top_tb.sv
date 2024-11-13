`timescale 1ns/1ns

module project_tb;

  // Parameters
  parameter AXI_ENCRYPTED_MSG_WIDTH = 512;
  parameter AXI_PLNTXT_MSG_WIDTH = 488;
  parameter MSG_WIDTH = 488;
  parameter FRAMER_CNTR_WIDTH = 16;
  parameter FRAMER_AUTH_WIDTH = 8;
  parameter FRAMED_TOTAL_WIDTH = 512;
  parameter CHACHA_CNTR_WIDTH = 32;
  parameter CHACHA_KEY_WIDTH = 256;
  parameter CHACHA_NONCE_WIDTH = 96;
  parameter CHACHA_BLOCK_COUNT_WIDTH = 32;
  parameter CHACHA_WIDTH = 32;
  parameter CHACHA_OUT_WIDTH = 512;

  //tb signals
  reg clk = 0;
  reg resetN = 1;

  // Transmitter signals
  reg sys2trans_ready;
  reg sys2trans_valid;
  reg trans2sys_ready;
  reg trans2sys_valid;
  reg [AXI_PLNTXT_MSG_WIDTH-1:0] sys2trans_plaintext;
  reg [AXI_ENCRYPTED_MSG_WIDTH-1:0] trans2sys_encrypted_data;


  //Receiver Signals
  reg sys2rec_ready;
  reg sys2rec_valid;
  reg rec2sys_valid;
  reg rec2sys_ready;
  reg [AXI_ENCRYPTED_MSG_WIDTH-1:0] sys2rec_encrypted_data;
  reg [AXI_PLNTXT_MSG_WIDTH-1:0] plaintext_data_out;

  assign sys2rec_valid = trans2sys_valid;
  assign sys2rec_encrypted_data = trans2sys_encrypted_data;

  // Instantiate receiver_top and transmitter_top
  receiver_top #(
    .AXI_ENCRYPTED_MSG_WIDTH(AXI_ENCRYPTED_MSG_WIDTH),
    .AXI_PLNTXT_MSG_WIDTH(AXI_PLNTXT_MSG_WIDTH),
    .MSG_WIDTH(MSG_WIDTH),
    .FRAMER_CNTR_WIDTH(FRAMER_CNTR_WIDTH),
    .FRAMER_AUTH_WIDTH(FRAMER_AUTH_WIDTH),
    .FRAMED_TOTAL_WIDTH(FRAMED_TOTAL_WIDTH),
    .CHACHA_MSG_WIDTH(AXI_ENCRYPTED_MSG_WIDTH),
    .CHACHA_CNTR_WIDTH(CHACHA_CNTR_WIDTH),
    .CHACHA_KEY_WIDTH(CHACHA_KEY_WIDTH),
    .CHACHA_NONCE_WIDTH(CHACHA_NONCE_WIDTH),
    .CHACHA_BLOCK_COUNT_WIDTH(CHACHA_BLOCK_COUNT_WIDTH),
    .CHACHA_WIDTH(CHACHA_WIDTH),
    .CHACHA_OUT_WIDTH(CHACHA_OUT_WIDTH)
  ) receiver_top_inst (
    .clk(clk),
    .resetN(resetN),
    .ready_in(sys2rec_ready),
    .valid_in(sys2rec_valid),
    .encrypted_data_in(sys2rec_encrypted_data),
    .ready_out(rec2sys_ready),
    .valid_out(rec2sys_valid),
    .plaintext_data_out(plaintext_data_out)
  );

  transmitter_top #(
    .AXI_ENCRYPTED_MSG_WIDTH(AXI_ENCRYPTED_MSG_WIDTH),
    .AXI_PLNTXT_MSG_WIDTH(AXI_PLNTXT_MSG_WIDTH),
    .MSG_WIDTH(MSG_WIDTH),
    .FRAMER_CNTR_WIDTH(FRAMER_CNTR_WIDTH),
    .FRAMER_AUTH_WIDTH(FRAMER_AUTH_WIDTH),
    .FRAMED_TOTAL_WIDTH(FRAMED_TOTAL_WIDTH),
    .CHACHA_MSG_WIDTH(FRAMED_TOTAL_WIDTH),
    .CHACHA_CNTR_WIDTH(CHACHA_CNTR_WIDTH),
    .CHACHA_KEY_WIDTH(CHACHA_KEY_WIDTH),
    .CHACHA_NONCE_WIDTH(CHACHA_NONCE_WIDTH),
    .CHACHA_BLOCK_COUNT_WIDTH(CHACHA_BLOCK_COUNT_WIDTH),
    .CHACHA_WIDTH(CHACHA_WIDTH),
    .CHACHA_OUT_WIDTH(CHACHA_OUT_WIDTH)
  ) transmitter_top_inst (
    .clk(clk),
    .resetN(resetN),
    .ready_in(sys2trans_ready),
    .valid_in(sys2trans_valid),
    .plaintext_data_in(sys2trans_plaintext),
    .ready_out(trans2sys_ready),
    .valid_out(trans2sys_valid),
    .encrypted_data_out(trans2sys_encrypted_data)
  );

  // Clock generation
  always #5 clk = ~clk;

initial begin //transmitter
    resetN = 0;
    sys2trans_ready = 0;
    sys2trans_valid = 0;

    #10;
    resetN = 1;
	
    #600;

    //first message 11 -1
    sys2trans_plaintext = 488'b11;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -2
    sys2trans_plaintext = 'h00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //changing message
    sys2trans_plaintext = 'hffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -3
    sys2trans_plaintext = 'h11aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -4
    sys2trans_plaintext = 'h22bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -5
    sys2trans_plaintext = 'h33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -6
    sys2trans_plaintext = 'h11aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -7
    sys2trans_plaintext = 'h22bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -8
    sys2trans_plaintext = 'h33cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -9
    sys2trans_plaintext = 'h11aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

    //next message 00 -10
    sys2trans_plaintext = 'h22bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4;
    #20;
    sys2trans_valid = 1;
    #40;
    sys2trans_valid = 0;
    #500;
    sys2trans_ready = 1;
    #20;
    sys2trans_ready = 0;

    #50;

  end

  initial begin //receiver
    sys2rec_ready = 0;
    #600;
    //1
    #1100;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //2
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //3
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //4
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //5
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    // 6
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //7
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //8
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //9
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;

    //10
    #600;
    sys2rec_ready = 1;
    #40;
    sys2rec_ready = 0;


  end
endmodule
