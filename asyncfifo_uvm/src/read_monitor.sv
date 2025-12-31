class read_monitor extends uvm_monitor #(my_transaction);
`uvm_component_utils(read_monitor)
virtual fifo_if.READ_MP vif;
uvm_analysis_port #(my_transaction) item_collect_port;

    function new(string name = "read_monito", uvm_component parent = null);
        super.new(name,parent);
        item_collect_port = new("item_collect_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if.READ_MP)::get(this,"","vif",vif)) begin
            `uvm_fatal(get_type_name(),"virtual interface is not connected");
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            my_transaction req;
            req = my_transaction::type_id::create("req");
            @(posedge vif.rclk);
            if(vif.ren & !empty) begin
                req.data_out <= vif.data_out;
                item_collect_port.write(req);
            end
        end
    endtask
endclass 
