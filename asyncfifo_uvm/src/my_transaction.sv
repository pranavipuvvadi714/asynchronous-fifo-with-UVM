`include "uvm_macros.svh"
import uvm_pkg::*;

class my_transaction extends uvm_sequence_item;
    rand bit ren;
    rand bit wen;
    rand bit [7:0] data_in;
    bit [7:0] data_out;

    `uvm_object_utils_begin(my_transaction)
        `uvm_field_int(ren)
        `uvm_field_int(wen)
        `uvm_field_int(data_in)
        `uvm_field_int(data_out)
    `uvm_object_utils_end

    constraint c1 {data_in inside {[1:255];}}

    function new(string name = "my_transaction");
        super.new(name);
    endfunction

endclass
