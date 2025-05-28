# Makefile for MIPS Multi-cycle Processor

# Source files
SOURCES = src/definitions.vh \
          src/ALU.v \
          src/RegisterFile.v \
          src/InstructionMemory.v \
          src/DataMemory.v \
          src/SignExtender.v \
          src/ControlUnit.v \
          src/MIPS_Multicycle.v \
          tests/MIPS_Multicycle_tb.v

# Output files
OUTPUT = mips_multicycle
VCD = mips_multicycle.vcd

# Default target
all: compile run

# Compile the design (try different simulators)
compile:
	@echo "Trying to compile with available Verilog simulator..."
	@if command -v iverilog >/dev/null 2>&1; then \
		echo "Using Icarus Verilog..."; \
		iverilog -o $(OUTPUT) $(SOURCES); \
	elif command -v vcs >/dev/null 2>&1; then \
		echo "Using VCS..."; \
		vcs -o $(OUTPUT) $(SOURCES); \
	elif command -v xvlog >/dev/null 2>&1; then \
		echo "Using Xilinx Vivado simulator..."; \
		xvlog $(SOURCES) && xelab -debug typical work.MIPS_Multicycle_tb -s $(OUTPUT); \
	else \
		echo "No supported Verilog simulator found!"; \
		echo "Please install one of: iverilog, vcs, or Xilinx Vivado"; \
		exit 1; \
	fi

# Run simulation
run: compile
	@if [ -f "./$(OUTPUT)" ]; then \
		echo "Running simulation..."; \
		./$(OUTPUT); \
	elif command -v xsim >/dev/null 2>&1; then \
		echo "Running Xilinx simulation..."; \
		xsim $(OUTPUT) -runall; \
	else \
		echo "Cannot find executable to run simulation"; \
	fi

# View waveforms
view: run
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave $(VCD) &; \
	else \
		echo "GTKWave not found. Install it to view waveforms."; \
	fi

# Clean generated files
clean:
	rm -f $(OUTPUT) $(VCD) *.log *.pb *.wdb xsim.dir -rf

# Check syntax only
syntax:
	@if command -v iverilog >/dev/null 2>&1; then \
		iverilog -t null $(SOURCES); \
		echo "Syntax check passed!"; \
	else \
		echo "iverilog not found for syntax checking"; \
	fi

# Run Python verification tools
verify:
	@echo "Running MIPS design verification..."
	@python3 tools/check_mips.py
	@echo ""
	@python3 tools/advanced_mips_verifier.py

# Run comprehensive tests
test: verify
	@echo "Running comprehensive test suite..."
	@python3 tools/final_test.py

# Quick check without simulation
quick-check:
	@echo "Running quick design check..."
	@python3 tools/check_mips.py

.PHONY: all compile run view clean syntax verify test quick-check
