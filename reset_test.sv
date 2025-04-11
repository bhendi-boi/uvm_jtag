class reset_test extends uvm_test;
    `uvm_component_utils(reset_test)

    environment env;
    async_reset_seq ras;
    sync_reset_seq rs;

    function new(string name = "reset_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = environment::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        ras = async_reset_seq::type_id::create("ras");
        rs  = sync_reset_seq::type_id::create("rs");

        ras.start(env.agnt.seqr);
        rs.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask

endclass
