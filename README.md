# RAM Module UVM Testbench

## Overview

This project implements a comprehensive UVM (Universal Verification Methodology) testbench for a parameterized RAM (Random Access Memory) module. The testbench follows UVM best practices with separate agents for read and write operations, monitors, drivers, sequencers, and a scoreboard for functional verification.

## Project Structure

```
ram/
├── rtl/                    # RTL Design Files
│   └── ram_dut.v          # RAM Design Under Test (DUT)
├── src/                    # UVM Testbench Source Files
│   ├── ram_defines.svh    # SystemVerilog defines and parameters
│   ├── interface.sv       # SystemVerilog interface for DUT connection
│   ├── ram_trans.sv       # Transaction class (sequence item)
│   ├── ram_pkg.sv         # UVM package containing all testbench components
│   ├── ram_wr_agent.sv    # Write agent (driver, monitor, sequencer)
│   ├── ram_rd_agent.sv    # Read agent (driver, monitor, sequencer)
│   ├── ram_wr_driver.sv   # Write driver
│   ├── ram_rd_driver.sv   # Read driver
│   ├── ram_wr_monitor.sv  # Write monitor
│   ├── ram_rd_monitor.sv  # Read monitor
│   ├── ram_wr_sequencer.sv # Write sequencer
│   ├── ram_rd_sequencer.sv # Read sequencer
│   ├── ram_wr_seq.sv      # Write sequence
│   ├── ram_rd_seq.sv      # Read sequence
│   ├── ram_env.sv         # UVM environment
│   ├── ram_scoreboard.sv  # Scoreboard for functional checking
│   └── ram_test.sv        # Top-level test class
├── top/                    # Top-level Testbench
│   └── testbench.sv       # Testbench module with DUT instantiation
└── scripts/                # Build and Simulation Scripts
    └── Makefile           # Makefile for compilation and simulation
```

## RAM DUT Specifications

The RAM module (`ram_dut.v`) is a parameterized synchronous RAM with the following features:

### Parameters
- `ADDR_WIDTH = 4`: Address width (default: 4 bits, supports 16 locations)
- `DATA_WIDTH = 8`: Data width (default: 8 bits)
- `DEPTH = 16`: Memory depth (default: 16 locations)

### Ports
- `clk`: Clock signal
- `rst`: Reset signal (active high)
- `wen`: Write enable signal
- `ren`: Read enable signal
- `cs`: Chip select signal
- `wdata[DATA_WIDTH-1:0]`: Write data input
- `waddr[ADDR_WIDTH-1:0]`: Write address
- `raddr[ADDR_WIDTH-1:0]`: Read address
- `rdata[DATA_WIDTH-1:0]`: Read data output

### Functionality
- Synchronous operation on positive clock edge
- Reset clears all memory locations and read data output
- Write operation: When `cs=1` and `wen=1`, data is written to `ram[waddr]`
- Read operation: When `cs=1` and `ren=1`, data is read from `ram[raddr]` to `rdata`
- Simultaneous read and write operations are supported (`wen=1` and `ren=1`)

## UVM Testbench Architecture

### Transaction Class (`ram_trans.sv`)
- Extends `uvm_sequence_item`
- Defines transaction types: `WRITE`, `READ`, `SIM_WR` (simultaneous write-read), `IDLE`
- Contains constraints for valid addresses and transaction type validation
- Fields: `wen`, `ren`, `wdata`, `rdata`, `waddr`, `raddr`, `cs`, `cases`

### Interface (`interface.sv`)
- SystemVerilog interface `ram_if` with clocking blocks
- `drv_cb`: Clocking block for drivers (outputs control signals)
- `mon_cb`: Clocking block for monitors (inputs for observation)
- Modports: `drv_mp` for drivers, `mon_mp` for monitors

### Agents

#### Write Agent (`ram_wr_agent.sv`)
- Contains write driver, write monitor, and write sequencer
- Active agent (can be configured as active or passive)

