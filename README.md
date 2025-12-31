# Asynchronous FIFO UVM Testbench

## Overview

This project implements a comprehensive UVM (Universal Verification Methodology) testbench for an Asynchronous FIFO (First-In-First-Out) module. The FIFO operates with independent write and read clocks, making it suitable for clock domain crossing (CDC) applications. The testbench follows UVM best practices with separate agents for read and write operations, monitors, drivers, sequencers, and a scoreboard for functional verification.

## Project Structure

```
asyncfifo_uvm/
├── rtl/                    # RTL Design Files
│   ├── top_module.v       # Top-level FIFO module
│   ├── fifo_mem.v         # FIFO memory array
│   ├── wptr_handler.v     # Write pointer handler with Gray code encoding
│   ├── rptr_handler.v     # Read pointer handler with Gray code encoding
│   └── synchronizer.v     # Dual-flop synchronizer for CDC
├── src/                    # UVM Testbench Source Files
│   ├── fifo_if.sv         # SystemVerilog interface for DUT connection
│   ├── my_transaction.sv   # Transaction class (sequence item)
│   ├── write_agent.sv     # Write agent (driver, monitor, sequencer)
│   ├── read_agent.sv      # Read agent (driver, monitor, sequencer)
│   ├── write_driver.sv    # Write driver
│   ├── read_driver.sv     # Read driver
│   ├── write_monitor.sv   # Write monitor
│   ├── read_monitor.sv    # Read monitor
│   ├── write_seqr.sv      # Write sequencer
│   ├── read_seqr.sv       # Read sequencer
│   ├── write_seq.sv       # Write sequence
│   ├── read_seq.sv        # Read sequence
│   ├── env.sv             # UVM environment
│   ├── scoreboard.sv      # Scoreboard for functional checking
│   └── test.sv            # Top-level test class
├── top/                    # Top-level Testbench
│   └── uvm_top.sv         # Testbench module with DUT instantiation
└── scripts/                # Build and Simulation Scripts
    └── Makefile           # Makefile for compilation and simulation
```

## Asynchronous FIFO DUT Specifications

The Asynchronous FIFO module (`top_module.v`) is a parameterized dual-clock FIFO with the following features:

### Parameters
- `DATA_WIDTH = 8`: Data width (default: 8 bits)
- `DEPTH = 8`: FIFO depth (default: 8 locations)
- `PTR_WIDTH`: Automatically calculated as `$clog2(DEPTH)` (default: 3 bits)

### Ports

**Write Domain (wclk):**
- `wclk`: Write clock
- `w_rstn`: Write reset (active low)
- `wen`: Write enable
- `data_in[DATA_WIDTH-1:0]`: Write data input
- `full`: Full flag (output)

**Read Domain (rclk):**
- `rclk`: Read clock
- `r_rstn`: Read reset (active low)
- `ren`: Read enable
- `data_out[DATA_WIDTH-1:0]`: Read data output
- `empty`: Empty flag (output)

### Architecture

The FIFO consists of four main components:

#### 1. FIFO Memory (`fifo_mem.v`)
- Dual-port memory array storing FIFO data
- Write operation: On `wclk` positive edge, when `wen=1` and `!full`, writes `data_in` to `fifo[b_wptr[PTR_WIDTH-1:0]]`
- Read operation: On `rclk` positive edge, when `ren=1` and `!empty`, reads `fifo[b_rptr[PTR_WIDTH-1:0]]` to `data_out`

#### 2. Write Pointer Handler (`wptr_handler.v`)
- Manages write pointer (`b_wptr`) and Gray-coded write pointer (`g_wptr`)
- Converts binary pointer to Gray code: `g_wptr = (b_wptr >> 1) ^ b_wptr`
- Generates `full` flag by comparing Gray-coded pointers
- Full condition: `g_wptr_next == {~g_rptr_sync[PTR_WIDTH], ~g_rptr_sync[PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]}`

