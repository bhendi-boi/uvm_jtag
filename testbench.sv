import uvm_pkg::*;

`include "uvm_macros.svh"
`include "model.sv"
`include "interface.sv"
`include "seq_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "rand_test.sv"
`include "reset_test.sv"


module top ();

    logic tck_pad_i;

    initial begin
        tck_pad_i = 0;
        forever #10 tck_pad_i = ~tck_pad_i;
    end

    jtag_if intf (.tck_pad_i(tck_pad_i));

    tap_top dut (
        .tms_pad_i  (intf.tms_pad_i),
        .tck_pad_i  (intf.tck_pad_i),
        .trst_pad_i (intf.trst_pad_i),
        .tdi_pad_i  (intf.tdi_pad_i),
        .tdo_pad_o  (intf.tdo_pad_o),
        .tdo_padoe_o(intf.tdo_padoe_o),

        .shift_dr_o  (intf.shift_dr_o),
        .pause_dr_o  (intf.pause_dr_o),
        .update_dr_o (intf.update_dr_o),
        .capture_dr_o(intf.capture_dr_o),

        .extest_select_o(intf.extest_select_o),
        .sample_preload_select_o(intf.sample_preload_select_o),
        .mbist_select_o(intf.mbist_select_o),
        .debug_select_o(intf.debug_select_o),

        .tdo_o(intf.tdo_o),

        .debug_tdi_i(intf.debug_tdi_i),
        .bs_chain_tdi_i(intf.bs_chain_tdi_i),
        .mbist_tdi_i(intf.mbist_tdi_i)
    );

    initial begin
        uvm_config_db#(virtual jtag_if)::set(null, "uvm_test_top*", "vif",
                                             intf);
        run_test("reset_test");
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end

endmodule
