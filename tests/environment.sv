class environment extends uvm_env;
    `uvm_component_utils(environment)

    agent agnt;
    scoreboard scb;
    ref_model model;

    function new(string name = "environment", uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb   = scoreboard::type_id::create("scb", this);
        agnt  = agent::type_id::create("agnt", this);
        model = new("model", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agnt.mon.monitor_port.connect(scb.scoreboard_port);
        scb.scoreboard_ref_port.connect(model.ref_imp_port);
        model.ref_port.connect(scb.scoreboard_ref_imp);
    endfunction

endclass
