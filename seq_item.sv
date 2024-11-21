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

    function void do_print(uvm_printer printer);
        super.do_print(printer);
        printer.print_field_int("TMS", tms_pad_i, 1, UVM_HEX);
        printer.print_field_int("TRST", trst_pad_i, 1, UVM_HEX);
        printer.print_field_int("TDI", tdi_pad_i, 1, UVM_HEX);
        printer.print_field_int("TDO", tdo_pad_o, 1, UVM_HEX);
        printer.print_field_int("TDO_EN", tdo_padoe_o, 1, UVM_HEX);
    endfunction

endclass
