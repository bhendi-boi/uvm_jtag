class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    transaction tr;
    virtual jtag_if vif;
    uvm_analysis_port #(transaction) monitor_port;

    function new(string name = "monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor_port = new("monitor_port", this);
        if (!uvm_config_db#(virtual jtag_if)::get(this, "*", "vif", vif)) begin
            `uvm_fatal("Monitor", "Couldn't get the interface")
        end
    endfunction

    task run_phase(uvm_phase phase);
        tr = transaction::type_id::create("tr");
        @(posedge vif.tck_pad_i);
        // the above line ensures monitor and driver are in sync
        forever begin
            capture(tr);
            `uvm_info("Monitor", "Sampled a transaction", UVM_NONE)
            tr.print();
            monitor_port.write(tr);
        end
    endtask

    task capture(transaction tr);
        //    TODO: Add capture code
    endtask

endclass
