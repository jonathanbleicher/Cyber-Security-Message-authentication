module key_generator #(
  parameter KEY_WIDTH = 256,
  parameter AUTH_TAG_WIDTH = 8
)
(
  input wire clk,
  input wire resetN,
  input wire [KEY_WIDTH-1:0] HC_key,
  output wire [KEY_WIDTH-1:0] random_bits_key,
  output wire [AUTH_TAG_WIDTH-1:0] random_bits_auth_tag
);

  reg [KEY_WIDTH-1:0] lfsr_state;
  reg [KEY_WIDTH-1:0] lfsr_state_temp;
  reg [AUTH_TAG_WIDTH-1:0] auth_tag;

  
	assign lfsr_state_temp = HC_key;

  always_ff @(posedge clk or negedge resetN) begin
    if (~resetN) begin
      // Reset the LFSR state on active-low reset
      lfsr_state <= lfsr_state_temp;
    end else begin
      // Update the LFSR state on each clock edge when enabled
      lfsr_state[63:0] <= { lfsr_state[62:0], lfsr_state[0] ^ lfsr_state[3] ^ lfsr_state[7] ^ lfsr_state[15] ^ lfsr_state[20] ^lfsr_state[50] };
      lfsr_state[127:64] <= { lfsr_state[126:64], lfsr_state[64] ^ lfsr_state[67] ^ lfsr_state[70] ^ lfsr_state[82] ^ lfsr_state[90] ^lfsr_state[100] };
      lfsr_state[191:128] <= { lfsr_state[190:128], lfsr_state[128] ^ lfsr_state[131] ^ lfsr_state[140] ^ lfsr_state[155] ^ lfsr_state[170] ^lfsr_state[182] };
      lfsr_state[255:192] <= { lfsr_state[254:192], lfsr_state[192] ^ lfsr_state[195] ^ lfsr_state[200] ^ lfsr_state[220] ^ lfsr_state[230] ^lfsr_state[237] };
      auth_tag = {lfsr_state[10], lfsr_state[31], lfsr_state[47], lfsr_state[81],
                  lfsr_state[189], lfsr_state[201], lfsr_state[235], lfsr_state[250]};

    end
  end

  assign random_bits_key = lfsr_state;
  assign random_bits_auth_tag = auth_tag;

endmodule
