# Asynchronous RAM Verification Environment (UVM)

This repository contains a **SystemVerilog UVM-based verification environment** for a RAM design (`ram_dut.v`).  
The project uses **Synopsys VCS** as the simulator and is driven via a centralized **Makefile**.

---

## 📁 Project Structure

.
├── rtl/
│ └── ram_dut.v # RAM DUT (Design Under Test)
│
├── src/
│ ├── interface.sv # Virtual interface
│ ├── ram_defines.svh # Global defines
│ ├── ram_pkg.sv # UVM package
│ ├── ram_env.sv # UVM environment
│ ├── ram_scoreboard.sv # Scoreboard
│ ├── ram_trans.sv # Transaction class
│ │
│ ├── ram_rd_agent.sv # Read agent
│ ├── ram_rd_driver.sv
│ ├── ram_rd_monitor.sv
│ ├── ram_rd_sequencer.sv
│ ├── ram_rd_seq.sv
│ │
│ ├── ram_wr_agent.sv # Write agent
│ ├── ram_wr_driver.sv
│ ├── ram_wr_monitor.sv
│ ├── ram_wr_sequencer.sv
│ ├── ram_wr_seq.sv
│ │
│ └── ram_test.sv # UVM test
│
├── top/
│ └── testbench.sv # Top-level testbench
│
├── scripts/
│ └── Makefile # Build & simulation control
│
└── README.md

yaml
Copy code

---

## 🧪 Verification Methodology

- **Methodology**: UVM (Universal Verification Methodology)
- **Language**: SystemVerilog
- **Simulator**: Synopsys VCS
- **Verification Components**:
  - Separate **read** and **write** agents
  - Transaction-level modeling
  - Scoreboard-based checking
  - Configurable UVM test selection

---

## ⚙️ Configuration

| Parameter | Value |
|--------|------|
| Top module | `tb` |
| Default test | `ram_test` |
| Simulator | `vcs` |
| UVM verbosity | `UVM_LOW` |
| Log file | `sim.log` |

---

## 🛠 Build & Simulation Flow

Run all commands from the `scripts/` directory.

### Compile and Simulate (default)
```bash
make
Compile Only
bash
Copy code
make compile
Run Simulation Only
bash
Copy code
make sim
This runs:

bash
Copy code
./simv +UVM_TESTNAME=ram_test +UVM_VERBOSITY=UVM_LOW -l sim.log
Clean Generated Files
bash
Copy code
make clean
Removes:

simv*

csrc*

*.log

*.vpd

DVEfiles*

ucli.key

Notes on Compilation Order
The Makefile enforces the correct compilation order:

RTL (ram_dut.v)

Interface

UVM packages

Agents and environment

Top-level testbench

This avoids package dependency and elaboration issues in VCS.

Requirements
Synopsys VCS (with UVM support)

Linux environment

Proper VCS license setup

Future Enhancements
Functional coverage

Assertion-based verification (SVA)

Multiple UVM tests via +UVM_TESTNAME

Regression automation

CI integration
