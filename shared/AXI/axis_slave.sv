/*------------------------------------------------------------------------------
 * File          : axi_slave.sv
 * Project       : RTL
 * Author        : epjoed
 * Creation date : May 23, 2023
 * Description   : 
 *------------------------------------------------------------------------------*/


module axi_stream_slave #(parameter TDATA_WIDTH = 512,
                          parameter TID_WIDTH   = 8,
                          parameter TDEST_WIDTH = 8,
                          parameter TUSER_WIDTH = 8)
(   
    //Internal interface
    input   logic                     aclk,
    input   logic                     aresetn,
    input   logic                     ready,

    output  logic [TDATA_WIDTH-1:0]   data_out,
    output  logic                     valid,
    
    //AXI interface
    input   logic                     tvalid,
    input   logic [TDATA_WIDTH-1:0]   tdata,
    input   logic [TDATA_WIDTH/8-1:0] tstrb,   //might not need
    input   logic [TDATA_WIDTH/8-1:0] tkeep,   //might not need
    input   logic                     tlast,   //might not need
    input   logic [TID_WIDTH-1:0]     tid,     //might not need
    input   logic [TDEST_WIDTH-1:0]   tdest,   //might not need
    input   logic [TUSER_WIDTH-1:0]   tuser,   //might not need
    input   logic                     twakeup, //might not need
    output  logic                     tready
);

    logic [TDATA_WIDTH-1:0] data_buff;
    
    always_ff @(posedge aclk or posedge aresetn) begin
        if (~aresetn) begin
            data_buff <= '0;
            valid <= '0;

        end
        else begin
            if(ready & tvalid)begin
                data_buff <= tdata;
            end

        end 
    end 

    always @(data_buff) begin //at any change of data_buff
        if(aresetn) begin //to avoid driving 1 and zero during reset
            valid <= 1;
        end 
    end 

    always_ff @(negedge ready) begin
       valid <= 0;
    end 

    assign data_out = data_buff;
    assign tready = ready;
endmodule