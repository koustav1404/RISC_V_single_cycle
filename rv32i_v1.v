



module rv32i_v1(instr,write,data_in,data_addr,data_out,clk,pc);
    input [31:0] instr;
    input  clk;
    output reg[31:0]pc;
    initial pc = 32'h00000000;
    
    //Data Memory interface
    output reg write;
    input [31:0] data_in;
    output reg [31:0] data_addr;
    output reg [31:0] data_out;

    //Register File
    reg [31:0]r[0:31];
    initial  r[0] = 32'h00000000;


    //jump or branch flag
    reg jmp_br; 
    initial jmp_br = 1'b0;

    //Instruction breakdown
    `define opcode  instr[6:0]
    `define rd  instr[11:7]
    `define func3  instr[14:12]
    `define rs1  instr[19:15]
    `define rs2  instr[24:20]
    `define func7  instr[31:25]
    `define Uimm  {instr[31],instr[30:12],{12{1'b0}}}
    `define Iimm  {{21{instr[31]}},instr[30:20]}
    `define Simm  {{21{instr[31]}},instr[30:25],instr[11:7]}
    `define Bimm  {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0}
    `define BimmU  {{19{1'b0}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0}
    `define Jimm  {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0}
    
    //Instruction types
    `define isALUreg    7'b0110011
    `define isALUimm    7'b0010011 
    `define isBranch    7'b1100011 
    `define isJALR      7'b1100111 
    `define isJAL       7'b1101111 
    `define isAUIPC     7'b0010111 
    `define isLUI       7'b0110111   
    `define isLoad      7'b0000011 
    `define isStore     7'b0100011 
    

    always @(posedge clk ) begin
        if (~jmp_br)pc = pc + 1;
    end
        
    always @(instr) 
    begin
        case (`opcode)
        `isALUreg:
        begin
        jmp_br = 1'b0;
        write = 1'b0;
        data_addr = 32'hZZZZZZZZ;
        data_out = 32'hZZZZZZZZ;
        if (`rd == 5'b00000)
        r[0] = 32'h00000000;
        else
        begin
        case(`func3)
	        3'b000: r[`rd] = (instr[30] & instr[5]) ? (r[`rs1]-r[`rs2]) : (r[`rs1]+r[`rs2]);
	        3'b001: r[`rd] = r[`rs1] << r[`rs2][4:0];
	        3'b010: r[`rd] = ($signed(r[`rs1]) < $signed(r[`rs2]));
	        3'b011: r[`rd] = (r[`rs1] < r[`rs2]);
	        3'b100: r[`rd] = (r[`rs1] ^ r[`rs2]);
	        3'b101: r[`rd] = instr[31]? ($signed(r[`rs1]) >>> r[`rs2][4:0]) : (r[`rs1] >> r[`rs2][4:0]); 
	        3'b110: r[`rd] = (r[`rs1] | r[`rs2]);
	        3'b111: r[`rd] = (r[`rs1] & r[`rs2]);	
        endcase
        end
        end
        `isALUimm:
        begin
        jmp_br = 1'b0;
        write = 1'b0;
        data_addr = 32'hZZZZZZZZ;
        data_out = 32'hZZZZZZZZ;
        if (`rd == 5'b00000)
        r[0] = 32'h00000000;
        else
        begin
        case(`func3)
	        3'b000: r[`rd] = (instr[30] & instr[5]) ? (r[`rs1]-`Iimm) : (r[`rs1]+`Iimm);
	        3'b001: r[`rd] = r[`rs1] << instr[24:20];
	        3'b010: r[`rd] = ($signed(r[`rs1]) < $signed(`Iimm));
	        3'b011: r[`rd] = (r[`rs1] < `Iimm);
	        3'b100: r[`rd] = (r[`rs1] ^ `Iimm);
	        3'b101: r[`rd] = instr[31]? ($signed(r[`rs1]) >>> instr[24:20]) : (r[`rs1] >> instr[24:20]); 
	        3'b110: r[`rd] = (r[`rs1] | `Iimm);
	        3'b111: r[`rd] = (r[`rs1] & `Iimm);	
        endcase
        end
        end
        `isLoad:
        begin
        jmp_br = 1'b0;
        write = 1'b0;
        data_addr = r[`rs1]+`Iimm;
        if (`rd == 5'b00000)
        r[0] = 32'h00000000;
        else
        begin
        case(`func3)
            3'b000: r[`rd] = {{24{data_in[7]}},data_in[7:0]}; 
            3'b001: r[`rd] = {{16{data_in[15]}},data_in[15:0]}; 
            3'b010: r[`rd] = data_in;
            3'b100: r[`rd] = {24'h000000,data_in[7:0]}; 
            3'b101: r[`rd] = {16'h0000,data_in[15:0]}; 
        endcase
        end
        end
        `isStore:
        begin
        data_addr = r[`rs1]+`Simm;
        jmp_br = 1'b0;
        write = 1'b1;
        if (`rd == 5'b00000)
        r[0] = 32'h00000000;
        else
        begin
        case(`func3)
            3'b000: data_out = {{24{r[`rs2][7]}},r[`rs2][7:0]}; 
            3'b001: data_out = {{16{r[`rs2][15]}},r[`rs2][15:0]}; 
            3'b010: data_out = r[`rs2]; 
        endcase
        end
        end
        `isBranch:
        begin
        write = 1'b0;
            case(`func3)
            3'b000: begin  if (r[`rs1] == r[`rs2]) begin jmp_br = 1'b1; pc = pc + `Bimm; end end
            3'b001: begin  if (r[`rs1] != r[`rs2]) begin jmp_br = 1'b1; pc = pc + `Bimm; end end
            3'b100: begin  if (r[`rs1] < r[`rs2]) begin jmp_br = 1'b1; pc = pc + `Bimm; end end
            3'b101: begin  if (r[`rs1] >= r[`rs2]) begin jmp_br = 1'b1; pc = pc + `Bimm; end end
            3'b110: begin  if (r[`rs1] < r[`rs2]) begin jmp_br = 1'b1; pc = pc + `Bimm; end end
            3'b000: begin  if (r[`rs1] >= r[`rs2]) begin jmp_br = 1'b1; pc = pc + `Bimm; end end
            endcase
        end
        `isJAL:
        begin
            write = 1'b0;
            jmp_br = 1'b1; 
            r[`rd] = (`rd == 5'b00000) ? 32'h00000000:(pc+1);
            pc = pc + `Jimm;
        end
        `isJALR:
        begin
            write = 1'b0;
            jmp_br = 1'b1; 
            r[`rd] = (`rd == 5'b00000) ? 32'h00000000:(pc+1);
            pc = r[`rs1] + `Iimm;
        end
        `isLUI:
        begin
            write = 1'b0;
            jmp_br = 1'b0;
            r[`rd] = (`rd == 5'b00000) ? 32'h00000000:`Uimm;
        end
        `isAUIPC:
        begin
            write = 1'b0;
            jmp_br = 1'b0;
            r[`rd] = (`rd == 5'b00000) ? 32'h00000000:(pc+`Uimm);
        end
        default: begin
            jmp_br = 1'b0;
            write = 1'b0;
            data_addr = 32'hZZZZZZZZ;
            data_out = 32'hZZZZZZZZ;
        end
    endcase
    end    

     
endmodule
