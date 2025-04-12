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

class sample_prelaod_seq extends uvm_sequence;
    `uvm_object_utils(sample_prelaod_seq)

    rand transaction tr;
    int no_of_tr;

    // 5 1's for bringing TAP to reset
    // Next 5 for bringing TAP to SHIFT_IR
    // Next 2 to keep the TAP in SHIFT_IR
    bit setup_with_tms[] = {1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1};
    rand bit setup_with_tdi[$];

    constraint setup_ir_to_0001 {
        setup_with_tdi.size() == 14;
        setup_with_tdi[10] == 0;
        setup_with_tdi[11] == 0;
    }

    function new(string name = "sample_prelaod_seq");
        super.new(name);
        if (!randomize(setup_with_tdi))
            `uvm_fatal("Sample Preload Sequence", "TDI randomization failed")
        `uvm_info("TDI", $sformatf("Randomized TDI: %p", setup_with_tdi),
                  UVM_HIGH)
        this.set_no_of_tr(1);
    endfunction

    function void set_no_of_tr(int no_of_tr);
        this.no_of_tr = no_of_tr;
    endfunction

    task body();
        tr = transaction::type_id::create("tr");

        foreach (setup_with_tms[i]) begin
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tms_pad_i == setup_with_tms[i];
                    tr.tdi_pad_i == setup_with_tdi[i];
                })
                `uvm_fatal("Sample Preload Sequence", "Randomisation failed")
            finish_item(tr);

        end
        // repeat (no_of_tr) begin
        //     start_item(tr);
        //     if (!tr.randomize() with {tr.trst_pad_i == 0;})
        //         `uvm_fatal("Sample Preload Sequence", "Randomisation failed")
        //     finish_item(tr);
        // end
    endtask

endclass


class id_code_seq extends uvm_sequence;
    `uvm_object_utils(id_code_seq)

    rand transaction tr;
    int no_of_tr;

    // 5 1's for bringing TAP to reset
    // Next 5 for bringing TAP to SHIFT_IR
    // Next 1 to keep the TAP in SHIFT_IR
    bit setup_with_tms[] = {1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0};
    rand bit setup_with_tdi[$];

    constraint setup_ir_to_0010 {
        setup_with_tdi.size() == 15;
        setup_with_tdi[10] == 0;
    }

    function new(string name = "id_code_seq");
        super.new(name);
        if (!randomize(setup_with_tdi))
            `uvm_fatal("ID Code Sequence", "TDI randomization failed")
        `uvm_info("TDI", $sformatf("Randomized TDI: %p", setup_with_tdi),
                  UVM_HIGH)
        this.set_no_of_tr(32);
    endfunction

    function void set_no_of_tr(int no_of_tr);
        this.no_of_tr = no_of_tr;
    endfunction

    task body();
        tr = transaction::type_id::create("tr");

        foreach (setup_with_tms[i]) begin
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tms_pad_i == setup_with_tms[i];
                    tr.tdi_pad_i == setup_with_tdi[i];
                })
                `uvm_fatal("ID Code Sequence", "Randomisation failed")
            finish_item(tr);

        end

        // extracting ID_CODE
        repeat (no_of_tr) begin
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tms_pad_i == 0;  // Keeping TAP in ShiftDR State
                })
                `uvm_fatal("ID Code Sequence", "Randomisation failed")
            finish_item(tr);
        end
    endtask

endclass

class extest_seq extends uvm_sequence;
    `uvm_object_utils(extest_seq)

    rand transaction tr;
    int no_of_tr;

    // 5 1's for bringing TAP to reset
    // Next 5 for bringing TAP to SHIFT_IR
    // Next 2 to keep the TAP in SHIFT_IR
    bit setup_with_tms[] = {1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0};
    rand bit setup_with_tdi[$];

    constraint setup_ir_to_0010 {
        setup_with_tdi.size() == 15;
        setup_with_tdi[10] == 0;
        setup_with_tdi[11] == 0;
        setup_with_tdi[12] == 0;
    }

    function new(string name = "extest_seq");
        super.new(name);
        if (!randomize(setup_with_tdi))
            `uvm_fatal("EXTEST Sequence", "TDI randomization failed")
        `uvm_info("TDI", $sformatf("Randomized TDI: %p", setup_with_tdi),
                  UVM_HIGH)
        this.set_no_of_tr(32);
    endfunction

    function void set_no_of_tr(int no_of_tr);
        this.no_of_tr = no_of_tr;
    endfunction

    task body();
        tr = transaction::type_id::create("tr");

        foreach (setup_with_tms[i]) begin
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tms_pad_i == setup_with_tms[i];
                    tr.tdi_pad_i == setup_with_tdi[i];
                })
                `uvm_fatal("EXTEST Sequence", "Randomisation failed")
            finish_item(tr);

        end

        // extracting ID_CODE
        repeat (no_of_tr) begin
            start_item(tr);
            if (!tr.randomize() with {
                    tr.trst_pad_i == 0;
                    tr.tms_pad_i == 0;  // Keeping TAP in IDLE State
                })
                `uvm_fatal("EXTEST Sequence", "Randomisation failed")
            finish_item(tr);
        end
    endtask

endclass
