class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(transaction, scoreboard) scoreboard_port;

    transaction tr, comp;
    int no_of_tr;
    bit is_sync_reset;
    bit are_same;

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scoreboard_port = new("scoreboard_port", this);
        this.no_of_tr   = 0;
    endfunction

    function void write(transaction tr);
        this.no_of_tr++;
        model_tap(tr, comp, is_sync_reset);
        are_same = tr.compare(comp);
        if (are_same) `uvm_info("Scoreboard", "Tr are same", UVM_NONE)
        else `uvm_error("Scoreboard", "Tr are different")

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



        print_info();
    endfunction


    function void print_info();
        `uvm_info("Scoreboard", $sformatf("Transaction No: %d \n\n ", no_of_tr),
                  UVM_NONE)

    endfunction

endclass
