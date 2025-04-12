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
        forever begin
            capture(tr);
            `uvm_info("Monitor", "Sampled a transaction", UVM_NONE)
            `uvm_info("Monitor", tr.convert2string(), UVM_NONE)
            monitor_port.write(tr);
        end
    endtask

    task capture(transaction tr);
        @(posedge vif.tck_pad_i);
        @(posedge vif.tck_pad_i);
        tr.tms_pad_i = vif.tms_pad_i;
        tr.trst_pad_i = vif.trst_pad_i;
        tr.tdi_pad_i = vif.tdi_pad_i;
        tr.tdo_o = vif.tdo_o;
        tr.tdo_pad_o = vif.tdo_pad_o;
        tr.tdo_padoe_o = vif.tdo_padoe_o;
        tr.shift_dr_o = vif.shift_dr_o;
        tr.update_dr_o = vif.update_dr_o;
        tr.capture_dr_o = vif.capture_dr_o;
        tr.pause_dr_o = vif.pause_dr_o;
    endtask

endclass