#### 3. Read Pointer Handler (`rptr_handler.v`)
- Manages read pointer (`b_rptr`) and Gray-coded read pointer (`g_rptr`)
- Converts binary pointer to Gray code: `g_rptr = (b_rptr >> 1) ^ b_rptr`
- Generates `empty` flag by comparing Gray-coded pointers
- Empty condition: `g_wptr_sync == g_rptr_next`

#### 4. Synchronizer (`synchronizer.v`)
- Dual-flop synchronizer for clock domain crossing
- Synchronizes Gray-coded pointers between clock domains
- Two-stage pipeline: `d_in -> q1 -> d_out`
- Prevents metastability issues when crossing clock domains

### Functionality
- **Asynchronous Operation**: Write and read operations operate on independent clocks
- **Gray Code Encoding**: Pointers are encoded in Gray code to prevent glitches during CDC
- **Full/Empty Detection**: Uses Gray code comparison to safely detect full and empty conditions across clock domains
- **Reset**: Independent resets for write and read domains
- **FIFO Behavior**: First-in-first-out data ordering

## UVM Testbench Architecture

### Transaction Class (`my_transaction.sv`)
- Extends `uvm_sequence_item`
- Fields:
  - `ren`: Read enable (rand)
  - `wen`: Write enable (rand)
  - `data_in[7:0]`: Write data (rand, constrained to 1-255)
  - `data_out[7:0]`: Read data (non-rand, captured from DUT)
- Constraint: `data_in` must be in range [1:255]

### Interface (`fifo_if.sv`)
- SystemVerilog interface `fifo_if` parameterized by `DATA_WIDTH` (default: 8)
- Two modports:
  - `WRITE_MP`: For write domain (wclk, w_rstn, data_in, wen, full)
  - `READ_MP`: For read domain (rclk, r_rstn, data_out, empty, ren)
- Separate clock domains: `wclk` and `rclk`

### Agents

#### Write Agent (`write_agent.sv`)
- Contains write driver, write monitor, and write sequencer
- Active agent (can be configured as active or passive)
- Connects driver to sequencer in connect phase

#### Read Agent (`read_agent.sv`)
- Contains read driver, read monitor, and read sequencer
- Active agent (can be configured as active or passive)
- Connects driver to sequencer in connect phase

**Note**: There appears to be a bug in `read_agent.sv` where it instantiates `write_driver`, `write_seqr`, and `write_monitor` instead of the corresponding read components. This should be fixed.

### Drivers

#### Write Driver (`write_driver.sv`)
- Drives write enable (`wen`) and write data (`data_in`)
- Checks `full` flag before writing
- Drives `wen` for one clock cycle
- Uses `fifo_if.WRITE_MP` modport

#### Read Driver (`read_driver.sv`)
- Drives read enable (`ren`)
- Checks `empty` flag before reading
- Drives `ren` for one clock cycle
- Uses `fifo_if.READ_MP` modport

**Note**: The `read_driver.sv` uses `body()` task instead of `run_phase()`, which is incorrect for UVM drivers. This should be changed to `run_phase()`.

### Monitors

#### Write Monitor (`write_monitor.sv`)
- Monitors write transactions on the write interface
- Captures write operations when `wen=1` and `!full`
- Sends captured transactions to scoreboard via analysis port
- Uses `fifo_if.WRITE_MP` modport

**Note**: There's a reference to `full` without `vif.full` in the monitor, which should be fixed.

#### Read Monitor (`read_monitor.sv`)
- Monitors read transactions on the read interface
- Captures read operations when `ren=1` and `!empty`
- Captures `data_out` from the interface
- Sends captured transactions to scoreboard via analysis port
- Uses `fifo_if.READ_MP` modport

**Note**: There's a reference to `empty` without `vif.empty` in the monitor, which should be fixed.

### Sequencers

