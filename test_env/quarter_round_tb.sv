//Done!

module tb_chacha_quarter_round;

    // Parameters
    parameter WIDTH = 32;  // Change this to match the WIDTH parameter of the module

    // Inputs
    logic [WIDTH-1:0] a_in;
    logic [WIDTH-1:0] b_in;
    logic [WIDTH-1:0] c_in;
    logic [WIDTH-1:0] d_in;

    // Outputs
    logic [WIDTH-1:0] a_out;
    logic [WIDTH-1:0] b_out;
    logic [WIDTH-1:0] c_out;
    logic [WIDTH-1:0] d_out;

    // Instantiate the module
    chacha_quarter_round #(WIDTH) uut (
        .a_in(a_in),
        .b_in(b_in),
        .c_in(c_in),
        .d_in(d_in),
        .a_out(a_out),
        .b_out(b_out),
        .c_out(c_out),
        .d_out(d_out)
    );

    // Initialize inputs
    initial begin
        a_in = 'h11111111;
        b_in = 'h01020304;
        c_in = 'h9b8d6f43;
        d_in = 'h01234567;

        // Wait for a few clock cycles
        #10;

        // Print the initial values
        $display("Initial values:");
        $display("a_in = %h, b_in = %h, c_in = %h, d_in = %h", a_in, b_in, c_in, d_in);
        $display("a_out = %h, b_out = %h, c_out = %h, d_out = %h", a_out, b_out, c_out, d_out);

        // End simulation
        $finish;
    end

endmodule
