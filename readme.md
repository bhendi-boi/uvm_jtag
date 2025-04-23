# JTAG TAP Controller verification with UVM

## Resources

- DUT is taken from opencores website.
- Can also be found on [this github page](https://github.com/fabriziotappero/ip-cores/tree/other_jtag_test_access_port_tap/tap/rtl/verilog).
- Only change made to the dut is removing `#1` delays in assigning values.

## Run Commands

### Xcelium

```bash
xrun -Q -unbuffered -gui '-timescale' '1ns/1ns' '-sysv' '-access' '+rw' '+UVM_VERBOSITY=UVM_FULL' '+UVM_TESTNAME=test_all_test' '-svseed' '2' -uvmautocompile -uvmnocdnsextra -uvmhome $UVM_HOME $UVM_HOME/src/uvm_macros.svh design.sv testbench.sv -incdir agent -incdir tests -input input.tcl -simvisionargs '-layout uvmdebug'

```

## SPEC

- signals with suffix `i` are inputs and signals with suffix `o` are outputs.

### Signal description

| Signal       | Description             |
| ------------ | ----------------------- |
| `tck_pad_i`  | TCK signal from 1149.1  |
| `tms_pad_i`  | TMS signal from 1149.1  |
| `tdi_pad_i`  | TDI signal from 1149.1  |
| `trst_pad_i` | TRST signal from 1149.1 |
| `tdo_pad_o`  | TDO signal from 1149.1  |

#### Supported instructions

Instruction register length = 4

| Test name      | OPCODE  |
| -------------- | ------- |
| EXTEST         | 4'b0000 |
| SAMPLE_PRELOAD | 4'b0001 |
| IDCODE         | 4'b0010 |
| DEBUG          | 4'b1000 |
| MBIST          | 4'b1001 |
| BYPASS         | 4'b1111 |

## Progress

### Testing Reset ✅

- `reset_test` is used to test the reset mechanism of JTAG.
- `sync_reset_seq` generated five consecutive cycles with `TMS` = 1.
- design has 2 internal variables `tms_reset` and `test_logic_reset` to detect reset.
- `tms_reset` is asserted after five consecutive cycles with `TMS` = 1.
- `test_logic_reset` is the final signal which resets the DUT.

### IDCODE ✅

- `IDCODE` instruction register is `0100`.
- `id_code_seq` generates five consecutive cycles with `TMS` = 1.
- Move TAP to SHIFT_IR.
- Update IR to `IDCODE`.
- Move TAP to SHIFT_DR and stay in the same state for 32 transactions while sampling `tdo_pad_o`.

### EXTEST ✅

- Run `extest_test` to test the extest functionality of JTAG.
- `extest_seq` loads `0000` into the instruction register.
- Then it brings TAP to IDLE State.
- `bs_chain_tdi` is connected to `tdo_pad_o`.

### BYPASS ✅

- Run `bypass_test` to test the bypass functionality of JTAG.
- `bypass_seq` load `1111` into the instruction register.
- Then it brings TAP to SHIFT_DR state.
- `tdo_pad_o` lags `tdi_pad` by one cycle.

### Debug ✅

- Run `debug_test` to test the debug functionality of JTAG.
- `debug_seq` load `1000` into the instruction register.
- Then it brings TAP to IDLE state.
- `debug_tdi_i` is connected to `tdo_pad_o`
