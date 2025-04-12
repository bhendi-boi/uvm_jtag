class bypass_test extends uvm_test;
    `uvm_component_utils(bypass_test)


    environment env;
    bypass_seq  bp;

    function new(string name = "bypass_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = environment::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        bp = bypass_seq::type_id::create("bypass_seq");
        bp.set_no_of_tr(10);

        bp.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask

endclass
