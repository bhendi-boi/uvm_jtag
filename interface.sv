interface jtag_if (
    input logic tck_pad_i
);

    logic tms_pad_i;
    logic trst_pad_i;
    logic tdi_pad_i;
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

    logic debug_tdi_i;
    logic bs_chain_tdi_i;
    logic mbist_tdi_i;

endinterface
