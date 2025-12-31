class test extends uvm_test;
    `uvm_component_utils(test)
    env env_o;
    read_seq r_seq;
    write_seq w_seq;

    function new(string name = "test", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        env_o = env::type_id::create("env",this);
        
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        r_seq = read_seq::type_id::create("r_seq");
        w_seq = write_seq::type_id::create("w_seq");

        fork
            r_seq.start(env_o.ra.seqr);
            w_seq.start(env_o.wa.seqr);
        join

        phase.drop_objection(this);
    endtask

endclass

