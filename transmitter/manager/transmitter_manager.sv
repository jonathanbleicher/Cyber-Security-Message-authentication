module transmitter_manager #(
    //parameters
        //framer
        parameter PLAINTEXT_WIDTH = 488,
        parameter FRAMED_DATA_WIDTH = 512,
        parameter FRAMER_CNTR_WIDTH = 16,
        parameter FRAMER_AUTH_WIDTH = 8,
        
        //chacha
        parameter CHACHA_KEY_WIDTH = 256, 
        parameter CHACHA_NONCE_WIDTH = 96,
        parameter CHACHA_BLOCK_COUNT_WIDTH = 32,
        parameter CHACHA_WIDTH = 32,
        parameter CHACHA_OUT_WIDTH = 512,

        //local
        parameter STAE_BITS_WIDTH = 2
    
)(
    input wire clk,
    input wire resetN,

    //AXI slave 
    input  wire [PLAINTEXT_WIDTH-1:0]        slave2manager_plaintext_data,
    input  wire                              slave2manager_valid,
    output wire                              manager2slave_ready,

    //AXI master
    input wire                               master2manager_ready,
    output wire [FRAMED_DATA_WIDTH-1:0]      manager2master_encrypted_data,
    output wire                              manager2master_valid,

    //Key Generator
    input  wire [CHACHA_KEY_WIDTH-1:0]       keygen2manager_key,
    input  wire [FRAMER_AUTH_WIDTH-1:0]      keygen2manager_auth_tag,
    output  wire [CHACHA_KEY_WIDTH-1:0]      manager2keygen_HC_key,
    
    //Chacha
    input  wire [FRAMED_DATA_WIDTH-1:0]      chacha2manager_encrypted_msg,
    input  wire                              chacha2manager_valid,
    input  wire                              chacha2manager_ready,
    output wire [CHACHA_KEY_WIDTH-1:0]       manager2chacha_key,
    output wire [CHACHA_NONCE_WIDTH-1:0]     manager2chacha_nonce,
    output wire                              manager2chacha_start,
    output wire [FRAMED_DATA_WIDTH-1:0]      manager2chacha_framed_plaintext,
    output wire [CHACHA_BLOCK_COUNT_WIDTH-1:0] manager2chacha_block_count

);

    //internal signals and registers
    reg  [PLAINTEXT_WIDTH-1:0]                 curr_plaintext_data_reg;
    reg [FRAMED_DATA_WIDTH-1:0]                curr_framed_msg;
    reg [FRAMER_CNTR_WIDTH-1:0]                curr_msg_counter;
    reg  [FRAMER_AUTH_WIDTH-1:0]               curr_auth_tag;
    reg  [CHACHA_KEY_WIDTH-1:0]                curr_key;

    reg  [CHACHA_KEY_WIDTH-1:0]                 next_key;
    reg  [FRAMER_AUTH_WIDTH-1:0]                next_auth_tag;
    reg  [CHACHA_KEY_WIDTH-1:0]                 HC_key;
    reg  [FRAMER_AUTH_WIDTH-1:0]                HC_auth_tag;

    reg                                        msg_count_inc;
    reg                                        reset_message_counterN;
    reg                                        reset_nonce_counterN;
    reg                                        nonce_count_inc;
    reg [CHACHA_NONCE_WIDTH-1:0]               nonce_counter;
    reg [STAE_BITS_WIDTH-1:0]                  state_bits;

    reg  [CHACHA_BLOCK_COUNT_WIDTH-1:0]        chacha_block_counter;

    //outputs
    reg                                        manager2slave_ready_reg;
    reg [FRAMED_DATA_WIDTH-1:0]                manager2master_encrypted_data_reg;
    reg                                        manager2master_valid_reg;
    reg                                        manager2chacha_start_reg;
    reg  [CHACHA_KEY_WIDTH-1:0]                manager2chacha_key_reg;

    localparam HARD_CODED_KEY = 256'hDEADBEEF1CEB00DA15AB1E5C0DECAFE155710C0FFEEBEEF1BADF00DCAFEBABE2;
    localparam HARD_CODED_AUTH_TAG = 8'hFE;

    localparam BLOCK_COUNTER_CONST = 32'hFADECAFE;

    initial begin
        HC_key = HARD_CODED_KEY;
        HC_auth_tag = HARD_CODED_AUTH_TAG;
        chacha_block_counter = BLOCK_COUNTER_CONST;
    end 

    assign manager2chacha_block_count = chacha_block_counter;
    assign manager2chacha_nonce = nonce_counter;

    //message counter
    counter#(
        .CNTR_WIDTH(FRAMER_CNTR_WIDTH)
    ) message_counter_inst(
        .clk(clk),
        .resetn(reset_message_counterN),
        .enable(msg_count_inc),
        .force_bit(1'b0),
        .counter(curr_msg_counter)
    );

    //nonce counter for chacha
    counter#(
        .CNTR_WIDTH(CHACHA_NONCE_WIDTH)
    ) nonce_counter_inst(
        .clk(clk),
        .resetn(reset_nonce_counterN),
        .enable(nonce_count_inc),
        .force_bit(1'b0),
        .counter(nonce_counter)
    );

    //state machine
    typedef enum logic [2:0] {
        RESET,
        IDLE,
        PREP_MSG,
        SEND_TO_CHACHA,
        SEND_TO_MASTER
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            manager2slave_ready_reg = 1'b0;
            manager2master_valid_reg = 1'b0;
            manager2chacha_start_reg = 1'b0;
            msg_count_inc = 1'b0;
            nonce_count_inc = 1'b0;
            reset_message_counterN = 1'b0;
            reset_nonce_counterN = 1'b0;
        end 
        else begin
            current_state = next_state;
            case (current_state)
                RESET: begin
                    next_state = IDLE;
                end
                IDLE: begin
                    //msg_count_inc was 1 at the end of SEND, now it gets zeroed so that the counter increments by only 1
                    msg_count_inc = 1'b0;
                    nonce_count_inc = 1'b0;
                    //tells the slave (to tell the system that the manager is ready for the next message)
                    manager2slave_ready_reg = 1'b1;
                    
                    //take counters out of reset
                    reset_message_counterN = 1'b1;
                    reset_nonce_counterN = 1'b1;

                    //move somewhere else and figure out valid ready with the master (how long to leave on?)
                    manager2master_valid_reg = 1'b0;

                    //update kex;
                    curr_key = next_key;
                    curr_auth_tag = next_auth_tag;
                    
                    //slave has a valid message, go ENCRYPT it
                    if (slave2manager_valid && manager2slave_ready) begin
                        next_state = PREP_MSG;
                        curr_plaintext_data_reg = slave2manager_plaintext_data;
                        state_bits = slave2manager_plaintext_data[1:0];
                    end

                    //no valid message yet, wait in IDLE until there is 
                    else begin
                        next_state = IDLE;
                    end
                end
                PREP_MSG: begin
                    //makes sure nonce is increaded only once when the password is changed
                    manager2slave_ready_reg = 1'b0;

                    //regular message
                    if(state_bits == 2'b00) begin
                        //state bits are already at the end of the msg
                        curr_framed_msg = {curr_auth_tag, curr_msg_counter, curr_plaintext_data_reg};
                        msg_count_inc = 1'b1;
                        manager2chacha_key_reg = curr_key;
                    end 
                    //update key (and send it to receiver as a message)
                    else begin
                        manager2chacha_key_reg = (state_bits == 2'b10) ? curr_key : HC_key;
                        curr_auth_tag = (state_bits == 2'b10) ? curr_auth_tag : HC_auth_tag;
                        curr_framed_msg = {curr_auth_tag,
                                            {(FRAMED_DATA_WIDTH-CHACHA_KEY_WIDTH-STAE_BITS_WIDTH-FRAMER_AUTH_WIDTH-FRAMER_AUTH_WIDTH-2){1'b0}}, 
                                            keygen2manager_key, keygen2manager_auth_tag, 2'b0, state_bits};
                        next_key = keygen2manager_key;
                        next_auth_tag = keygen2manager_auth_tag;
                    end 
                    next_state = SEND_TO_CHACHA;
                end
                
                SEND_TO_CHACHA: begin
                    msg_count_inc = 1'b0;
                    manager2chacha_start_reg = (chacha2manager_ready) ? 1'b1 : 1'b0;
                    manager2master_encrypted_data_reg = chacha2manager_encrypted_msg;
                    next_state = (chacha2manager_valid) ? SEND_TO_MASTER : SEND_TO_CHACHA;
                end

                SEND_TO_MASTER: begin
                    if(master2manager_ready)begin
                        manager2master_valid_reg = 1'b1;
                        next_state = IDLE;
                        nonce_count_inc = 1'b1;
                    end
                    else begin
                        next_state = SEND_TO_MASTER;
                    end 
                end
                
                default : begin
                    current_state = RESET;
                    next_state = RESET;
                end 

            endcase
        end
    end

    assign manager2slave_ready                  = manager2slave_ready_reg;
    assign manager2master_encrypted_data        = manager2master_encrypted_data_reg;
    assign manager2master_valid                 = manager2master_valid_reg;
    assign manager2keygen_HC_key                = HC_key;
    assign manager2chacha_key                   = manager2chacha_key_reg;
    assign manager2chacha_start                 = manager2chacha_start_reg;
    assign manager2chacha_framed_plaintext      = curr_framed_msg;
    
endmodule 


