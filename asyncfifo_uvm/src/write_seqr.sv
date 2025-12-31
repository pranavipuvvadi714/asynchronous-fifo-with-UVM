class write_seqr extends uvm_sequencer #(my_transaction);
    `uvm_component_utils (write_seqr)

    function new(string name = "write_seqr");
        super.new(name);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

endclass
