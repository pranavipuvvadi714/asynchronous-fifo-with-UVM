`include "uvm_macros.svh"   
import uvm_pkg::*;
import top_module::*;

`include "../src/fifo_if.sv"
`include "../src/base_test.sv"
module uvm_top;
    logic wclk =0, rclk=0;
    logic w_rstn =0, r_rstn =0;

    fifo_if fifo0 (wclk, rclk);
    top_module dut(
        .wclk(fifo0.wclk),
        .rclk(fifo0.rclk),
        .w_rstn(fifo0.w_rstn),
        .r_rstn(fifo0.r_rstn),
        .data_in(fifo0.data_in),
        .wen(fifo0.wen),
        .ren(fifo0.ren),
        .data_out(fifo0.data_out),
        .full(fifo0.full),
        .empty(fifo0.empty)
    );

    always #5 wclk = ~wclk;
    always #7 rclk = ~rclk;

    initial begin
        fifo0.w_rstn=0;
        fifo0.r_rstn = 0;
        #50;
        fifo0.w_rstn=1;
        fifo0.r_rstn =1;
    end

    initial begin
        uvm_config_db #(virtual fifo_if.WRITE_MP) ::set(null, "env_h.w_agt.*", "vif", fifo0);
        uvm_config_db #(virtual fifo_if.READ_MP) ::set(null, "env_h.w_agt.*", "vif", fifo0);
        run_test("test");
    end
endmodule
