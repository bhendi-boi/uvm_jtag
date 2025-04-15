class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    environment env;

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = environment::type_id::create("env", this);
    endfunction

endclass
