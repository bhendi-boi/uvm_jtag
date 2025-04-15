class sample_preload_test extends base_test;
    `uvm_component_utils(sample_preload_test)

    sample_prelaod_seq sp0;


    function new(string name = "sample_preload_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        sp0 = sample_prelaod_seq::type_id::create("sample_prelaod_seq");

        sp0.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask



endclass
