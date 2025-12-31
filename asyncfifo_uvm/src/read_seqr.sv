class read_seqr extends uvm_sequencer #(my_transaction);
    `uvm_component_utils(read_seqr)

    function new(string name = "read_seqr");
        super.new(name);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

endclass
