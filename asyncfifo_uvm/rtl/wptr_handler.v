module wptr_handler #(PTR_WIDTH = 3) (
    input wclk,
    input w_rstn,
    input wen,
    input [PTR_WIDTH:0] g_rptr_sync,
    output reg [PTR_WIDTH :0] b_wptr,
    output reg [PTR_WIDTH:0] g_wptr,
    output reg full
    );

    wire [PTR_WIDTH :0] g_wptr_next;
    wire [PTR_WIDTH :0] b_wptr_next;
    wire w_full_cond;

    assign b_wptr_next = b_wptr + (w_en &(!full));
    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

    assign w_full_cond = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH],~g_rptr_sync[PTR_WIDTH-1],g_rptr_sync[PTR_WIDTH-2:0]})

    always @(posedge wclk or negedge w_rstn) begin
        if(!w_rstn) begin
            full <= 0;
            g_wptr <= 0;
            b_wptr <= 0;
        end else begin
            
            g_wptr <= g_wptr_next;
            b_wptr <= b_wptr_next;
        end
        full <= (wen& !full)?w_full_cond:full;
    end

endmodule



