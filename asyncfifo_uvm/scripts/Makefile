# Filename: Makefile - Placed in the scripts/ directory

# --- Directory Paths ---
RTL_DIR  := ../rtl
SRC_DIR  := ../src
TOP_DIR  := ../top

# --- Project Configuration ---

TOP_MODULE := uvm_top 

TEST_NAME  := test 
SIMULATOR := vcs 

# --- Source File Lists ---
# All design (Verilog) files
RTL_FILES  := $(RTL_DIR)/fifo_mem.v\
			  $(RTL_DIR)/rptr_handler.v\
			  $(RTL_DIR)/wptr_handler.v\
			  $(RTL_DIR)/synchronizer.v\
			  $(RTL_DIR)/top_module.v

# All SystemVerilog files (Interface, Package/Components, Top Module)
# Compiler must resolve packages (like adder_pkg) before linking the top module.
TB_FILES   := $(SRC_DIR)/env.sv \
              $(SRC_DIR)/fifo_if.sv \
			  $(SRC_DIR)/my_transaction.sv \
			  $(SRC_DIR)/read_agent.sv \
			  $(SRC_DIR)/read_driver.sv \
			  $(SRC_DIR)/read_monitor.sv \
			  $(SRC_DIR)/read_seq.sv \ 
			  $(SRC_DIR)/read_seqr.sv \
			  $(SRC_DIR)/scoreboard.sv \ 
			  $(SRC_DIR)/test.sv \
			  $(SRC_DIR)/write_agent.sv \
			  $(SRC_DIR)/write_driver.sv \
			  $(SRC_DIR)/write_monitor.sv \
			  $(SRC_DIR)/write_seq.sv \
			  $(SRC_DIR)/write_seqr.sv \			  
              $(TOP_DIR)/uvm_top.sv

# --- Compiler Options ---
# -sverilog: Enable SystemVerilog
# -ntb_opts uvm: Enable UVM library
# -fullpkg: Instructs VCS to compile packages first and resolve dependencies
# +incdir+: Tell the compiler where to look for 'include files
VLOG_OPTS  := -sverilog -ntb_opts uvm -full64 -fullpkg +incdir+$(SRC_DIR) +incdir+$(TOP_DIR)

# --- Simulation Options ---
SIM_OPTS   :=  +UVM_TESTNAME=$(TEST_NAME) +UVM_VERBOSITY=UVM_LOW -l sim.log

# --- Targets ---

.PHONY: all compile sim clean

# Default target: compile and simulate
all: compile sim

# Target to compile and elaborate the design and testbench
compile:
	@echo "--- Compiling $(SIMULATOR) build for $(TOP_MODULE) ---"
	# Ensure the compilation order is correct: RTL -> Interface -> Package -> Top Module
	vcs $(VLOG_OPTS) $(RTL_FILES) $(TB_FILES) -o simv
	@echo "--- Compilation successful. Ready to simulate. ---"

# Target to run the simulation
sim:
	@echo "--- Running simulation for $(TEST_NAME) ---"
	./simv $(SIM_OPTS)

# Target to clean up generated files
clean:
	@echo "--- Cleaning up simulation files ---"
	rm -rf simv* csrc* *.log ucli.key DVEfiles* *.vpd
