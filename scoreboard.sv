class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp #(transaction, scoreboard) scoreboard_port;

    transaction tr;
    int no_of_tr;

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
        `uvm_info("Scoreboard", "Constructor Scoreboard", UVM_MEDIUM)
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scoreboard_port = new("scoreboard_port", this);
        this.no_of_tr   = 0;
    endfunction

    function void write(transaction tr);
        this.no_of_tr++;
        // TODO
        print_info();
    endfunction


    function print_info();
        `uvm_info("Scoreboard", $sformatf("Transaction No: %d \n\n ", no_of_tr),
                  UVM_NONE)

    endfunction

endclass
