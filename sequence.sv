class async_reset_seq extends uvm_sequence;
    `uvm_object_utils(async_reset_seq)

    rand transaction tr;

    constraint reset {tr.trst_pad_i == 1;}

    function new(string name = "async_reset_seq");
        super.new(name);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");
        start_item(tr);
        if (!tr.randomize() with {tr.trst_pad_i == 1;})
            `uvm_fatal("Async Reset Sequence", "Randomisation failed")
        finish_item(tr);
    endtask

endclass

class sync_reset_seq extends uvm_sequence;
    `uvm_object_utils(sync_reset_seq)

    rand transaction tr;

    constraint trst_is_off {tr.trst_pad_i == 0;}
    constraint tdi_is_1 {tr.tdi_pad_i == 1;}

    function new(string name = "sync_reset_seq");
        super.new(name);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");

        repeat (5) begin  // 5 consequtive TDI = 1 resets JTAG
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tdi_pad_i == 1;
                })
                `uvm_fatal("Async Reset Sequence", "Randomisation failed")
            finish_item(tr);
        end
    endtask

endclass
