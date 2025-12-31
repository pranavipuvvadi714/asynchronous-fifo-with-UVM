`include "synchronizer.v"
`include "r_ptr_handler.v"
`include "wptr_handler"
`include "fifo_mem.v"

module top_module #(
    parameter DATA_WIDTH =8,
    parameter DEPTH = 8
)(
    input wclk, rclk,
    input w_rstn, r_rstn,
    input ren, wen,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg full, empty
);

parameter PTR_WIDTH = $clog2(DEPTH);

reg [PTR_WIDTH:0] b_rptr, b_wptr;
reg [PTR_WIDTH:0] g_rptr, g_wptr;
reg [PTR_WIDTH:0] g_rptr_sync, g_wptr_sync;

synchronizer #(PTR_WIDTH) s1 (.clk(wclk), .rst(w_rstn), .d_in(g_rptr), .d_out(g_rptr_sync));
synchronizer #(PTR_WIDTH) s2 (.clk(rclk), .rst(r_rstn), .d_in(g_wptr), .d_out(g_wptr_sync));
wptr_handler #(PTR_WIDTH) w1 (.wclk(wclk), .w_rstn(w_rstn), .wen(wen), .g_rptr_sync(g_rptr_sync), .b_wptr(b_wptr), .g_wptr(g_wptr), .full(full));
rptr_handler #(PTR_WIDTH) r1 (.rclk(rclk), .r_rstn(r_rstn), .ren(ren), .g_wptr_sync(g_wptr_sync), .b_rptr(b_rptr), .g_rptr(g_rptr), .empty(empty));
fifo_mem f1 (.wclk(wclk), .rclk(rclk), .w_rstn(w_rstn), .r_rstn(r_rstn), .wen(wen), .ren(ren), .b_rptr(b_rptr), .b_wptr(b_wptr), .data_in(data_in), .full(full), .empty(empty), .data_out(data_out));

endmodule
