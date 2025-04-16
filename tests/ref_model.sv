class ref_model extends uvm_component;
    `uvm_component_utils(ref_model)

    uvm_analysis_imp #(transaction, ref_model) ref_port;
    transaction tr, trs[$], comp;

    function new(string name = "ref_model", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ref_port = new("ref_port", this);
    endfunction

    function void write(transaction t);
        trs.push_back(t);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        tr = transaction::type_id::create("tr");

        forever begin
            wait (trs.size() != 0);
            tr = trs.pop_front();
            `uvm_info(
                "Ref Model", $sformatf(
                "Prev State = %s, TMS = %d", tap_state.name(), tr.tms_pad_i),
                UVM_LOW)

            compute_current_state(tr.trst_pad_i, tr.tms_pad_i);

            `uvm_info("Ref Model", $sformatf(
                      "Current State = %s", tap_state.name()), UVM_LOW)

            this.is_sync_reset =
                check_for_sync_reset(tr.trst_pad_i, tr.tms_pad_i);
            if (this.is_sync_reset)
                `uvm_info("Ref Model", "Sync Reset Detected", UVM_HIGH)

            add_assert_statements();
            check_for_bypass(tr.tdi_pad_i);
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

    TAP_STATE tap_state;

    int tms_count;  // used to check for sync reset.
    bit is_sync_reset;  // asserted when sync reset is detected

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

    function void add_assert_statements();
        if (this.tap_state == CAPTURE_DR) begin
            `uvm_info("Ref Model", "Capture DR asserted", UVM_HIGH)
            comp.capture_dr_o = 1;
        end
        if (this.tap_state == SHIFT_DR) begin
            `uvm_info("Ref Model", "Shift DR asserted", UVM_HIGH)
            comp.shift_dr_o = 1;
        end
        if (this.tap_state == UPDATE_DR) begin
            `uvm_info("Ref Model", "UPDATE DR asserted", UVM_HIGH)
            comp.update_dr_o = 1;
        end
        if (this.tap_state == PAUSE_DR) begin
            `uvm_info("Ref Model", "PAUSE DR asserted", UVM_HIGH)
            comp.pause_dr_o = 1;
        end
        if (this.tap_state == CAPTURE_IR) begin
            `uvm_info("Ref Model", "Capture IR asserted", UVM_HIGH)
        end
        if (this.tap_state == SHIFT_IR) begin
            `uvm_info("Ref Model", "Shift IR asserted", UVM_HIGH)
        end
        if (this.tap_state == UPDATE_IR) begin
            `uvm_info("Ref Model", "UPDATE IR asserted", UVM_HIGH)
        end
        if (this.tap_state == PAUSE_IR) begin
            `uvm_info("Ref Model", "PAUSE IR asserted", UVM_HIGH)
        end
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

endclass
