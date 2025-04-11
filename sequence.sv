class async_reset_seq extends uvm_sequence;
    `uvm_object_utils(async_reset_seq)

    rand transaction tr;

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

    function new(string name = "sync_reset_seq");
        super.new(name);
    endfunction

    task body();
        tr = transaction::type_id::create("tr");

        repeat (5) begin  // 5 consequtive TMS = 1 resets JTAG
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tms_pad_i == 1;
                })
                `uvm_fatal("Sync Reset Sequence", "Randomisation failed")
            finish_item(tr);
        end
    endtask

endclass

class rand_seq extends uvm_sequence;
    `uvm_object_utils(rand_seq)

    rand transaction tr;
    int no_of_tr;

    function new(string name = "rand_seq");
        super.new(name);
        this.set_no_of_tr(1);
    endfunction

    function void set_no_of_tr(int no_of_tr);
        this.no_of_tr = no_of_tr;
    endfunction

    task body();
        tr = transaction::type_id::create("tr");

        repeat (no_of_tr) begin
            start_item(tr);
            if (!tr.randomize() with {tr.trst_pad_i == 0;})
                `uvm_fatal("Rand Sequence", "Randomisation failed")
            finish_item(tr);
        end
    endtask

endclass
