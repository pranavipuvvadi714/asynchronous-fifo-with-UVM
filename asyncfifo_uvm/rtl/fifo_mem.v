module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8,
    parameter PTR_WIDTH = 3
)(
    input wclk, rclk,
    input w_rstn, r_rstn,
    input wen, ren,
    input [PTR_WIDTH:0] b_rptr, b_wptr,
    input [DATA_WIDTH-1:0] data_in,
    input full,
    input empty,
    output reg [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] fifo [DEPTH-1:0];

always @(posedge wclk) begin
    if(wen & !full) begin
        fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;
end
end

always @(posedge rclk) begin
    if(ren & !empty)begin
        data_out <= fifo[b_rptr[PTR_WIDTH-1:0]];
    end
end

endmodule
