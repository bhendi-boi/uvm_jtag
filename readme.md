# JTAG verification with UVM

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

### Testing Reset

- `reset_test` is used to test the reset mechanism of JTAG.
- `sync_reset_seq` generated five consecutive cycles with `TMS` = 1.
- design has 2 internal variables `tms_reset` and `test_logic_reset` to detect reset.
- `tms_reset` is asserted after five consecutive cycles with `TMS` = 1.
- `test_logic_reset` is the final signal which resets the DUT.
