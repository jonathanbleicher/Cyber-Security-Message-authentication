module axi_stream_slave_tb;

    // Parameters
    parameter CLK_PERIOD = 5; // Clock period in time units
    parameter RESET_PERIOD = 100; // Reset pulse width in time units
    parameter DATA_WIDTH = 512;

    // Signals
    reg clk = 0;
    reg resetN = 0;
    reg ready_internal;
    reg valid_sys;
    reg [DATA_WIDTH-1:0] data_from_sys;
    wire ready;
    wire [DATA_WIDTH-1:0] data_to_encrypt;

    // Instantiate the axi_stream_slave module
    axi_stream_slave uut (
        .clk(clk),
        .resetN(resetN),
        .ready_internal(ready_internal),
        .valid_sys(valid_sys),
        .data_in(data_from_sys),
        .ready(ready),
        .data_out(data_to_encrypt)
    );

    // Clock generation
    always begin
        #CLK_PERIOD  clk = ~clk;
    end

    // Reset generation
    initial begin
        resetN = 0;
        #RESET_PERIOD;
        resetN = 1;
        #RESET_PERIOD;
        
        // Scenario: Receiver is ready to accept data
        // In this case, data_from_sys and valid_sys are provided by the external source

        ready_internal = 1'b1;
        valid_sys = 1'b1;
        data_from_sys = 'hA5A5A5A5A5A5A5A5;

        #100;

        // Scenario: Receiver is not ready, data should not be transferred
        ready_internal = 1'b0;
        valid_sys = 1'b0;
        data_from_sys = 'hA5A5A5A5A5A5A5A5;

        #100;

        // Scenario: Receiver is ready to accept data
        ready_internal = 1'b1;
        valid_sys = 1'b0;
        data_from_sys = 'h1234567890ABCDEF;

        #100;

	ready_internal = 1'b0;
        valid_sys = 1'b1;
        data_from_sys = 'hA5A5A5A5A5A5A5A5;
	
	#100

        ready_internal = 1'b1;
        valid_sys = 1'b1;
        data_from_sys = 'h1234567890ABCDEF;

        $finish; 
    end

endmodule
