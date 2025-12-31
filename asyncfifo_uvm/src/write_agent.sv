class write_agent extends uvm_agent #(my_transaction);
    `uvm_component_utils(write_agent)
    write_driver drv;
    write_seqr seqr;
    write_monitor mon;

    function new(string name = "write_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(get_is_active()==UVM_ACTIVE) begin
            drv = write_driver::type_id::create("drv",this);
            seqr = write_seqr::type_id::create("seqr",this);
        end
        mon = write_monitor::type_id::create("mon",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        if(get_is_active()==UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass
        