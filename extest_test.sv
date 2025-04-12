class extest_test extends uvm_test;
    `uvm_component_utils(extest_test)

    environment env;
    extest_seq  et;

    function new(string name = "extest_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = environment::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        et = extest_seq::type_id::create("extest_seq");
        et.set_no_of_tr(10);

        et.start(env.agnt.seqr);

        #20;
        phase.drop_objection(this);
    endtask
endclass
