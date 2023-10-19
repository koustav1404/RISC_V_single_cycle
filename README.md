# RISC_V_single_cycle


* Make sure you have iverilog installed
* use an online assembler to generate your hex code of your program and put it in the instr.hex file
* program counter starts from 0x00000000 location so make sure your program is placed accordingly
* place your data in appropriate memory locations in the data.hex file
* you can run the mem.py script to set both instruction and data memory to zero

# To run your program

* open cmd
* type "iverilog -o cpu  rv32_tb.v rv32i_v1.v"
* then "vvp cpu"
* after running your program check your data.hex file for the changes
