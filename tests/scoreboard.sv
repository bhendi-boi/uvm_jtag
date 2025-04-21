`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_ref)
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp_mon #(transaction, scoreboard) scoreboard_port;
    uvm_analysis_imp_ref #(transaction, scoreboard) scoreboard_ref_imp;
    uvm_analysis_port #(transaction) scoreboard_ref_port;

    transaction tr, comp, trs[$], comps[$];
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
        scoreboard_ref_port = new("scoreboard_ref_port", this);
        scoreboard_ref_imp = new("scoreboard_ref_imp", this);
        this.no_of_tr = 0;
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        tr = transaction::type_id::create("transaction");
        forever begin
            wait (trs.size() != 0);
            tr = trs.pop_front();

            wait (comps.size() != 0);
            comp = comps.pop_front();
            `uvm_info("Scoreboard Ref Model", comp.convert2string(), UVM_NONE)
            are_same = tr.compare(comp);

            this.no_of_tr++;
            print_info();
        end
    endtask

    function void write_mon(transaction tr);
        trs.push_back(tr);
        scoreboard_ref_port.write(tr);
    endfunction

    function void write_ref(transaction tr);
        comps.push_back(tr);
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
