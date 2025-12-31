interface fifo_if #(parameter DATA_WIDTH = 8) (input wclk, input rclk);
    //write signals
    logic w_rstn;
    logic wen;
    logic [DATA_WIDTH-1:0] data_in;
    logic full;

    //read signals
    logic r_rstn;
    logic ren;
    logic [DATA_WIDTH-1:0] data_out;
    logic empty;

    modport WRITE_MP (
        input wclk,
        input w_rstn,
        output data_in,
        output wen,
        input full
    );

    modport READ_MP (
        input rclk,
        input r_rstn,
        input data_out,
        input empty,
        output ren
    );
endinterface
