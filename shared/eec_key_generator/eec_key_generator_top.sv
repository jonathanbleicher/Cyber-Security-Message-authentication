/*------------------------------------------------------------------------------
 * File          : eec_key_generator_top.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 24, 2023
 * Description   :
 *------------------------------------------------------------------------------*/

//find out what the curve parameters are
module eec_key_generator_top #(parameter ECC_CurveType = "P256") 
(
  input  logic clk,
  input  logic rst,
  input  logic [255:0] random_seed,
  input  logic [255:0] received_public_key,
  output logic [255:0] private_key
);

  // Internal signals
  logic [255:0] generated_public_key;

  // ECC key generation process
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      generated_public_key <= '0;
      private_key <= '0;
    end else begin
      // Generate public key from the random seed
      // Use your ECC library or implement the ECC algorithm here
      // Example usage: generated_public_key = ECC_GeneratePublicKey(random_seed, ECC_CurveType);
      // Replace ECC_GeneratePublicKey with the appropriate function or implementation
    end
  end

  // Private key generation process
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      private_key <= '0;
    end else begin
      // Generate private key from the received public key
      // Use your ECC library or implement the ECC algorithm here
      // Example usage: private_key = ECC_GeneratePrivateKey(received_public_key, random_seed, ECC_CurveType);
      // Replace ECC_GeneratePrivateKey with the appropriate function or implementation
    end
  end

endmodule
