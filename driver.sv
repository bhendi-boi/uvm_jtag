class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)

    transaction tr;
    virtual jtag_if vif;

    function new(string name = "driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual jtag_if)::get(this, "*", "vif", vif)) begin
            `uvm_fatal("Driver", "Couldn't access interface")
        end
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        tr = transaction::type_id::create("tr");

        forever begin
            seq_item_port.get_next_item(tr);
            drive(tr);
            `uvm_info("Driver", "Drove a transaction", UVM_NONE)
            tr.print();
            seq_item_port.item_done();
        end
    endtask

    task drive(transaction tr);
        // ! TODO
    endtask

endclass
