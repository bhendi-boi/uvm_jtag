class async_reset_seq extends uvm_sequence;
    `uvm_object_utils(async_reset_seq)

    transaction tr;

    function new(string name = "async_reset_seq");
        super.new(name);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        `uvm_do_with(tr, {trst_pad_i == 1;});
    endtask

endclass

class sync_reset_seq extends uvm_sequence;
    `uvm_object_utils(sync_reset_seq)

    transaction tr;

    function new(string name = "sync_reset_seq");
        super.new(name);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        repeat (5) begin
            `uvm_do_with(tr, {tms_pad_i == 1;});
        end
    endtask

endclass
