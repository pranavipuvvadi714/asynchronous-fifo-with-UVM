class write_driver extends uvm_driver #(my_transaction);
    `uvm_component_utils(write_driver)
    virtual fifo_if.WRITE_MP vif;

    function new(string name = "write_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if.WRITE_MP)::get(this,"","vif",vif)) begin
            `uvm_fatal (get_type_name(),"virtual interface was not set");
        end
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            my_transaction req;
            req = my_transaction::type_id::create("req");
            seq_item_port.get_next_item(req);
            @(posedge.wclk);
            if(!vif.full) begin
                vif.wen <= 1;
                vif.data_in <= req.data_in;
                `uvm_info(get_type_name, $sformatf("writing: %0h",req.data_in),UVM_LOW);
            end else 
                vif.wen <= 0;
            @(posedge vif.wclk)
                vif.wen <=0;
            seq_item_port.item_done();
        end
    endtask
endclass
