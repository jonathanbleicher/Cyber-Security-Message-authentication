/*------------------------------------------------------------------------------
 * File          : axi_master.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 24, 2023
 * Description   : 
 *------------------------------------------------------------------------------*/

//manager provides message and raises send
//the packet goes into a buffer and so that the data won't be changed
//in the middle of the transaction.
//when tready goes down, the interface lowers busy to tell the 
//manager to send the next packet. 
//the manager raises the last bit when the last packet was sent.

module axi_stream_master #(parameter TDATA_WIDTH = 512,
                           parameter TID_WIDTH   = 8,
                           parameter TDEST_WIDTH = 8,
                           parameter TUSER_WIDTH = 8)
(   
    //Internal interface
    input   logic                     aclk,
    input   logic                     aresetn,
    input   logic [TDATA_WIDTH-1:0]   data_in,
    input   logic                     send,
    input   logic                     last,
    output  logic                     busy,
    output  logic                     done,
    
    //AXI interface
    input   logic                     tready,
    output  logic                     tvalid,
    output  logic [TDATA_WIDTH-1:0]   tdata,
    output  logic [TDATA_WIDTH/8-1:0] tstrb,   //might not need
    output  logic [TDATA_WIDTH/8-1:0] tkeep,   //might not need
    output  logic                     tlast,   //might not need
    output  logic [TID_WIDTH-1:0]     tid,     //might not need
    output  logic [TDEST_WIDTH-1:0]   tdest,   //might not need
    output  logic [TUSER_WIDTH-1:0]   tuser,   //might not need
    output  logic                     twakeup, //might not need
);

    logic [TDATA_WIDTH-1:0] data_buf;
    logic                   busy_buff;
    logic                   valid_buff;
    
    always_ff @(posedge aclk or posedge aresetn) begin
        if (~aresetn) begin
            tvalid <= 0;
            data_buf <= '0;
            tstrb <= '0;
            tkeep <= '0;
            tlast <= 0;
            tid <= '0;
            tdest <= '0;
            tuser <= '0;
            twakeup <= 0;

            busy <= 0;
            done <= 0;
        end
        else if(tready && valid_buff) begin
            busy <= 1;
        end 
    end 

    always_ff @(posedge send) begin
        data_buf <= data_in;
        valid_buff <= 1;
    end 

    always_ff @(negedge tready) begin
        done <= 1;
        busy <= 0;
        valid_buff <= 0;
    end 

    assign tvalid = valid_buff;

endmodule