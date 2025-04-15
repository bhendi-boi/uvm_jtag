class rand_test extends base_test;
    `uvm_component_utils(rand_test)

    async_reset_seq ras;
    sync_reset_seq  rs;

    function new(string name = "rand_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        ras = async_reset_seq::type_id::create("ras");
        rs  = sync_reset_seq::type_id::create("rs");

        ras.start(env.agnt.seqr);

        `uvm_info("Rand Test", "Async Reset Sequence is done", UVM_NONE)
        rs.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask

endclass
