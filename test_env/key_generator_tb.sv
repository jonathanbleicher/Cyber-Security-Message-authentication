module key_generator_tb;

  reg clk;
  reg resetN;
  reg [255:0] HC_key;
  wire [255:0] random_bits_key;
  wire [7:0] random_bits_auth_tag;

  // Instantiate the key_generator module
  key_generator #(256, 8) random_gen (
    .clk(clk),
    .resetN(resetN),
    .HC_key(HC_key),
    .random_bits_key(random_bits_key),
    .random_bits_auth_tag(random_bits_auth_tag)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Initial block
  initial begin
    // Initialize inputs
    clk = 0;
    resetN = 0;
    HC_key = 256'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;

    // Apply a reset
    resetN = 0;
    #10 resetN = 1;

    // Run the simulation for some cycles
    #100;

    // Display the results
    $display("HC_key = %h", HC_key);
    $display("Random Bits Key = %h", random_bits_key);
    $display("Random Bits Auth Tag = %h", random_bits_auth_tag);

    // End the simulation
    $stop;
  end

endmodule
