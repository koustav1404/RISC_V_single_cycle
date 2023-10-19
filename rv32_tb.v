`timescale 1ns / 1ps



module rv32_tb();

    wire [31:0]pc;
    reg clk;

    wire [31:0] data_addr;
    wire [31:0] data_out;

    reg [31:0]instruction_memory[0:1023];
    reg [31:0]data_memory[0:1023];

    reg [31:0]instr;
    wire cl = clk;
    wire write;
    
    rv32i_v1 main (instr,write,data_memory[data_addr],data_addr,data_out,clk,pc);

    initial begin
    clk = 0;
    forever #5 clk=~clk;
    end

    initial $readmemh("instr.hex",instruction_memory);
    initial $readmemh("data.hex",data_memory);

    always @(pc)
    begin
        instr = instruction_memory[pc];
    end

    always @(data_addr)
    begin
        data_memory[data_addr] = (write)?data_out:data_memory[data_addr];
    end

    initial begin
    #100
    $writememh("data.hex",data_memory);
    $finish;
    end


endmodule
