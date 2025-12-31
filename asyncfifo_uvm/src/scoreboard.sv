class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)
    `uvm_analysis_imp_decl(_write)
    `uvm_analysis_imp_decl(_read)

    `uvm_analysis_imp_write #(my_transaction,scoreboard)item_collect_export_write;
    `uvm_analysis_imp_read #(my_transaction,scoreboard) item_collect_export_read;
    
    my_transaction q[$];

    function new(string name = "scoreboard",uvm_component parent = null);
        super.new(name,parent);
        item_collect_export_write = new("item_collect_export_write",this);
        item_collect_export_read = new("item_collect_export_read",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void write_w(my_transaction t);
        q.push_back(t);
    endfunction

    function void write_r(my_transaction t);
        if(q.size==0)
            `uvm_error("scoreboard",$sformatf("unexpected error"));
        else begin
            my_transaction sb_item = q.pop_front();
            if(sb_item.data_out != t.data_out)
                `uvm_error("scoreboard",$sformatf("error, got = %0h, exp = %0h",t.data_out, sb_item.data_out));
            else  
                `uvm_info("scoreboard",$sformatf("output check, got = %0h, exp = %0h", t.data_out,sb_item,data_out),UVM_LOW);
        end
    endfunction
endclass
            
