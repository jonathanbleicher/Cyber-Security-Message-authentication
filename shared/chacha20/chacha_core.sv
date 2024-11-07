/*------------------------------------------------------------------------------
 * File          : chacha_core.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   :
 *------------------------------------------------------------------------------*/

module chacha_core #(parameter WIDTH     = 32,  parameter ROUNDS      = 20,
                     parameter KEY_WIDTH = 256, parameter NONCE_WIDTH = 96,
                     parameter OUT_WIDTH = 512)
(
    input  logic                    clk,
    input  logic                    reset,
    input  logic [KEY_WIDTH-1:0]    key,
    input  logic [NONCE_WIDTH-1:0]  nonce,
    input  logic                    start,
    output logic [OUT_WIDTH-1:0]    state_out
);
    //local signals
    logic [OUT_WIDTH-1:0]    state;
    logic [OUT_WIDTH-1:0]    state0;
    logic [OUT_WIDTH-1:0]    state1;
    logic [31:0]             block_count

    // instantiate the counter module
    chacha_counter counter (
        .clk(clk),
        .reset(reset),
        .enable(start),
        .counter(block_count)
    );

    // instantiate the key expansion
    chacha_key_expansion expansion (
        .clk(clk),
        .reset(reset),
        .key(key),
        .nonce(nonce),
        .block_count(block_count),
        .state_out(state),
    );

    // instantiate the quarter rounds

    //stage 0
    //QUARTERROUND( x0, x4, x8, x12)
    chacha_quarter_round q_0_0 (
        .a_in(state[32*0: (32*1)-1]),    //x0
        .b_in(state[32*4 : (32*5)-1]),   //x4
        .c_in(state[32*8 : (32*9)-1]),   //x8
        .d_in(state[32*12 : (32*13)-1]), //x12
        .a_out(state0[32*0: (32*1)-1]),   //x0
        .b_out(state0[32*4 : (32*5)-1]),  //x4
        .c_out(state0[32*8 : (32*9)-1]),  //x8
        .d_out(state0[32*12 : (32*13)-1]) //x12
    );

    //QUARTERROUND( x1, x5, x9, x13)
    chacha_quarter_round q_0_1 (
        .a_in(state[32*1: (32*2)-1]),    //x1
        .b_in(state[32*5 : (32*6)-1]),   //x5
        .c_in(state[32*9 : (32*10)-1]),  //x9
        .d_in(state[32*13 : (32*14)-1]), //x13
        .a_out(state0[32*1: (32*2)-1]),   //x1
        .b_out(state0[32*5 : (32*6)-1]),  //x5
        .c_out(state0[32*9 : (32*10)-1]), //x9
        .d_out(state0[32*13 : (32*14)-1]) //x13
    );

    //QUARTERROUND( x2, x6, x10, x14)
    chacha_quarter_round q_0_2 (
        .a_in(state[32*2: (32*3)-1]),      //x2
        .b_in(state[32*6 : (32*7)-1]),     //x6
        .c_in(state[32*10 : (32*11)-1]),   //x10
        .d_in(state[32*14 : (32*15)-1]),   //x14
        .a_out(state0[32*2: (32*3)-1]),    //x2
        .b_out(state0[32*6 : (32*7)-1]),   //x6
        .c_out(state0[32*10 : (32*11)-1]), //x10
        .d_out(state0[32*14 : (32*15)-1])  //x14
    );

    //QUARTERROUND( x3, x7, x11, x15)
    chacha_quarter_round q_0_3 (
        .a_in(state[32*3: (32*4)-1]),      //x3
        .b_in(state[32*7 : (32*8)-1]),     //x7
        .c_in(state[32*11 : (32*12)-1]),   //x11
        .d_in(state[32*15 : (32*16)-1]),   //x15
        .a_out(state0[32*3: (32*4)-1]),    //x3
        .b_out(state0[32*7 : (32*8)-1]),   //x7
        .c_out(state0[32*11 : (32*12)-1]), //x11
        .d_out(state0[32*15 : (32*16)-1])  //x15
    );

    //stage 1
    //QUARTERROUND( x0, x5, x10, x15)
    chacha_quarter_round q_1_0 (
        .a_in(state[32*0: (32*1)-1]),      //x0
        .b_in(state[32*5 : (32*6)-1]),     //x5
        .c_in(state[32*10 : (32*11)-1]),   //x10
        .d_in(state[32*15 : (32*16)-1]),   //x15
        .a_out(state0[32*0: (32*1)-1]),    //x0
        .b_out(state0[32*5 : (32*6)-1]),   //x5
        .c_out(state0[32*10 : (32*11)-1]), //x10
        .d_out(state0[32*15 : (32*16)-1])  //x15
    );

    //QUARTERROUND( x1, x6, x11, x12)
    chacha_quarter_round q_1_1 (
        .a_in(state[32*1: (32*2)-1]),      //x1
        .b_in(state[32*6 : (32*7)-1]),     //x6
        .c_in(state[32*11 : (32*12)-1]),   //x11
        .d_in(state[32*12 : (32*13)-1]),   //x12
        .a_out(state0[32*1: (32*2)-1]),    //x1
        .b_out(state0[32*6 : (32*7)-1]),   //x6
        .c_out(state0[32*11 : (32*12)-1]), //x11
        .d_out(state0[32*12 : (32*13)-1])  //x12
    );

    //QUARTERROUND( x2, x7, x8, x13)
    chacha_quarter_round q_1_2 (
        .a_in(state[32*2: (32*3)-1]),     //x2
        .b_in(state[32*7 : (32*8)-1]),    //x7
        .c_in(state[32*8 : (32*9)-1]),    //x8
        .d_in(state[32*13 : (32*14)-1]),  //x13
        .a_out(state0[32*2: (32*3)-1]),   //x2
        .b_out(state0[32*7 : (32*8)-1]),  //x7
        .c_out(state0[32*8 : (32*9)-1]),  //x8
        .d_out(state0[32*13 : (32*14)-1]) //x13
    );

    //QUARTERROUND( x3, x4, x9, x14)
    chacha_quarter_round q_1_3 (
        .a_in(state[32*3: (32*4)-1]),     //x3
        .b_in(state[32*4 : (32*5)-1]),    //x4
        .c_in(state[32*9 : (32*10)-1]),   //x9
        .d_in(state[32*14 : (32*15)-1]),  //x14
        .a_out(state0[32*3: (32*4)-1]),   //x3
        .b_out(state0[32*4 : (32*5)-1]),  //x4
        .c_out(state0[32*9 : (32*10)-1]), //x9
        .d_out(state0[32*14 : (32*15)-1]) //x14
    );



endmodule
