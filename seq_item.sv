class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    // inputs
    rand logic tms_pad_i;
    rand logic trst_pad_i;
    rand logic tdi_pad_i;
    rand logic debug_tdi_i;
    rand logic bs_chain_tdi_i;
    rand logic mbist_tdi_i;

    // outputs
    logic tdo_pad_o;
    logic tdo_padoe_o;

    logic shift_dr_o;
    logic pause_dr_o;
    logic update_dr_o;
    logic capture_dr_o;

    logic extest_select_o;
    logic sample_preload_select_o;
    logic mbist_select_o;
    logic debug_select_o;

    logic tdo_o;

    function new(string name = "transaction");
        super.new(name);
    endfunction

    // function void do_print(uvm_printer printer);
    //     super.do_print(printer);
    //     printer.print_field_int("TMS", tms_pad_i, 1, UVM_HEX);
    //     printer.print_field_int("TRST", trst_pad_i, 1, UVM_HEX);
    //     printer.print_field_int("TDI", tdi_pad_i, 1, UVM_HEX);
    //     printer.print_field_int("TDO", tdo_pad_o, 1, UVM_HEX);
    //     printer.print_field_int("TDO_EN", tdo_padoe_o, 1, UVM_HEX);
    // endfunction

    function string convert2string();
        string msg = $sformatf("TMS: %d, TRST: %d, ", tms_pad_i, trst_pad_i);

        msg = {msg, $sformatf("TDI: %d, ", tdi_pad_i)};
        msg = {msg, $sformatf("TDO: %d, TDO_EN: %d", tdo_pad_o, tdo_padoe_o)};

        return msg;
    endfunction

    function bit compare(transaction comp);
        // inputs
        if (this.tms_pad_i != comp.tms_pad_i) return 0;
        if (this.trst_pad_i != comp.trst_pad_i) return 0;
        if (this.tdi_pad_i != comp.tdi_pad_i) return 0;
        if (this.debug_tdi_i != comp.debug_tdi_i) return 0;
        if (this.bs_chain_tdi_i != comp.bs_chain_tdi_i) return 0;
        if (this.mbist_tdi_i != comp.mbist_tdi_i) return 0;

        // only checking for fields which are used
        if (this.shift_dr_o != comp.shift_dr_o) return 0;
        if (this.capture_dr_o != comp.capture_dr_o) return 0;
        if (this.update_dr_o != comp.update_dr_o) return 0;
        if (this.tdo_o != comp.tdo_o) return 0;
        if (this.tdo_padoe_o != comp.tdo_padoe_o) return 0;
        if (this.tdo_pad_o != comp.tdo_pad_o) return 0;

        return 1;

    endfunction

endclass
