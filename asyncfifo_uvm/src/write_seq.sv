class write_seq extends uvm_sequence #(my_transaction);
    `uvm_object_utils(write_seq)
    my_transaction req;

    function new(string name = "write_seq");
        super.new(name);
    endfunction

    task body();
        req = my_transaction::type_id::create("req");
        wait_for_grant();
        assert(req.randomize());
        send_request(req);
        wait_for_item_done();
    endtask
endclass

