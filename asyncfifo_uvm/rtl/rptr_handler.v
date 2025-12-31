module rptr_handler #(PTR_WIDTH = 3)(
    input rclk,
    input r_rstn,
    input ren,
    input [PTR_WIDTH:0] g_wptr_sync,
    output reg [PTR_WIDTH:0] b_rptr,
    output reg [PTR_WIDTH:0] g_rptr,
    output reg empty
);

reg [PTR_WIDTH:0] b_rptr_next;
reg [PTR_WIDTH:0] g_rptr_next;
reg [PTR_WIDTH:0] r_empty;

assign b_rptr_next = b_rptr +(ren&(!empty));
assign g_rptr_next = (b_rptr_next >>1) ^ b_rptr_next;
assign r_empty = (g_wptr_sync==g_rptr_next);

always @(posedge rclk or negedge r_rstn) begin
    if(!r_rstn) begin
        empty <=1;
        b_rptr_next<=0;
        g_rptr_next <=0;
    end else begin
       
        b_rptr <= b_rptr_next;
        g_rptr <= g_rptr_next;
    end
    empty <= (ren&!empty)?r_empty:empty;

end
endmodule


