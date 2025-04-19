class test_all_test extends base_test;
    `uvm_component_utils(test_all_test)

    bypass_seq bp;
    extest_seq et;
    id_code_seq id0;
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
        ras = async_reset_seq::type_id::create("ras");
        rs  = sync_reset_seq::type_id::create("rs");

        bp.set_no_of_tr(10);
        et.set_no_of_tr(10);

        fork
            begin
                et.start(env.agnt.seqr);
            end
            begin
                bp.start(env.agnt.seqr);
            end
            begin
                id0.start(env.agnt.seqr);
            end
            begin
                ras.start(env.agnt.seqr);
            end
            begin
                rs.start(env.agnt.seqr);
            end
        join

        #20;
        phase.drop_objection(this);
    endtask

endclass
