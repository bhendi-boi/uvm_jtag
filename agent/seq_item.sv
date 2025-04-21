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

        msg = {msg, $sformatf("TDI: %d, TDO: %d ", tdi_pad_i, tdo_o)};
        msg = {
            msg,
            $sformatf("TDO_PAD: %d, TDO_PAD_EN: %d", tdo_pad_o, tdo_padoe_o)
        };

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
        if (this.shift_dr_o != comp.shift_dr_o) begin
            `uvm_info("Transaction",
                      $sformatf("tr.shift_dr_o = %d, comp.shift_dr_o = %d",
                                this.shift_dr_o, comp.shift_dr_o), UVM_DEBUG)
            return 0;
        end
        if (this.capture_dr_o != comp.capture_dr_o) begin
            `uvm_info("Transaction",
                      $sformatf("tr.capture_dr_o = %d, comp.capture_dr_o = %d",
                                this.capture_dr_o, comp.capture_dr_o),
                      UVM_DEBUG)
            return 0;
        end
        if (this.update_dr_o != comp.update_dr_o) begin
            `uvm_info("Transaction",
                      $sformatf("tr.update_dr_o = %d, comp.update_dr_o = %d",
                                this.update_dr_o, comp.update_dr_o), UVM_DEBUG)
            return 0;
        end
        if (this.tdo_o != comp.tdo_o) begin
            `uvm_info("Transaction",
                      $sformatf("tr.tdo_o = %d, comp.tdo_o = %d", this.tdo_o,
                                comp.tdo_o), UVM_DEBUG)
            return 0;
        end
        if (this.tdo_padoe_o != comp.tdo_padoe_o) begin
            `uvm_info("Transaction",
                      $sformatf("tr.tdo_padoe_o = %d, comp.tdo_padoe_o = %d",
                                this.tdo_padoe_o, comp.tdo_padoe_o), UVM_DEBUG)
            return 0;
        end
        if (this.tdo_pad_o != comp.tdo_pad_o) begin
            `uvm_info("Transaction",
                      $sformatf("tr.tdo_pad_o = %d, comp.tdo_pad_o = %d",
                                this.tdo_o, comp.tdo_o), UVM_DEBUG)
            return 0;
        end


        if (this.debug_select_o != comp.debug_select_o) begin
            `uvm_info("Transaction",
                      $sformatf(
                          "tr.debug_select_o = %d, comp.debug_select_o = %d",
                          this.debug_select_o, comp.debug_select_o), UVM_DEBUG)
            return 0;
        end
        if (this.extest_select_o != comp.extest_select_o) begin
            `uvm_info("Transaction",
                      $sformatf(
                          "tr.extest_select_o = %d, comp.extest_select_o = %d",
                          this.extest_select_o, comp.extest_select_o),
                      UVM_DEBUG)
            return 0;
        end
        if (this.sample_preload_select_o != comp.sample_preload_select_o) begin
            `uvm_info(
                "Transaction",
                $sformatf(
                    "tr.sample_preload_select_o = %d, comp.sample_preload_select_o = %d",
                    this.sample_preload_select_o, comp.sample_preload_select_o),
                UVM_DEBUG)
            return 0;
        end

        return 1;

    endfunction

endclass
