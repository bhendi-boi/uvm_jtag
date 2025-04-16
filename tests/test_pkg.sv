`include "../agent/agent_pkg.sv"

package test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import agent_pkg::*;

    `include "../model.sv"
    `include "scoreboard.sv"
    `include "ref_model.sv"
    `include "environment.sv"

    `include "base_test.sv"
    `include "reset_test.sv"
    `include "id_code_test.sv"
    `include "extest_test.sv"
    `include "bypass_test.sv"
    `include "sample_preload_test.sv"
    `include "rand_test.sv"

endpackage
