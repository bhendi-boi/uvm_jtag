// module TAP (
//     tap_intf.tap_port port
// );



// task display_current_state();
//     $display("Current State = %s, TMS = %d", TAP_STATE.name(), port.tms);
// endtask

//     task reset_all_signals();
//         port.selectDR  = 0;
//         port.captureDR = 0;
//         port.shiftDR   = 0;
//         port.updateDR  = 0;
//         port.selectIR  = 0;
//         port.captureIR = 0;
//         port.shiftIR   = 0;
//         port.updateIR  = 0;
//     endtask

//     task assert_select_dr();
//         port.selectDR = 1;
//         $display("Asserting selectDR signal");
//     endtask

//     task assert_capture_dr();
//         @(negedge port.tck) port.captureDR = 1;
//         $display("Asserting captureDR signal on negedge of tck");
//     endtask

//     task assert_shift_dr();
//         port.shiftDR = 1;
//         $display("Asserting shiftDR signal");
//     endtask

//     task assert_update_dr();
//         port.updateDR = 1;
//         $display("Asserting updateDR signal");
//     endtask

//     task assert_select_ir();
//         port.selectIR = 1;
//         $display("Asserting selectIR signal");
//     endtask

//     task assert_capture_ir();
//         @(negedge port.tck) port.captureIR = 1;
//         $display("Asserting captureIR signal on negedge of tck");
//     endtask

//     task assert_shift_ir();
//         port.shiftIR = 1;
//         $display("Asserting shiftIR signal");
//     endtask

//     task assert_update_ir();
//         port.updateIR = 1;
//         $display("Asserting updateIR signal");
//     endtask

//     always @(posedge port.tck) begin

//         display_current_state();
//         reset_all_signals();

//         if (TAP_STATE == SELECT_DR) assert_select_dr();
//         if (TAP_STATE == CAPTURE_DR) assert_capture_dr();
//         if (TAP_STATE == SHIFT_DR) assert_shift_dr();




//         if (tms_count == 4) begin
//             $display("Synchronous rest");
//             tms_count = 0;
//         end else begin
//             if (port.tms) tms_count++;
//             else begin
//                 tms_count = 0;
//             end
//         end

//         $display("\n");
//     end

// endmodule


function void model_tap(input bit tms, input bit trst,
                        output bit is_sync_reset);

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

    static int tms_count = 0;

    `uvm_info("Model_SV", $sformatf(
              "Current State = %s, TMS = %d", TAP_STATE.name(), tms), UVM_LOW)

    if (trst) begin
        TAP_STATE = TEST_LOGIC_RESET;
    end else begin
        if (TAP_STATE == TEST_LOGIC_RESET) begin
            if (tms) TAP_STATE <= TEST_LOGIC_RESET;
            else TAP_STATE <= IDLE;
        end else if (TAP_STATE == IDLE) begin
            if (tms) TAP_STATE <= SELECT_DR;
            else TAP_STATE <= IDLE;
        end else if (TAP_STATE == SELECT_DR) begin
            if (tms) TAP_STATE <= SELECT_IR;
            else TAP_STATE <= CAPTURE_DR;
        end else if (TAP_STATE == CAPTURE_DR) begin
            if (tms) TAP_STATE <= EXIT_1_DR;
            else TAP_STATE <= SHIFT_DR;
        end else if (TAP_STATE == SHIFT_DR) begin
            if (tms) TAP_STATE <= EXIT_1_DR;
            else TAP_STATE <= SHIFT_DR;
        end else if (TAP_STATE == EXIT_1_DR) begin
            if (tms) TAP_STATE <= UPDATE_DR;
            else TAP_STATE <= PAUSE_DR;
        end else if (TAP_STATE == PAUSE_DR) begin
            if (tms) TAP_STATE <= EXIT_2_DR;
            else TAP_STATE <= PAUSE_DR;
        end else if (TAP_STATE == EXIT_2_DR) begin
            if (tms) TAP_STATE <= UPDATE_DR;
            else TAP_STATE <= SHIFT_DR;
        end else if (TAP_STATE == UPDATE_DR) begin
            if (tms) TAP_STATE <= SELECT_DR;
            else TAP_STATE <= IDLE;
        end else if (TAP_STATE == SELECT_IR) begin
            if (tms) TAP_STATE <= TEST_LOGIC_RESET;
            else TAP_STATE <= CAPTURE_IR;
        end else if (TAP_STATE == CAPTURE_IR) begin
            if (tms) TAP_STATE <= EXIT_1_IR;
            else TAP_STATE <= SHIFT_IR;
        end else if (TAP_STATE == SHIFT_IR) begin
            if (tms) TAP_STATE <= EXIT_1_IR;
            else TAP_STATE <= SHIFT_IR;
        end else if (TAP_STATE == EXIT_1_IR) begin
            if (tms) TAP_STATE <= UPDATE_IR;
            else TAP_STATE <= PAUSE_IR;
        end else if (TAP_STATE == PAUSE_IR) begin
            if (tms) TAP_STATE <= EXIT_2_IR;
            else TAP_STATE <= PAUSE_IR;
        end else if (TAP_STATE == EXIT_2_DR) begin
            if (tms) TAP_STATE <= UPDATE_IR;
            else TAP_STATE <= SHIFT_IR;
        end else begin
            if (tms) TAP_STATE <= SELECT_DR;
            else TAP_STATE <= IDLE;
        end
    end

    if (trst) begin
        tms_count = 0;
    end else begin
        if (tms_count == 4) begin
            `uvm_info("Model_SV", "Sync Reset Detected", UVM_LOW)
            tms_count = 0;
            is_sync_reset = 1;
        end else begin
            is_sync_reset = 0;
            if (tms) tms_count++;
            else tms_count = 0;
        end
    end

endfunction


function bit sync_reset_check(input bit shift_dr, input bit pause_dr,
                              input bit update_dr, input bit capture_dr);

    bit [3:0] temp;
    temp = {shift_dr, pause_dr, update_dr, capture_dr};
    if (temp == 4'b0000) return 0;
    else return 1;

endfunction
