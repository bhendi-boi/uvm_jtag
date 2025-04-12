class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(transaction, scoreboard) scoreboard_port;

    transaction tr, comp, trs[$];
    int no_of_tr;
    bit is_sync_reset;
    bit id_code_test_complete;
    bit are_same;

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scoreboard_port = new("scoreboard_port", this);
        this.no_of_tr   = 0;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        tr = transaction::type_id::create("transaction");
        forever begin
            wait (trs.size() != 0);
            tr = trs.pop_front();

            model_tap(tr, comp, is_sync_reset, id_code_test_complete);
            are_same = tr.compare(comp);
            `uvm_info("Scoreboard", comp.convert2string(), UVM_NONE)

            if (is_sync_reset) begin
                if (!sync_reset_check(
                        tr.shift_dr_o,
                        tr.pause_dr_o,
                        tr.update_dr_o,
                        tr.capture_dr_o
                    ))
                    `uvm_info("Scoreboard", "Sync Reset Check Passed", UVM_NONE)
                else `uvm_error("Scoreboard", "Sync Reset Check Failed")
            end

            if (id_code_test_complete)
                `uvm_info("Scoreboard", "ID CODE Test Complete", UVM_NONE)

            this.no_of_tr++;
            print_info();
        end
    endtask

    function void write(transaction tr);
        trs.push_back(tr);
    endfunction


    function void print_info();
        if (are_same)
            `uvm_info("Scoreboard", $sformatf(
                      "Tr are same. Transaction No: %d \n\n ", no_of_tr),
                      UVM_NONE)
        else
            `uvm_error("Scoreboard", $sformatf(
                       "Tr are different Transaction No: %d \n\n ", no_of_tr))

    endfunction

endclass
