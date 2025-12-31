class env extends uvm_env;
    `uvm_component_utils(env)
    write_agent wa;
    read_agent ra;
    scoreboard sb;

    function new(string name = "env", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wa = write_agent::type_id::create("wa",this);
        ra = read_agent::type_id::create("ra",this);
        sb = scoreboard::type_id::create("sb",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        wa.mon.item_collect_port.connect(sb.item_collect_export_write);
        ra.mon.item_collect_port.connect(sb.item_collect_export_read);
    endfunction
endclass
