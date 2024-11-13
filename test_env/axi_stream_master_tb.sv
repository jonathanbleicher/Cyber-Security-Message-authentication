module axi_stream_master_tb;

    // Parameters
    parameter CLK_PERIOD = 5; // Clock period in time units
    parameter RESET_PERIOD = 100; // Reset pulse width in time units
    parameter DATA_WIDTH = 512;

    // Signals
    reg clk = 0;
    reg resetN = 0;
    reg valid_input;
    reg ready_sys;
    reg [DATA_WIDTH-1:0] encrypted_data;
    wire valid;
    wire [DATA_WIDTH-1:0] data_to_sys;

    // Instantiate the axi_stream_master module
    axi_stream_master uut (
        .clk(clk),
        .resetN(resetN),
        .valid_input(valid_input),
        .ready_sys(ready_sys),
        .data_in(encrypted_data),
        .valid(valid),
        .data_out(data_to_sys)
    );

    // Clock generation
    always begin
        #CLK_PERIOD clk = ~clk;
    end

    // Reset generation
    initial begin
        resetN = 0;
        #RESET_PERIOD;
        resetN = 1;
        #RESET_PERIOD;

        // Scenario: Data transfer with valid_input and ready_sys signals

        valid_input = 1'b1;
        ready_sys = 1'b1;
        encrypted_data = 'hA5A5A5A5A5A5A5A5;

        #100;

        // Scenario: Data transfer with valid_input but not ready_sys

        valid_input = 1'b1;
        ready_sys = 1'b0;
        encrypted_data = 'h1234567890ABCDEF;

        #100; 

        valid_input = 1'b0;
        ready_sys = 1'b1;
        encrypted_data = 'hA5A5A5A5A5A5A5A5;

        #100; 

        valid_input = 1'b0;
        ready_sys = 1'b0;
        encrypted_data = 'h0000000000000000;

        #100; 

       

        $finish;
    end

endmodule
