
TEST_HOME=$PWD
FILENAME=$(basename "$1" .S)
OUT_DIR=$PWD/work/$FILENAME
mkdir -p $OUT_DIR
rm -rf $OUT_DIR/*
cd $OUT_DIR
echo "run.sh | Running Test : $1 "

echo "-------------------------------------------------------------------------"
echo Compiling using riscv-gcc
echo "-------------------------------------------------------------------------"

echo "run.sh | riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -DENTROPY=0x9629af2 -std=gnu99 -O2 -I$TEST_HOME/env -T$TEST_HOME/env/link.ld $TEST_HOME/$1 -o $OUT_DIR/$FILENAME.elf"
riscv64-unknown-elf-gcc -march=rv64imafdc -mabi=lp64 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -DENTROPY=0x9629af2 -std=gnu99 -O2 -I$TEST_HOME/env -T$TEST_HOME/env/link.ld $TEST_HOME/$1 -o $OUT_DIR/$FILENAME.elf

echo "-------------------------------------------------------------------------"
echo Disassembly Generation
echo "-------------------------------------------------------------------------"

echo "run.sh | riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data $OUT_DIR/$FILENAME.elf > $OUT_DIR/$FILENAME.disass"
riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data $OUT_DIR/$FILENAME.elf > $OUT_DIR/$FILENAME.disass

echo "-------------------------------------------------------------------------"
echo Running on Spike
echo "-------------------------------------------------------------------------"

echo "run.sh | timeout --foreground 60s spike  --log-commits --log  $OUT_DIR/$FILENAME.dump --isa=rv64gc +signature=spike_signature.txt +signature-granularity=4 $OUT_DIR/$FILENAME.elf"
timeout --foreground 60s spike  --log-commits --log  $OUT_DIR/$FILENAME.dump --isa=rv64gc +signature=spike_signature.txt +signature-granularity=4 $OUT_DIR/$FILENAME.elf

echo "-------------------------------------------------------------------------"
echo DONE
echo "-------------------------------------------------------------------------"
cd $TEST_HOME

