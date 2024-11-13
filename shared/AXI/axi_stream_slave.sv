module axi_stream_slave #(
	parameter DATA_WIDTH = 512
)(
    input wire clk,
    input wire resetN,
    input wire ready_internal,//the inside ready not the systems ready
    input wire valid_sys,
    input wire [DATA_WIDTH-1:0] data_in,
    output wire ready,
	output wire valid,
    output wire [DATA_WIDTH-1:0] data_out
);

    // Internal signals
    reg [DATA_WIDTH-1:0] data_internal;
    logic ready_temp;
    logic valid_temp;

    always_ff @(posedge clk or negedge resetN) begin

    	if (!resetN) begin
        	valid_temp <= 'b0; // Reset data to 0
	    end 
		else begin
			if (ready_internal) begin
				ready_temp <= 1'b1;
			end else begin
				ready_temp <= 1'b0;
			end
			if (valid_sys) begin
				valid_temp <= 1'b1;
			end else begin
				valid_temp <=0'b0;
			end
			if (ready & valid_temp) begin
				data_internal <= data_in;
			end 
		end
     end

    assign data_out = data_in;
    assign ready = ready_temp;
	assign valid = valid_temp;
	
endmodule
