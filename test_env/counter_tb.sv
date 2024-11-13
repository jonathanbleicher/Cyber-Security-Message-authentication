module counter_tb;

    // Parameters
    localparam CNTR_WIDTH = 32;
    
    // Signals
    logic clk;
    logic resetn;
    logic enable;
    logic force_bit;
    logic [CNTR_WIDTH-1:0] force_value;
    logic [CNTR_WIDTH-1:0] counter;

    // Instantiate counter module
    counter #(
        .CNTR_WIDTH(CNTR_WIDTH)
    ) dut (
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .force_bit(force_bit),
        .force_value(force_value),
        .counter(counter)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimuli
    initial begin
        resetn = 0;
        enable = 0;
        force_bit = 0;
        force_value = 0;

        // Reset sequence
        #10 resetn = 1;
		
        // Test with enable but no force
        enable = 1;
        
		#50

        // Test with force value
        force_bit = 1;
        force_value = 5;
	
		#20
		
		force_bit = 0;
		//force a wrap around
		force_value = (1 << (CNTR_WIDTH)) - 2; // Set close to max value
		
		#20
		
		force_bit = 1;
		
		#20
		force_bit = 0;
        #5000;
        $finish;
    end

endmodule
