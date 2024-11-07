module framer_Test;

    logic clk;
    logic resetN;
    logic [511:0] data_in;
    logic [7:0] new_msg_counter;
    logic [7:0] new_timer;
    logic [7:0] new_auth_tag;
    logic [1:0] new_state_bits;
    logic [537:0] data_out;

    // Instantiate the module under test
    framer uut (
        .clk(clk),
        .resetN(resetN),
        .data_in(data_in),
        .new_msg_counter(new_msg_counter),
        .new_timer(new_timer),
        .new_auth_tag(new_auth_tag),
        .new_state_bits(new_state_bits),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset generation
    initial begin
        resetN = 0;
        #10 resetN = 1;
    end

    // Test stimulus
    initial begin
        // Initialize input data and new values with test values
        data_in = 512'b1010101010;
        new_msg_counter = 8'b11001100;
        new_timer = 8'b00110011;
        new_auth_tag = 8'b11110000;
        new_state_bits = 2'b10;

        // Wait for a few clock cycles
        #20;

        // Print input and output data
        $display("Input data: %h", data_in);
        $display("New msg_counter: %h", new_msg_counter);
        $display("New timer: %h", new_timer);
        $display("New auth_tag: %h", new_auth_tag);
        $display("New state_bits: %h", new_state_bits);
        $display("Output data: %h", data_out);

        // Add more test scenarios here if needed

        // Finish the simulation
        $finish;
    end

endmodule
