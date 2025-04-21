class test_all_test extends base_test;
    `uvm_component_utils(test_all_test)

    bypass_seq bp;
    extest_seq et;
    id_code_seq id0;
    debug_seq dbg;
    sample_prelaod_seq sp0;
    async_reset_seq ras;
    sync_reset_seq rs;

    function new(string name = "test_all_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        bp  = bypass_seq::type_id::create("bypass_seq");
        et  = extest_seq::type_id::create("extest_seq");
        id0 = id_code_seq::type_id::create("id_code_seq");
        dbg = debug_seq::type_id::create("debug_seq");
        sp0 = sample_prelaod_seq::type_id::create("sample_prelaod_seq");
        ras = async_reset_seq::type_id::create("ras");
        rs  = sync_reset_seq::type_id::create("rs");


        bp.set_no_of_tr(50);
        et.set_no_of_tr(50);
        dbg.set_no_of_tr(50);
        sp0.set_no_of_tr(50);


        ras.start(env.agnt.seqr);
        rs.start(env.agnt.seqr);

        et.start(env.agnt.seqr);
        `uvm_info("Test all Test", "Extest Sequence is done", UVM_NONE)

        bp.start(env.agnt.seqr);
        `uvm_info("Test all Test", "Bypass Sequence is done", UVM_NONE)

        id0.start(env.agnt.seqr);
        `uvm_info("Test all Test", "Idcode Sequence is done", UVM_NONE)


        dbg.start(env.agnt.seqr);
        `uvm_info("Test all Test", "Debug Sequence is done", UVM_NONE)

        sp0.start(env.agnt.seqr);
        `uvm_info("Test all Test", "Sample Preload Sequence is done", UVM_NONE)


        #20;
        phase.drop_objection(this);
    endtask

endclass
