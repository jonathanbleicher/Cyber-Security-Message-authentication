/*------------------------------------------------------------------------------
 * File          : chacha_key_expansion.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   : 
 *------------------------------------------------------------------------------*/

module chacha_key_expansion #(parameter WIDTH     = 32,  parameter KEY_WIDTH = 256, 
                              parameter OUT_WIDTH = 512, parameter NONCE_WIDTH = 96)
(
    input  logic                    clk,
    input  logic                    reset,
    input  logic                    start,
    input  logic [KEY_WIDTH-1:0]    key,
    input  logic [NONCE_WIDTH-1:0]  nonce,
    input  logic [31:0]             block_count
    output logic [OUT_WIDTH-1:0]    state_out,
);

    // Constants
    // "expand 32-byte k"
    parameter [31:0] CONSTANT_0 = 32'h61707865;
    parameter [31:0] CONSTANT_1 = 32'h3320646e;
    parameter [31:0] CONSTANT_2 = 32'h79622d32;
    parameter [31:0] CONSTANT_3 = 32'h6b206574;

    // State registers
    logic [WIDTH-1:0] state [15:0];

    // Key and nonce expansion
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset state
            for (int i = 0; i < 16; i = i + 1)
                state[i] <= '0;
        end
        else begin //maybe a start, done signal?
            // Key expansion
            /////////////////////////////////////////
            // cccccccc  cccccccc  cccccccc  cccccccc
            // kkkkkkkk  kkkkkkkk  kkkkkkkk  kkkkkkkk
            // kkkkkkkk  kkkkkkkk  kkkkkkkk  kkkkkkkk
            // bbbbbbbb  nnnnnnnn  nnnnnnnn  nnnnnnnn
            //
            // c=constant k=key b=blockcount n=nonce
            /////////////////////////////////////////

            if (start_internal && !done) begin
                state[0] <= CONSTANT_0;
                state[1] <= CONSTANT_1;
                state[2] <= CONSTANT_2;
                state[3] <= CONSTANT_3;
            
                state[4]  <= key[0:31];     
                state[5]  <= key[32:63];
                state[6]  <= key[64:95];
                state[7]  <= key[96:127];
                state[8]  <= key[128:159];
                state[9]  <= key[160:191];
                state[10] <= key[192:223];
                state[11] <= key[224:255];    
            
                state[12] <= block_count;           

                state[13] <= nonce[0:31];     
                state[14] <= nonce[32:63];   
                state[15] <= nonce[64:96];    
        
            end
        end
    end

    // Output assignment
    generate
        genvar i;
        for (i = 0; i < 16; i = i + 1)
            assign state_out[i*32] = state[i];
    endgenerate
endmodule
