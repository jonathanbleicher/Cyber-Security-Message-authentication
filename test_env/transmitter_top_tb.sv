module transmitter_top_tb;

    // Parameters
    localparam AXI_ENCRYPTED_MSG_WIDTH = 512;
    localparam AXI_PLNTXT_MSG_WIDTH = 488;
    localparam MSG_WIDTH = 488;
    localparam FRAMER_CNTR_WIDTH = 16;
    localparam FRAMER_AUTH_WIDTH = 8;
    localparam FRAMED_TOTAL_WIDTH = 512;
    localparam CHACHA_KEY_WIDTH = 256;
    localparam CHACHA_NONCE_WIDTH = 96;
    localparam CHACHA_BLOCK_COUNT_WIDTH = 32;
    localparam CHACHA_WIDTH = 32;
    localparam CHACHA_OUT_WIDTH = 512;

    // Signals
    logic clk;
    logic resetN;
    logic ready_in;
    logic valid_in;
    logic [AXI_PLNTXT_MSG_WIDTH-1:0] plaintext_data_in;
    logic ready_out;
    logic valid_out;
    logic [AXI_ENCRYPTED_MSG_WIDTH-1:0] encrypted_data_out;

    // Instantiate transmitter_top module
    transmitter_top #(
        .AXI_ENCRYPTED_MSG_WIDTH(AXI_ENCRYPTED_MSG_WIDTH),
        .AXI_PLNTXT_MSG_WIDTH(AXI_PLNTXT_MSG_WIDTH),
        .MSG_WIDTH(MSG_WIDTH),
        .FRAMER_CNTR_WIDTH(FRAMER_CNTR_WIDTH),
        .FRAMER_AUTH_WIDTH(FRAMER_AUTH_WIDTH),
        .FRAMED_TOTAL_WIDTH(FRAMED_TOTAL_WIDTH),
        .CHACHA_KEY_WIDTH(CHACHA_KEY_WIDTH),
        .CHACHA_NONCE_WIDTH(CHACHA_NONCE_WIDTH),
        .CHACHA_BLOCK_COUNT_WIDTH(CHACHA_BLOCK_COUNT_WIDTH),
        .CHACHA_WIDTH(CHACHA_WIDTH),
        .CHACHA_OUT_WIDTH(CHACHA_OUT_WIDTH)
    ) uut (
        .clk(clk),
        .resetN(resetN),
        .ready_in(ready_in),
        .valid_in(valid_in),
        .plaintext_data_in(plaintext_data_in),
        .ready_out(ready_out),
        .valid_out(valid_out),
        .encrypted_data_out(encrypted_data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimuli
    initial begin
        // Initialize signals
        resetN = 0;
        ready_in = 0;
        valid_in = 0;
        plaintext_data_in = 488'b11; 

        // Apply reset
        #10;
        resetN = 1;

        // Test scenario 1
        #25;
        valid_in = 1;
        #50;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        valid_in = 1;
        plaintext_data_in = 488'b00; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        valid_in = 1;
        plaintext_data_in = 488'b100; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        valid_in = 1;
        plaintext_data_in = 488'b1100; 
        #30;
        valid_in = 0;
        #100
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;
        
        valid_in = 1;
        plaintext_data_in = 488'b01; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;


        valid_in = 1;
        plaintext_data_in = 488'b00; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        valid_in = 1;
        plaintext_data_in = 488'b10; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        valid_in = 1;
        plaintext_data_in = 488'b100; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        valid_in = 1;
        plaintext_data_in = 488'b000; 
        #30;
        valid_in = 0;
        #100;
        ready_in = 1;
        #50;
        ready_in = 0;
        #100;

        #10;
    end

endmodule