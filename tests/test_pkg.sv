package test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "../apb/apb_pkg.sv"
    import apb_pkg::*;

    `include "scoreboard.sv"
    `include "environment.sv"

    `include "base_test.sv"
    `include "reset_test.sv"
    `include "id_code_test.sv"
    `include "extest_test.sv"
    `include "bypass_test.sv"
    `include "sample_preload_test.sv"
    `include "rand_test.sv"

endpackage