#### Write Sequencer (`write_seqr.sv`)
- Extends `uvm_sequencer #(my_transaction)`
- Manages write sequence items

#### Read Sequencer (`read_seqr.sv`)
- Extends `uvm_sequencer #(my_transaction)`
- Manages read sequence items

### Sequences

#### Write Sequence (`write_seq.sv`)
- Generates a single write transaction
- Uses `wait_for_grant()`, `send_request()`, and `wait_for_item_done()` pattern
- Randomizes transaction with write enable

#### Read Sequence (`read_seq.sv`)
- Generates a single read transaction
- Uses `wait_for_grant()`, `send_request()`, and `wait_for_item_done()` pattern
- Randomizes transaction with read enable

### Environment (`env.sv`)
- Top-level UVM environment
- Instantiates write agent, read agent, and scoreboard
- Connects monitor analysis ports to scoreboard:
  - `wa.mon.item_collect_port` -> `sb.item_collect_export_write`
  - `ra.mon.item_collect_port` -> `sb.item_collect_export_read`

### Scoreboard (`scoreboard.sv`)
- Maintains a queue (`q`) of expected write transactions
- Receives write transactions and pushes them to the queue
- Receives read transactions and compares with expected data from queue (FIFO order)
- Reports mismatches using `uvm_error`
- Reports successful matches using `uvm_info`

**Note**: There's a typo in the scoreboard: `sb_item,data_out` should be `sb_item.data_out`.

### Test Class (`test.sv`)
- Top-level UVM test
- Instantiates environment
- Runs write and read sequences in parallel using `fork-join`
- Manages simulation objection

### Testbench (`uvm_top.sv`)
- Top-level SystemVerilog module
- Instantiates DUT and interface
- Generates independent clocks:
  - Write clock (`wclk`): 10ns period (50MHz)
  - Read clock (`rclk`): 14ns period (~35.7MHz)
- Implements reset sequence: Both resets low for 50ns, then released
- Sets up UVM configuration database with virtual interfaces
- Runs UVM test

## Configuration Parameters

- `DATA_WIDTH`: 8 bits (default)
- `DEPTH`: 8 locations (default)
- `PTR_WIDTH`: 3 bits (calculated from DEPTH)

## Build and Simulation

### Prerequisites
- VCS (Synopsys) simulator
- UVM library

### Using Makefile

The Makefile in the `scripts/` directory provides convenient targets:

```bash
cd scripts

# Compile and simulate
make all

# Compile only
make compile

# Simulate only (after compilation)
make sim

# Clean generated files
make clean
```

### Manual Compilation

```bash
vcs -sverilog -ntb_opts uvm -full64 -fullpkg \
    +incdir+../src +incdir+../top \
    ../rtl/fifo_mem.v \
    ../rtl/rptr_handler.v \
    ../rtl/wptr_handler.v \
    ../rtl/synchronizer.v \
    ../rtl/top_module.v \
    ../src/fifo_if.sv \
    ../src/my_transaction.sv \
    ../src/write_agent.sv \
    ../src/read_agent.sv \
    ../src/write_driver.sv \
    ../src/read_driver.sv \
    ../src/write_monitor.sv \
    ../src/read_monitor.sv \
    ../src/write_seqr.sv \
    ../src/read_seqr.sv \
    ../src/write_seq.sv \
    ../src/read_seq.sv \
    ../src/env.sv \
    ../src/scoreboard.sv \
    ../src/test.sv \
    ../top/uvm_top.sv \
    -o simv
```

### Running Simulation

```bash
./simv +UVM_TESTNAME=test +UVM_VERBOSITY=UVM_LOW -l sim.log
```

## Test Coverage

The testbench covers:
- Write operations to FIFO
- Read operations from FIFO
- Full condition handling
- Empty condition handling
- FIFO ordering (FIFO behavior)
- Clock domain crossing (asynchronous operation)
- Data integrity verification through scoreboard



