# Build and run tests

## Build C-Class

```
$ git clone https://gitlab.com/shaktiproject/cores/c-class.git
$ cd c-class/
$ pip install -r requirements.txt
$ repomanager --yaml $PWD/test_soc/deps.yaml --verbose debug --clean
$ repomanager --yaml $PWD/test_soc/deps.yaml --verbose debug -cup
$ soc_config -ispec sample_config/c64/rv64i_isa.yaml   -customspec sample_config/c64/rv64i_custom.yaml   -cspec sample_config/c64/core64.yaml   -gspec sample_config/c64/csr_grouping64.yaml   -dspec sample_config/c64/rv64i_debug.yaml   --verbose debug
$ export XXD_VERSION=2023
$ make  generate_verilog
$ make link_verilator
$ make generate_boot_files
```

- After the build is completed, the executable binaries can be found at `./c-class/bin` and the verilog files will be at `/home/vsysuser/workspace/c-class/build/hw/verilog` .
- Export the design build
```
export DESIGN_HOME=/home/vsysuser/workspace/c-class/bin
```

## To compile tests

- To compile and run tests on spike
```
make run TEST=<path/to/test>
```

- To run test only on spike
```
make spike TEST=<path/to/test>
```

- To generate disassembly file
```
make disasm TEST=<path/to/test>
```

## To run tests in C-CLASS


```
export DESIGN_HOME=/home/vsysuser/workspace/c-class/bin
make run_dut TEST=<path/to/test>
```

- example `make run_dut TEST=tests/branch.S`

## To clean work dir:
```
make clean TEST=<testname>
```
- example `make clean TEST=branch`


