class rand_test extends uvm_test;
    `uvm_component_utils(rand_test)

    environment env;
    sync_reset_seq rs;

    function new(string name = "rand_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = environment::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        rs = sync_reset_seq::type_id::create("rs");

        rs.start(env.agnt.seqr);

        #100;
        phase.drop_objection(this);
    endtask

endclass
