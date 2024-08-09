Get risc-v tests
----------------

~~~
git clone https://github.com/riscv/riscv-compliance.git
cd riscv-compliance
git checkout 798477ad5583b8017692cf30fc8bc1637ab0fa0a
cd ..
~~~

Test riscv-potin
----------------

~~~
# install riscv potin specific things
rm -rf                   riscv-compliance/riscv-target/potin
cp -r riscv-target/potin riscv-compliance/riscv-target/potin

cd riscv-compliance

## Target riscv-potin

# requirement
#   - RISC-V toolchain (see ../../README.mkd to set your PATH)
#   - vsim in your PATHH (modelsim/questasim)

# populate the work library of the design under test
make -C ../../RV32I_Monocycle

# only a simple test
make RISCV_DEVICE=rv32i RISCV_TARGET=potin RISCV_ISA=rv32i RISCV_TEST=I-IO simulate
make RISCV_DEVICE=rv32i RISCV_TARGET=potin RISCV_ISA=rv32i RISCV_TEST=I-IO verify

# all tests: launch simulations
make RISCV_DEVICE=rv32i RISCV_TARGET=potin RISCV_ISA=rv32i simulate
# all tests: Simon version to print results
(
  echo "Test;Signature;Return"
  for F in riscv-test-suite/rv32i/references/*.reference_output ; do
    TEST="$(echo $F | sed -n 's/^riscv-test-suite\/rv32i\/references\/\(.\+\)\.reference_output$/\1/p')"
    
    SIGNATURE="Unknown"
    if [ -e "work/rv32i/$TEST.signature.output" ] ; then
      if diff --strip-trailing-cr "$F" "work/rv32i/$TEST.signature.output" >/dev/null ; then
        SIGNATURE="Success"
      else
        SIGNATURE="Failure"
      fi
    fi

    RETURN="Unknown"
    if [ -e "work/rv32i/$TEST.vsim.transcript" ] ; then
      if cat "work/rv32i/$TEST.vsim.transcript" | sed -n 's/^.*end of simulation: *\<\([^ \t]\+\)\>.*$/\1/p' | grep -qi success ; then
        RETURN="Success"
      else
        if cat "work/rv32i/$TEST.vsim.transcript" | sed -n 's/^.*end of simulation: *\<\([^ \t]\+\)\>.*$/\1/p' | grep -qi failure ; then
          RETURN="Failure"
          if [ -e "work/rv32i/$TEST.stdout" ] ; then
            ASSERT=$(cat "work/rv32i/$TEST.stdout" | grep -i 'Assertion violation')
            if [ ! -z "$ASSERT" ] ; then
              RETURN="Failure: $ASSERT"
            fi
          fi
        else
          if cat "work/rv32i/$TEST.vsim.transcript" | sed -n 's/^.*end of simulation: *\<\([^ \t]\+\)\>.*$/\1/p' | grep -qi timeout ; then
            RETURN="Timeout"
          fi
        fi
      fi
    fi
  
    echo "$TEST;$SIGNATURE;$RETURN"
  done
) | column -xts ';'

# to debug a test you can find informations inside the ./work/rv32i
# in files prefixed by the test names
#   - *.asm to see annoted assembler
#   - *.gui.cmd to launch vsim gui for a specfic test
~~~



Test a simulator
----------------

~~~
cd riscv-compliance

## Target is the default simulator

# execute only I-IO test
make RISCV_PREFIX=riscv-none-embed- RISCV_DEVICE=rv32i RISCV_TARGET=riscvOVPsim RISCV_ISA=rv32i RISCV_TEST=I-IO simulate
# verify
make RISCV_PREFIX=riscv-none-embed- RISCV_DEVICE=rv32i RISCV_TARGET=riscvOVPsim RISCV_ISA=rv32i RISCV_TEST=I-IO verify

# execute only I-IO test + verify
make RISCV_PREFIX=riscv-none-embed- RISCV_DEVICE=rv32i RISCV_TARGET=riscvOVPsim RISCV_ISA=rv32i RISCV_TEST=I-IO
# execute all tests + verify
make RISCV_PREFIX=riscv-none-embed- RISCV_DEVICE=rv32i RISCV_TARGET=riscvOVPsim RISCV_ISA=rv32i
~~~

Test pulpino
------------

~~~
## Target is pulpino 4-stage pipeline (RI5CY)
cd /path/to/somewhere
  git clone https://github.com/pulp-platform/riscv.git riscv-ri5cy
  cd riscv-ri5cy/tb/core/
  git checkout pulpissimo-v3.4.0
  sed 's/-$(VVERSION)//' -i Makefile
  source  /opt/shrc_modelsim_10.5e
  make vsim-all
  RI5CY_WORK=$(readlink -f work/)
cd -

cd riscv-compliance

make RISCV_PREFIX=riscv-none-embed- RISCV_DEVICE=rv32imc RISCV_TARGET=ri5cy RISCV_ISA=rv32i RISCV_TEST=I-IO TARGET_SIM="vsim -work $RI5CY_WORK" simulate
make RISCV_PREFIX=riscv-none-embed- RISCV_DEVICE=rv32imc RISCV_TARGET=ri5cy RISCV_ISA=rv32i RISCV_TEST=I-IO TARGET_SIM="vsim -work $RI5CY_WORK" verify
~~~
