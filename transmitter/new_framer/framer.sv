module framer (
    input logic clk,
    input logic resetN,
    input logic [511:0] data_in,
    input logic [7:0] new_msg_counter, // New values for components
    input logic [7:0] new_timer,
    input logic [7:0] new_auth_tag,
    input logic [1:0] new_state_bits,
    output logic [537:0] data_out
);

    // Registers to hold various components of the input data
    logic [7:0] msg_counter;
    logic [7:0] timer;
    logic [7:0] auth_tag;
    logic [1:0] state_bits;

    // Register for the modified output data
    logic [537:0] modified_data;

    // Flip-flops for holding the various components
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            msg_counter <= 8'b0;
        else
            msg_counter <= (new_msg_counter == 0) ? data_in[537:530] : new_msg_counter;
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            timer <= 8'b0;
        else
            timer <= (new_timer == 0) ? data_in[529:522] : new_timer;
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            auth_tag <= 8'b0;
        else
            auth_tag <= (new_auth_tag == 0) ? data_in[521:514] : new_auth_tag;
    end

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN)
            state_bits <= 2'b0;
        else
            state_bits <= (new_state_bits == 0) ? data_in[513:512] : new_state_bits;
    end

    // Combine the various components into the modified data
    always_comb begin
        modified_data = {data_in, msg_counter, timer, auth_tag, state_bits};
    end

    // Output the modified data when not resetting
    assign data_out = (resetN) ? modified_data : 538'b0;

endmodule
