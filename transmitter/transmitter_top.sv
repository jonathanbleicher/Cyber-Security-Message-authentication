module transmitter_top #(
    //list of all parameters

        //parameters for axi
        parameter AXI_ENCRYPTED_MSG_WIDTH = 512,
        parameter AXI_PLNTXT_MSG_WIDTH = 488,

        //parameters for framer/deframer
        parameter MSG_WIDTH = 488,
        parameter FRAMER_CNTR_WIDTH = 16,
        parameter FRAMER_AUTH_WIDTH = 8,
        parameter FRAMED_TOTAL_WIDTH = 512,

        //parameters for chacha
        parameter CHACHA_MSG_WIDTH = 512,
        parameter CHACHA_CNTR_WIDTH = 32,
        parameter CHACHA_KEY_WIDTH = 256, 
        parameter CHACHA_NONCE_WIDTH = 96,
        parameter CHACHA_BLOCK_COUNT_WIDTH = 32,
        parameter CHACHA_WIDTH = 32,
        parameter CHACHA_OUT_WIDTH = 512

)(
    //transmitter inputs
    input  wire clk,
    input  wire resetN,
    input  wire ready_in,
    input  wire valid_in,
    input  wire [AXI_PLNTXT_MSG_WIDTH-1:0] plaintext_data_in,

    //transmitter outputs
    output wire ready_out,
    output wire valid_out,
    output wire [AXI_ENCRYPTED_MSG_WIDTH-1:0] encrypted_data_out
);

    //internal signals
        //axi master
        reg                                       manager2master_valid;
        reg [AXI_ENCRYPTED_MSG_WIDTH-1:0]         manager2master_encrypted_data;
        reg                                       master2manager_ready;

        //axi slave
        reg                                       manager2slave_ready;
        reg [AXI_PLNTXT_MSG_WIDTH-1:0]            slave2manager_plaintext_data;
        reg                                       slave2manager_valid;

        //key_gen
        reg [CHACHA_KEY_WIDTH-1:0]                manager2keygen_HC_key;
        reg [CHACHA_KEY_WIDTH-1:0]                keygen2manager_key;
        reg [FRAMER_AUTH_WIDTH-1:0]               keygen2manager_auth_tag;

        //chacha
        reg [CHACHA_KEY_WIDTH-1:0]                manager2chacha_key;
        reg [CHACHA_NONCE_WIDTH-1:0]              manager2chacha_nonce;
        reg [CHACHA_BLOCK_COUNT_WIDTH-1:0]        manager2chacha_block_count;
        reg [CHACHA_MSG_WIDTH-1:0]                manager2chacha_framed_plaintext;
        reg                                       manager2chacha_start;
        reg                                       chacha2manager_ready;
        reg                                       chacha2manager_valid;
        reg [CHACHA_OUT_WIDTH-1:0]                chacha2manager_encrypted_msg;
    
    //instantiations

        //manager
        transmitter_manager#(
            .PLAINTEXT_WIDTH(MSG_WIDTH),
            .FRAMED_DATA_WIDTH(FRAMED_TOTAL_WIDTH),
            .FRAMER_CNTR_WIDTH(FRAMER_CNTR_WIDTH),
            .FRAMER_AUTH_WIDTH(FRAMER_AUTH_WIDTH),
            .CHACHA_KEY_WIDTH(CHACHA_KEY_WIDTH), 
            .CHACHA_NONCE_WIDTH(CHACHA_NONCE_WIDTH),
            .CHACHA_BLOCK_COUNT_WIDTH(CHACHA_BLOCK_COUNT_WIDTH),
            .CHACHA_WIDTH(CHACHA_WIDTH),
            .CHACHA_OUT_WIDTH(CHACHA_OUT_WIDTH)
        ) transmitter_manager_inst(
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
            .chacha2manager_ready(chacha2manager_ready),
            .chacha2manager_valid(chacha2manager_valid),
            .manager2chacha_key(manager2chacha_key),
            .manager2chacha_start(manager2chacha_start),
            .manager2chacha_block_count(manager2chacha_block_count),
            .manager2chacha_nonce(manager2chacha_nonce),
            .manager2chacha_framed_plaintext(manager2chacha_framed_plaintext)
        );

        //axi master
        axi_stream_master#(
            .DATA_WIDTH(AXI_ENCRYPTED_MSG_WIDTH)
        ) axi_stream_master_inst(
            .clk(clk),
            .resetN(resetN),
            .valid_input(manager2master_valid),
            .ready_sys(ready_in),
            .data_in(manager2master_encrypted_data),
            .valid(valid_out),
            .ready(master2manager_ready),
            .data_out(encrypted_data_out)
        );
        
        //axi slave
        axi_stream_slave#(
            .DATA_WIDTH(AXI_PLNTXT_MSG_WIDTH)
        ) axi_stream_slave_inst(
            .clk(clk),
            .resetN(resetN),
            .ready_internal(manager2slave_ready),
            .valid_sys(valid_in),
            .data_in(plaintext_data_in),
            .ready(ready_out),
            .valid(slave2manager_valid),
            .data_out(slave2manager_plaintext_data)
        );

        //key generator
        key_generator#(
            .KEY_WIDTH(CHACHA_KEY_WIDTH)
        )key_generator_inst(
            .clk(clk),
            .resetN(resetN),
            .HC_key(manager2keygen_HC_key),
            .random_bits_key(keygen2manager_key),
            .random_bits_auth_tag(keygen2manager_auth_tag)
        );

        //chacha20
        chacha_top#(
            .IN_WIDTH(CHACHA_MSG_WIDTH),
            .KEY_WIDTH(CHACHA_KEY_WIDTH), 
            .NONCE_WIDTH(CHACHA_NONCE_WIDTH),
            .BLOCK_COUNT_WIDTH(CHACHA_BLOCK_COUNT_WIDTH),
            .WIDTH(CHACHA_WIDTH),
            .OUT_WIDTH(CHACHA_OUT_WIDTH)
        ) chacha_top_inst(
            .clk(clk),
            .resetn(resetN),
            .key(manager2chacha_key),
            .nonce(manager2chacha_nonce),
            .block_count(manager2chacha_block_count),
            .data_in(manager2chacha_framed_plaintext),
            .start(manager2chacha_start),
            .ready(chacha2manager_ready),
            .valid(chacha2manager_valid),
            .data_out(chacha2manager_encrypted_msg)
        );

endmodule 
