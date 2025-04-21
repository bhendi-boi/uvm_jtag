class ref_model extends uvm_component;
    `uvm_component_utils(ref_model)

    uvm_analysis_imp #(transaction, ref_model) ref_imp_port;
    uvm_analysis_port #(transaction) ref_port;
    transaction tr, trs[$], comp;

    function new(string name = "ref_model", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ref_port = new("ref_port", this);
        ref_imp_port = new("ref_imp_port", this);
    endfunction

    function void write(transaction t);
        trs.push_back(t);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        tr   = transaction::type_id::create("tr");
        comp = transaction::type_id::create("comp");

        forever begin
            wait (trs.size() != 0);
            tr = trs.pop_front();
            `uvm_info("Ref Model", $sformatf(
                      "Prev State = %s, TMS = %d, IR_REG = %d",
                      tap_state.name(),
                      tr.tms_pad_i,
                      this.IR_REG
                      ), UVM_LOW)

            this.prev_tap_state = this.tap_state;
            compute_current_state(tr.trst_pad_i, tr.tms_pad_i);
            `uvm_info(
                "Ref Model", $sformatf(
                "Current State = %s, IR_REG = %d", tap_state.name(), this.IR_REG
                ), UVM_LOW)

            this.is_sync_reset =
                check_for_sync_reset(tr.trst_pad_i, tr.tms_pad_i);
            if (this.is_sync_reset)
                `uvm_info("Ref Model", "Sync Reset Detected", UVM_HIGH)

            update_input_vars_in_comp();
            reset_output_vars_in_comp();

            reset_update();
            add_assert_statements_and_update_outputs();
            check_for_bypass(tr.tdi_pad_i);
            check_for_extest();
            check_for_id_code();
            check_for_debug();
            check_for_sample_preload();
            updates_to_ir_reg(tr.tdi_pad_i);

            if (this.id_code_test_complete)
                `uvm_info("Ref Model", "ID CODE Test Complete", UVM_LOW)
            ref_port.write(comp);


        end
    endtask


    typedef enum bit [3:0] {
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

    TAP_STATE tap_state, prev_tap_state;

    int tms_count;  // used to check for sync reset.
    bit is_sync_reset;  // asserted when sync reset is detected
    bit id_code_test_complete;

    // Supported Instructions
    `define EXTEST 4'b0000
    `define SAMPLE_PRELOAD 4'b0001
    `define IDCODE 4'b0010
    `define DEBUG 4'b1000
    `define MBIST 4'b1001
    `define BYPASS 4'b1111

    bit [3:0] IR_REG, ir_reg;

    bit [31:0] id_code_value = 32'h149511c3;
    int id_code_reg_index;  // variable used to move bit by bit
    bit bypass_reg;  // lags tdi by a cycle

    function void check_for_id_code();
        if (IR_REG == `IDCODE) begin
            this.comp.tdo_pad_o = 1'b1;
        end
        if (this.tap_state == SHIFT_DR) begin
            if (IR_REG == `IDCODE) begin
                this.comp.tdo_pad_o = this.id_code_value[this.id_code_reg_index];
                this.id_code_test_complete = this.id_code_reg_index == 31 ? 1 : 0;
                this.id_code_reg_index = (this.id_code_reg_index + 1) % 32;
            end
        end
    endfunction

    function void check_for_bypass(input bit tdi);
        if (this.tap_state == SHIFT_DR) begin
            if (this.IR_REG == `BYPASS) begin
                comp.tdo_pad_o = bypass_reg;
                `uvm_info("Ref Model", "Bypass Detected", UVM_HIGH)
            end
            // added this statement here so that bypass_reg lags a cycle
            bypass_reg = tdi;
        end
    endfunction

    function bit check_for_sync_reset(input bit trst, input bit tms);
        if (trst) begin
            this.tms_count = 0;
        end else begin
            if (this.tms_count == 4) begin
                tms_count = 0;
                return 1;
            end
            if (tr.tms_pad_i) tms_count++;
            else tms_count = 0;
            return 0;
        end
    endfunction

    function void reset_update();
        if (this.tap_state == TEST_LOGIC_RESET) begin
            ir_reg = 0;
            IR_REG = `IDCODE; // Don't get fooled by line 374; Take a look at line 447 in design.
            bypass_reg = 0;
        end
    endfunction

    function void check_for_extest();
        if (this.tap_state == IDLE) begin
            if (IR_REG == `EXTEST) begin
                `uvm_info("Ref Model", "EXTEST Detected", UVM_HIGH)
                comp.tdo_pad_o = tr.bs_chain_tdi_i;
            end
        end
        if (IR_REG == `EXTEST) begin
            comp.extest_select_o = tr.extest_select_o;
        end
    endfunction

    function void check_for_debug();
        if (this.tap_state == IDLE) begin
            if (IR_REG == `DEBUG) begin
                `uvm_info("Ref Model", "DEBUG Detected", UVM_HIGH)
                comp.tdo_pad_o = tr.debug_tdi_i;
                comp.debug_select_o = 1'b1;
            end
        end
    endfunction

    function void check_for_sample_preload();
        if (this.tap_state == IDLE) begin
            if (IR_REG == `SAMPLE_PRELOAD) begin
                `uvm_info("Ref Model", "SAMPLE_PRELOAD Detected", UVM_HIGH)
                comp.tdo_pad_o = tr.bs_chain_tdi_i;
                comp.sample_preload_select_o = 1'b1;
            end
        end
    endfunction

    function void updates_to_ir_reg(input bit tdi);
        if (this.prev_tap_state == CAPTURE_IR) begin
            this.ir_reg = 4'b0101;
            `uvm_info("Ref Model", $sformatf("Changing ir to %b", this.ir_reg),
                      UVM_LOW)
        end

        if (this.prev_tap_state == SHIFT_IR) begin
            this.comp.tdo_pad_o = this.ir_reg[0];
            this.ir_reg = {tdi, this.ir_reg[3:1]};
            `uvm_info("Ref Model", $sformatf("Changing ir to %b", this.ir_reg),
                      UVM_LOW)
        end

        if (this.prev_tap_state == UPDATE_IR) begin
            this.IR_REG = this.ir_reg;
        end
    endfunction

    function void add_assert_statements_and_update_outputs();

        // using prev_state as ref model is not lagged by a cycle
        if (this.tap_state == CAPTURE_DR)
            `uvm_info("Ref Model", "Capture DR asserted", UVM_HIGH)
        if (this.prev_tap_state == CAPTURE_DR) comp.capture_dr_o = 1;

        if (this.tap_state == SHIFT_DR)
            `uvm_info("Ref Model", "Shift DR asserted", UVM_HIGH)
        if (this.prev_tap_state == SHIFT_DR) comp.shift_dr_o = 1;

        if (this.tap_state == UPDATE_DR)
            `uvm_info("Ref Model", "UPDATE DR asserted", UVM_HIGH)
        if (this.prev_tap_state == UPDATE_DR) comp.update_dr_o = 1;

        if (this.tap_state == PAUSE_DR)
            `uvm_info("Ref Model", "PAUSE DR asserted", UVM_HIGH)
        if (this.prev_tap_state == PAUSE_DR) comp.pause_dr_o = 1;

        if (this.tap_state == CAPTURE_IR)
            `uvm_info("Ref Model", "Capture IR asserted", UVM_HIGH)

        if (this.tap_state == SHIFT_IR)
            `uvm_info("Ref Model", "Shift IR asserted", UVM_HIGH)

        if (this.tap_state == UPDATE_IR)
            `uvm_info("Ref Model", "UPDATE IR asserted", UVM_HIGH)

        if (this.tap_state == PAUSE_IR)
            `uvm_info("Ref Model", "PAUSE IR asserted", UVM_HIGH)

    endfunction

    function void compute_current_state(input bit trst, input bit tms);
        if (trst) begin
            this.tap_state = TEST_LOGIC_RESET;
        end else begin
            if (this.tap_state == TEST_LOGIC_RESET) begin
                if (tms) this.tap_state = TEST_LOGIC_RESET;
                else this.tap_state = IDLE;
            end else if (this.tap_state == IDLE) begin
                if (tms) this.tap_state = SELECT_DR;
                else this.tap_state = IDLE;
            end else if (this.tap_state == SELECT_DR) begin
                if (tms) this.tap_state = SELECT_IR;
                else this.tap_state = CAPTURE_DR;
            end else if (this.tap_state == CAPTURE_DR) begin
                if (tms) this.tap_state = EXIT_1_DR;
                else this.tap_state = SHIFT_DR;
            end else if (this.tap_state == SHIFT_DR) begin
                if (tms) this.tap_state = EXIT_1_DR;
                else this.tap_state = SHIFT_DR;
            end else if (this.tap_state == EXIT_1_DR) begin
                if (tms) this.tap_state = UPDATE_DR;
                else this.tap_state = PAUSE_DR;
            end else if (this.tap_state == PAUSE_DR) begin
                if (tms) this.tap_state = EXIT_2_DR;
                else this.tap_state = PAUSE_DR;
            end else if (this.tap_state == EXIT_2_DR) begin
                if (tms) this.tap_state = UPDATE_DR;
                else this.tap_state = SHIFT_DR;
            end else if (this.tap_state == UPDATE_DR) begin
                if (tms) this.tap_state = SELECT_DR;
                else this.tap_state = IDLE;
            end else if (this.tap_state == SELECT_IR) begin
                if (tms) this.tap_state = TEST_LOGIC_RESET;
                else this.tap_state = CAPTURE_IR;
            end else if (this.tap_state == CAPTURE_IR) begin
                if (tms) this.tap_state = EXIT_1_IR;
                else this.tap_state = SHIFT_IR;
            end else if (this.tap_state == SHIFT_IR) begin
                if (tms) this.tap_state = EXIT_1_IR;
                else this.tap_state = SHIFT_IR;
            end else if (this.tap_state == EXIT_1_IR) begin
                if (tms) this.tap_state = UPDATE_IR;
                else this.tap_state = PAUSE_IR;
            end else if (this.tap_state == PAUSE_IR) begin
                if (tms) this.tap_state = EXIT_2_IR;
                else this.tap_state = PAUSE_IR;
            end else if (this.tap_state == EXIT_2_DR) begin
                if (tms) this.tap_state = UPDATE_IR;
                else this.tap_state = SHIFT_IR;
            end else begin
                if (tms) this.tap_state = SELECT_DR;
                else this.tap_state = IDLE;
            end
        end
    endfunction

    function void update_input_vars_in_comp();
        this.comp.tms_pad_i = this.tr.tms_pad_i;
        this.comp.trst_pad_i = this.tr.trst_pad_i;
        this.comp.tdi_pad_i = this.tr.tdi_pad_i;
        this.comp.bs_chain_tdi_i = this.tr.bs_chain_tdi_i;
        this.comp.debug_tdi_i = this.tr.debug_tdi_i;
        this.comp.mbist_tdi_i = this.tr.mbist_tdi_i;
    endfunction

    function void reset_output_vars_in_comp();
        this.comp.shift_dr_o = 0;
        this.comp.capture_dr_o = 0;
        this.comp.update_dr_o = 0;
        this.comp.pause_dr_o = 0;

        this.comp.tdo_o = tr.tdi_pad_i;
        this.comp.tdo_pad_o = 0;

        this.extest_select_o = 0;
        this.sample_preload_select_o = 0;
        this.mbist_select_o = 0;
        this.debug_select_o = 0;
    endfunction

endclass
