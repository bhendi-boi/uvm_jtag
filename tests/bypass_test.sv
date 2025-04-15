class bypass_test extends base_test;
    `uvm_component_utils(bypass_test)

    bypass_seq bp;

    function new(string name = "bypass_test", uvm_component parent);
        super.new(name, parent);
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
