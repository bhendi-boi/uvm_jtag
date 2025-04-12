typedef transaction;
task model_tap(input transaction tr, output transaction comp,
               output bit is_sync_reset, output bit id_code_test_complete);

    enum bit [3:0] {
        TEST_LOGIC_RESET = 0,
        IDLE = 1,
        SELECT_DR = 2,
        CAPTURE_DR = 3,
        SHIFT_DR = 4,
        EXIT_1_DR = 5,
        PAUSE_DR = 6,
        EXIT_2_DR = 7,
        UPDATE_DR = 8,
        SELECT_IR = 9,
        CAPTURE_IR = 10,
        SHIFT_IR = 11,
        EXIT_1_IR = 12,
        PAUSE_IR = 13,
        EXIT_2_IR = 14,
        UPDATE_IR = 15
    } TAP_STATE;

    // Supported Instructions
    `define EXTEST 4'b0000
    `define SAMPLE_PRELOAD 4'b0001
    `define IDCODE 4'b0010
    `define DEBUG 4'b1000
    `define MBIST 4'b1001
    `define BYPASS 4'b1111

    // captial one is used for deciding output
    // small one is temp variable which is copied to capital one
    // when UPDATE_IR is asserted
    static bit [3:0] IR_REG, ir_reg;
    static
    bit [31:0]
    id_code_value = 32'h149511c3;  // TODO: Should not be static. 
    static int id_code_reg_index;  // variable used to move bit by bit
    static int tms_count = 0;
    static bit bypass_reg;

    comp = transaction::type_id::create("transaction_comp");

    `uvm_info("Model_SV",
              $sformatf("Current State = %s, TMS = %d, IR_REG = %0x",
                        TAP_STATE.name(), tr.tms_pad_i, IR_REG), UVM_HIGH)


    comp.tms_pad_i = tr.tms_pad_i;
    comp.trst_pad_i = tr.trst_pad_i;
    comp.tdi_pad_i = tr.tdi_pad_i;
    comp.bs_chain_tdi_i = tr.bs_chain_tdi_i;
    comp.debug_tdi_i = tr.debug_tdi_i;
    comp.mbist_tdi_i = tr.mbist_tdi_i;

    comp.shift_dr_o = 0;
    comp.capture_dr_o = 0;
    comp.update_dr_o = 0;
    comp.pause_dr_o = 0;

    comp.tdo_o = tr.tdi_pad_i;
    comp.tdo_pad_o = 0;

    fork
        begin
            begin
                // Debug statements for DR Assertion
                if (TAP_STATE == CAPTURE_DR) begin
                    `uvm_info("Model_SV", "Capture DR asserted", UVM_HIGH)
                    comp.capture_dr_o = 1;
                end
                if (TAP_STATE == SHIFT_DR) begin
                    `uvm_info("Model_SV", "Shift DR asserted", UVM_HIGH)
                    comp.shift_dr_o = 1;
                end
                if (TAP_STATE == UPDATE_DR) begin
                    `uvm_info("Model_SV", "UPDATE DR asserted", UVM_HIGH)
                    comp.update_dr_o = 1;
                end
                if (TAP_STATE == PAUSE_DR) begin
                    `uvm_info("Model_SV", "PAUSE DR asserted", UVM_HIGH)
                    comp.pause_dr_o = 1;
                end

                if (TAP_STATE == TEST_LOGIC_RESET) begin
                    ir_reg = 0;
                    IR_REG = `IDCODE; // Don't get fooled by line 374; Take a look at line 447 in design.
                    bypass_reg = 0;
                end

                if (IR_REG == `IDCODE) begin
                    comp.tdo_pad_o = id_code_value;
                end

                // Debug statements for IR Assertion
                if (TAP_STATE == CAPTURE_IR) begin
                    `uvm_info("Model_SV", "Capture IR asserted", UVM_HIGH)
                end
                if (TAP_STATE == SHIFT_IR) begin
                    `uvm_info("Model_SV", "Shift IR asserted", UVM_HIGH)
                end
                if (TAP_STATE == UPDATE_IR) begin
                    `uvm_info("Model_SV", "UPDATE IR asserted", UVM_HIGH)
                end
                if (TAP_STATE == PAUSE_IR) begin
                    `uvm_info("Model_SV", "PAUSE IR asserted", UVM_HIGH)
                end

                if (TAP_STATE == IDLE) begin
                    if (IR_REG == `EXTEST) begin
                        `uvm_info("Model_SV", "EXTEST Detected", UVM_HIGH)
                        comp.tdo_pad_o = tr.bs_chain_tdi_i;
                    end
                end
                if (TAP_STATE == CAPTURE_IR) begin
                    ir_reg = 4'b0101;
                end

                if (TAP_STATE == SHIFT_IR) begin
                    comp.tdo_pad_o = ir_reg[0];
                    ir_reg = {tr.tdi_pad_i, ir_reg[3:1]};
                end

                if (TAP_STATE == UPDATE_IR) begin
                    IR_REG = ir_reg;
                end
                if (TAP_STATE == SHIFT_DR) begin
                    if (IR_REG == `IDCODE) begin
                        comp.tdo_pad_o = id_code_value[id_code_reg_index];
                        id_code_test_complete = id_code_reg_index == 31 ? 1 : 0;
                        id_code_reg_index = (id_code_reg_index + 1) % 32;
                    end
                    if (IR_REG == `BYPASS) begin
                        comp.tdo_pad_o = bypass_reg;
                        `uvm_info("Model_SV", "Bypass Detected", UVM_HIGH)
                    end
                    // added this statement here so that bypass_reg lags a cycle
                    bypass_reg = comp.tdi_pad_i;
                end

            end
            // FSM LOGIC
            begin
                if (tr.trst_pad_i) begin
                    TAP_STATE = TEST_LOGIC_RESET;
                end else begin
                    if (TAP_STATE == TEST_LOGIC_RESET) begin
                        if (tr.tms_pad_i) TAP_STATE <= TEST_LOGIC_RESET;
                        else TAP_STATE <= IDLE;
                    end else if (TAP_STATE == IDLE) begin
                        if (tr.tms_pad_i) TAP_STATE <= SELECT_DR;
                        else TAP_STATE <= IDLE;
                    end else if (TAP_STATE == SELECT_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= SELECT_IR;
                        else TAP_STATE <= CAPTURE_DR;
                    end else if (TAP_STATE == CAPTURE_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= EXIT_1_DR;
                        else TAP_STATE <= SHIFT_DR;
                    end else if (TAP_STATE == SHIFT_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= EXIT_1_DR;
                        else TAP_STATE <= SHIFT_DR;
                    end else if (TAP_STATE == EXIT_1_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= UPDATE_DR;
                        else TAP_STATE <= PAUSE_DR;
                    end else if (TAP_STATE == PAUSE_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= EXIT_2_DR;
                        else TAP_STATE <= PAUSE_DR;
                    end else if (TAP_STATE == EXIT_2_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= UPDATE_DR;
                        else TAP_STATE <= SHIFT_DR;
                    end else if (TAP_STATE == UPDATE_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= SELECT_DR;
                        else TAP_STATE <= IDLE;
                    end else if (TAP_STATE == SELECT_IR) begin
                        if (tr.tms_pad_i) TAP_STATE <= TEST_LOGIC_RESET;
                        else TAP_STATE <= CAPTURE_IR;
                    end else if (TAP_STATE == CAPTURE_IR) begin
                        if (tr.tms_pad_i) TAP_STATE <= EXIT_1_IR;
                        else TAP_STATE <= SHIFT_IR;
                    end else if (TAP_STATE == SHIFT_IR) begin
                        if (tr.tms_pad_i) TAP_STATE <= EXIT_1_IR;
                        else TAP_STATE <= SHIFT_IR;
                    end else if (TAP_STATE == EXIT_1_IR) begin
                        if (tr.tms_pad_i) TAP_STATE <= UPDATE_IR;
                        else TAP_STATE <= PAUSE_IR;
                    end else if (TAP_STATE == PAUSE_IR) begin
                        if (tr.tms_pad_i) TAP_STATE <= EXIT_2_IR;
                        else TAP_STATE <= PAUSE_IR;
                    end else if (TAP_STATE == EXIT_2_DR) begin
                        if (tr.tms_pad_i) TAP_STATE <= UPDATE_IR;
                        else TAP_STATE <= SHIFT_IR;
                    end else begin
                        if (tr.tms_pad_i) TAP_STATE <= SELECT_DR;
                        else TAP_STATE <= IDLE;
                    end
                end
            end

        end
    join
    // Sync Reset Detection (TMS = 1 for 5 consecutive cycles)
    if (tr.trst_pad_i) begin
        tms_count = 0;
    end else begin
        if (tms_count == 4) begin
            `uvm_info("Model_SV", "Sync Reset Detected", UVM_HIGH)
            tms_count = 0;
            is_sync_reset = 1;
        end else begin
            is_sync_reset = 0;
            if (tr.tms_pad_i) tms_count++;
            else tms_count = 0;
        end
    end

endtask


function bit sync_reset_check(input bit shift_dr, input bit pause_dr,
                              input bit update_dr, input bit capture_dr);

    bit [3:0] temp;
    temp = {shift_dr, pause_dr, update_dr, capture_dr};
    if (temp == 4'b0000) return 0;
    else return 1;

endfunction
