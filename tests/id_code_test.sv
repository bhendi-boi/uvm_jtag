class id_code_test extends base_test;
    `uvm_component_utils(id_code_test)

    id_code_seq id0;


    function new(string name = "id_code_test", uvm_component parent);
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        id0 = id_code_seq::type_id::create("id_code_seq");

        id0.start(env.agnt.seqr);

        #40;
        phase.drop_objection(this);
    endtask



endclass
