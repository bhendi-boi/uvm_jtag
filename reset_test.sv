class reset_test extends base_test;
    `uvm_component_utils(reset_test)

    async_reset_seq ras;
    rand_seq r0;
    sync_reset_seq rs;

    function new(string name = "reset_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        ras = async_reset_seq::type_id::create("ras");
        rs  = sync_reset_seq::type_id::create("rs");
        r0  = rand_seq::type_id::create("rand_seq");
        r0.set_no_of_tr(10);


        ras.start(env.agnt.seqr);
        r0.start(env.agnt.seqr);
        rs.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask

endclass
