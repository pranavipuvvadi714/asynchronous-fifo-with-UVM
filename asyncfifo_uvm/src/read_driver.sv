class read_driver extends uvm_driver #(my_transaction);
`uvm_component_utils(read_driver)
virtual fifo_if.READ_MP vif;

    function new(string name = "read_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if.READ_MP) :: get(this,"","vif",vif)) begin
            `uvm_fatal(get_type_name(),"virtual interface not connected");
        end
    endfunction

    task body();
        my_transaction req;
        req = my_transaction:: type_id::create("req");
        seq_item_port.get_next_item(req);
        @(posedge vif.rclk);
        if(!vif.empty) begin
            vif.ren <= 1;
            `uvm_info(get_type_name(),$sformatf("reading data = %0h",vif.ren),UVM_LOW);
        end else begin
            vif.ren <=0;
        end
        @(posedge vif.rclk);
        vif.ren <= 0;
        seq_item_port.item_done();
    endtask

endclass





