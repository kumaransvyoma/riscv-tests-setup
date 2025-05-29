# Makefile for compiling and running RISC-V test on Spike

ifndef TEST
$(error TEST is not set. Please run: export TEST=/path/to/test_file.S)
endif

# Variables (override TEST on the command line)
# TEST      ?= test.S
FILENAME  := $(basename $(notdir $(TEST)))
TEST_HOME := $(CURDIR)
OUT_DIR   := $(TEST_HOME)/work/$(FILENAME)

# Tools
GCC       := riscv64-unknown-elf-gcc
OBJDUMP   := riscv64-unknown-elf-objdump
SPIKE     := spike
TIMEOUT   := timeout --foreground 6s

# Compiler/linker options
CFLAGS    := -march=rv64imafdc -mabi=lp64 -static -mcmodel=medany -fvisibility=hidden \
             -nostdlib -nostartfiles -DENTROPY=0x9629af2 -std=gnu99 -O2 \
             -I$(TEST_HOME)/env -T$(TEST_HOME)/env/link.ld

# Targets
.PHONY: all run disasm spike clean

all: run

run: $(OUT_DIR)/$(FILENAME).elf
	@$(MAKE) --no-print-directory disasm
	@$(MAKE) --no-print-directory spike
	@echo "-------------------------------------------------------------------------"
	@echo "DONE"
	@echo "-------------------------------------------------------------------------"

$(OUT_DIR)/$(FILENAME).elf: $(TEST)
	@echo "-------------------------------------------------------------------------"
	@echo "Compiling $(TEST)"
	@echo "-------------------------------------------------------------------------"
	mkdir -p $(OUT_DIR)
	rm -rf $(OUT_DIR)/*
	$(GCC) $(CFLAGS) $< -o $@

disasm: $(OUT_DIR)/$(FILENAME).elf
	@echo "-------------------------------------------------------------------------"
	@echo "Disassembly Generation"
	@echo "-------------------------------------------------------------------------"
	$(OBJDUMP) --disassemble-all --disassemble-zeroes \
		--section=.text --section=.text.startup --section=.text.init --section=.data \
		$< > $(OUT_DIR)/$(FILENAME).disass
	@echo "-------------------------------------------------------------------------"
	
spike: $(OUT_DIR)/$(FILENAME).elf
	@echo "-------------------------------------------------------------------------"
	@echo "Running on Spike"
	@echo "-------------------------------------------------------------------------"
	$(TIMEOUT) $(SPIKE) --log-commits --log $(OUT_DIR)/$(FILENAME).dump \
		--isa=rv64gc +signature=spike_signature.txt +signature-granularity=4 $<
	@echo "-------------------------------------------------------------------------"

clean:
	@echo "Cleaning $(CURDIR)/work/$(FILENAME)"
	rm -rf $(CURDIR)/work/$(FILENAME)

# cleanall:
# 	@echo "Cleaning all work directories"
# 	rm -rf $(CURDIR)/work/*


run_dut: $(OUT_DIR)/$(FILENAME).elf
	@if [ -z "$(DESIGN_HOME)" ]; then \
		echo "ERROR: DESIGN_HOME is not set. Please export it."; \
		exit 1; \
	fi
	@echo "-------------------------------------------------------------------------"
	@echo "Running Tests on C-CLASS "
	@echo "-------------------------------------------------------------------------"
	@echo "Copying design files from $(DESIGN_HOME)"
	cp -r "$(DESIGN_HOME)"/. $(OUT_DIR)/
	elf2hex  8  4194304  $(OUT_DIR)/$(FILENAME).elf 2147483648 > $(OUT_DIR)/code.mem
	cd $(OUT_DIR) && \
	timeout --foreground 6s ./out +rtldump