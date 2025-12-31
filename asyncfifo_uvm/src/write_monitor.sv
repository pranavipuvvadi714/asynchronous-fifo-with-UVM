class write_monitor extends uvm_monitor #(my_transaction);
`uvm_component_utils(write_monitor)
virtual fifo_if.WRITE_MP vif;
uvm_analysis_port #(my_transaction) item_collect_port;

    function new(string name = "write_monitor", uvm_component parent = null);
        super.new(name,parent);
        item_collect_port = new("item_collect_this",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if.WRITE_MP)::get(this,"",vif,"vif")) begin
            `uvm_fatal(get_type_name,"virtual interface not connected");
            end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            my_transaction seq;
            seq = my_transaction::type_id::create("req");
            @(posedge vif.wclk);
            if(vif.wen & !full) begin
                seq.data_in = vif.data_in;
                item_collect_port.write(seq);
            end
        end
    endtask
endclass 

