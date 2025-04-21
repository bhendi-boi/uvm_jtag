class debug_test extends base_test;
    `uvm_component_utils(debug_test)

    debug_seq dbg;

    function new(string name = "debug_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        dbg = debug_seq::type_id::create("debug_seq");
        dbg.set_no_of_tr(10);

        dbg.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask

endclass
