module receiver_manager #(
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

        //Global

        //local
        parameter STAE_BITS_WIDTH = 2

    
)(
    input wire clk,
    input wire resetN,

    //AXI slave 
    input  wire [FRAMED_DATA_WIDTH-1:0]      slave2manager_cyphertext,
    input  wire                              slave2manager_valid,
    output wire                              manager2slave_ready,

    //AXI master
    input wire                               master2manager_ready,
    output wire [PLAINTEXT_WIDTH-1:0]        manager2master_plaintext,
    output wire                              manager2master_valid,
    
    //Chacha
    input  wire [FRAMED_DATA_WIDTH-1:0]      chacha2manager_decrypted_msg,
    input  wire                              chacha2manager_valid,
    input  wire                              chacha2manager_ready,
    output wire [CHACHA_KEY_WIDTH-1:0]       manager2chacha_key,
    output wire [CHACHA_NONCE_WIDTH-1:0]     manager2chacha_nonce,
    output wire                              manager2chacha_start,
    output wire [FRAMED_DATA_WIDTH-1:0]      manager2chacha_framed_cyphertext,
    output wire [CHACHA_BLOCK_COUNT_WIDTH-1:0] manager2chacha_block_count

);

    //internal signals and registers
    
    //for concatenation
    wire [PLAINTEXT_WIDTH-1:0]                plaintext_temp;
    wire [FRAMER_AUTH_WIDTH-1:0]              auth_tag_temp;
    wire [FRAMER_CNTR_WIDTH-1:0]              counter_temp;

    reg [PLAINTEXT_WIDTH-1:0]                 plaintext_reg;
    reg [FRAMED_DATA_WIDTH-1:0]              framed_plaintext_reg;
    reg [FRAMED_DATA_WIDTH-1:0]              framed_cyphertext_reg;
    reg [FRAMER_AUTH_WIDTH-1:0]               auth_tag_reg;
    reg [FRAMER_CNTR_WIDTH-1:0]               counter_reg;
    reg [STAE_BITS_WIDTH-1:0]                 state_bits_reg;

    reg [FRAMER_CNTR_WIDTH-1:0]                curr_msg_counter;
    reg  [FRAMER_AUTH_WIDTH-1:0]               curr_auth_tag;
    reg  [CHACHA_KEY_WIDTH-1:0]                curr_key;

    reg  [CHACHA_KEY_WIDTH-1:0]                 next_key;
    reg  [FRAMER_AUTH_WIDTH-1:0]                next_auth_tag;
    reg  [CHACHA_KEY_WIDTH-1:0]                 HC_key;
    reg  [FRAMER_AUTH_WIDTH-1:0]                HC_auth_tag;

    reg                                        reset_nonce_counterN;
    reg                                        nonce_count_inc;
    reg [CHACHA_NONCE_WIDTH-1:0]               nonce_counter;

    reg  [CHACHA_BLOCK_COUNT_WIDTH-1:0]        chacha_block_counter;

    //outputs
    reg                                        manager2slave_ready_reg;
    reg [PLAINTEXT_WIDTH-1:0]                  manager2master_plaintext_reg;
    reg                                        manager2master_valid_reg;
    reg                                        manager2chacha_start_reg;
    reg                                        key_fail_flag;
    reg                                        counter_fail_flag;

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
    assign framed_plaintext_reg = chacha2manager_decrypted_msg;
    assign {auth_tag_temp, counter_temp, plaintext_temp} = framed_plaintext_reg;

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
        START_DECRYPT,
        FINISH_DECRYPT,
        AUTHENTICATE,
        SEND_TO_MASTER
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            manager2slave_ready_reg = 1'b0;
            manager2master_valid_reg = 1'b0;
            manager2chacha_start_reg = 1'b0;
            nonce_count_inc = 1'b0;
            reset_nonce_counterN = 1'b0;
            key_fail_flag = 1'b0;
            counter_fail_flag = 1'b0;
            curr_msg_counter = 0;
        end 
        else begin
            current_state = next_state;
            case (current_state)
                RESET: begin
                    next_state = IDLE;
                    next_key = HC_key;
                    next_auth_tag = HC_auth_tag;
                end
                IDLE: begin
                    //tells the slave (to tell the system that the manager is ready for the next message)
                    manager2slave_ready_reg = 1'b1;
                    
                    //take counters out of reset
                    reset_nonce_counterN = 1'b1;
                    nonce_count_inc = 1'b0;

                    //move somewhere else and figure out valid ready with the master (how long to leave on?)
                    manager2master_valid_reg = 1'b0;

                    //update kex;
                    curr_key = next_key;
                    curr_auth_tag = next_auth_tag;
                    
                    //slave has a valid message, go ENCRYPT it
                    if (slave2manager_valid && manager2slave_ready) begin
                        next_state = START_DECRYPT;
                        framed_cyphertext_reg = slave2manager_cyphertext;
                    end

                    //no valid message yet, wait in IDLE until there is 
                    else begin
                        next_state = IDLE;
                    end
                end
                START_DECRYPT: begin
                    if(chacha2manager_ready) begin
                        manager2chacha_start_reg = 1'b1;
                        next_state = FINISH_DECRYPT;
                    end 
                    else begin
                        next_state = START_DECRYPT;
                    end
                end
                FINISH_DECRYPT: begin
                    manager2chacha_start_reg = 1'b0;
                    if(chacha2manager_valid) begin
                        auth_tag_reg = auth_tag_temp;
                        counter_reg = counter_temp;
                        plaintext_reg = plaintext_temp;
                        state_bits_reg = plaintext_temp[STAE_BITS_WIDTH-1:0];
                        next_state = AUTHENTICATE;
                        if(auth_tag_reg == curr_auth_tag && state_bits_reg[1] == 1'b1)begin
                            next_auth_tag = framed_plaintext_reg[11:4]; //TODO parameterize
                            next_key = framed_plaintext_reg[267:12]; //TODO parameterize
                            next_state = SEND_TO_MASTER;
                        end 
                    end 
                    else begin
                        next_state = FINISH_DECRYPT;
                    end
                end
                AUTHENTICATE: begin
                    //auth tag mismatch, go back and try again with HC_KEY
                    if(auth_tag_reg != curr_auth_tag)begin
                        curr_key = HC_key;
                        curr_auth_tag = HC_auth_tag;
                        //HC_key failed
                        if(key_fail_flag)begin
                            next_state = SEND_TO_MASTER;
                        end
                        else begin
                            key_fail_flag = 1'b1;
                            next_state = START_DECRYPT;
                        end 
                    end 
                    else begin
                        key_fail_flag = 1'b0;
                        //regular message or sent again
                        if(state_bits_reg[1] == 1'b0)begin
                            if(counter_reg != curr_msg_counter)begin
                                counter_fail_flag = 1'b1;
                            end
                            else begin
                                curr_msg_counter = curr_msg_counter + 1;
                            end
                            next_state = SEND_TO_MASTER;
                        end
                    end 
                end     
                SEND_TO_MASTER: begin
                    if(master2manager_ready)begin
                        manager2master_valid_reg = 1'b1;
			nonce_count_inc = 1'b1;
                        next_state = IDLE;
                        if(key_fail_flag)begin
                            manager2master_plaintext_reg =  {{(PLAINTEXT_WIDTH-STAE_BITS_WIDTH){1'b0}}, {2'b11}};
                            next_key = HC_key;
                            next_auth_tag = HC_auth_tag;
                        end 
                        else if(state_bits_reg[1] == 1'b1)begin
                            manager2master_plaintext_reg = 2'b10;
                        end 
                        else begin
                            manager2master_plaintext_reg = plaintext_reg;
                        end                        
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
    assign manager2master_plaintext             = manager2master_plaintext_reg;
    assign manager2master_valid                 = manager2master_valid_reg;
    assign manager2chacha_key                   = curr_key;
    assign manager2chacha_start                 = manager2chacha_start_reg;
    assign manager2chacha_framed_cyphertext     = framed_cyphertext_reg;
    
endmodule 