#### Read Agent (`ram_rd_agent.sv`)
- Contains read driver, read monitor, and read sequencer
- Active agent (can be configured as active or passive)

### Drivers

#### Write Driver (`ram_wr_driver.sv`)
- Drives write enable (`wen`), write address (`waddr`), write data (`wdata`), and chip select (`cs`)
- Receives transactions from write sequencer and drives them to DUT

#### Read Driver (`ram_rd_driver.sv`)
- Drives read enable (`ren`), read address (`raddr`), and chip select (`cs`)
- Receives transactions from read sequencer and drives them to DUT

### Monitors

#### Write Monitor (`ram_wr_monitor.sv`)
- Monitors write transactions on the interface
- Captures write operations when `wen=1` and `cs=1`
- Sends captured transactions to scoreboard via analysis port

#### Read Monitor (`ram_rd_monitor.sv`)
- Monitors read transactions on the interface
- Captures read operations when `ren=1` and `cs=1`
- Captures read data on the next clock cycle (pipelined read)
- Sends captured transactions to scoreboard via analysis port

### Sequencers

#### Write Sequencer (`ram_wr_sequencer.sv`)
- Extends `uvm_sequencer #(ram_trans)`
- Manages write sequence items

#### Read Sequencer (`ram_rd_sequencer.sv`)
- Extends `uvm_sequencer #(ram_trans)`
- Manages read sequence items

### Sequences

#### Write Sequence (`ram_wr_seq.sv`)
- Generates `no_of_itr` (20) write transactions
- Randomizes transactions with `cases == WRITE`

#### Read Sequence (`ram_rd_seq.sv`)
- Generates `no_of_itr` (20) read transactions
- Randomizes transactions with `cases == READ`

### Environment (`ram_env.sv`)
- Top-level UVM environment
- Instantiates write agent, read agent, and scoreboard
- Connects monitor analysis ports to scoreboard

### Scoreboard (`ram_scoreboard.sv`)
- Maintains a local memory model (`local_mem`)
- Receives write transactions and updates local memory
- Receives read transactions and compares with expected data from local memory
- Reports mismatches using `uvm_fatal`

### Test Class (`ram_test.sv`)
- Top-level UVM test
- Instantiates environment
- Runs write and read sequences in parallel using `fork-join`
- Manages simulation objection

### Testbench (`testbench.sv`)
- Top-level SystemVerilog module
- Instantiates DUT and interface
- Generates clock (10ns period, 50MHz)
- Implements reset task
- Sets up UVM configuration database with virtual interface
- Generates VCD dump file for waveform viewing

## Configuration Parameters

Defined in `ram_defines.svh`:
- `ADDR_WIDTH`: 4 bits
- `DATA_WIDTH`: 8 bits
- `DEPTH`: 16 memory locations
- `no_of_itr`: 20 iterations per sequence

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
    ../rtl/ram_dut.v \
    ../src/interface.sv \
    ../src/ram_defines.svh \
    ../src/ram_pkg.sv \
    ../top/testbench.sv \
    -o simv
```

### Running Simulation

```bash
./simv +UVM_TESTNAME=ram_test +UVM_VERBOSITY=UVM_LOW -l sim.log
```

## Test Coverage

The testbench covers:
- Write operations to all valid addresses
- Read operations from all valid addresses
- Simultaneous read and write operations
- Reset functionality
- Chip select functionality
- Data integrity verification through scoreboard

## Waveform Analysis

The testbench generates a VCD dump file (`dump.vcd`) that can be viewed with:
- GTKWave
- DVE (Synopsys)
- Any VCD-compatible waveform viewer

## Notes

- The package file (`ram_pkg.sv`) includes a reference to `ram_base_test.sv`, which is not present in the current codebase. This may need to be addressed if a base test class is required.
- The test runs write and read sequences in parallel, which may cause race conditions if the same address is accessed simultaneously. The scoreboard handles this appropriately.
- The read monitor captures read data on the cycle following the read enable assertion, accounting for the DUT's synchronous read behavior.


