module PipelinedCPU (
    input clk,
    input start,
	 output [31:0] final_result
);

//hazard detection wires
wire pcWrite, if_id_write, control_mux_sel, if_id_flush;

//1 INSTRUCTION FETCH (IF) STAGE
wire [31:0] if_pc_input, if_pc_output;
wire [31:0] if_adder1_output;
wire [31:0] if_instruction;

//mux logic for branch resolution and hazard freezing
wire [31:0] next_pc = id_branch_taken ? id_branch_target : if_adder1_output;
assign if_pc_input = pcWrite ? next_pc : if_pc_output;

PC m_PC(
    .clk(clk),
    .rst(start),
    .pc_i(if_pc_input),
    .pc_o(if_pc_output)
);

Adder m_Adder_1(
    .a(if_pc_output),
    .b(32'd4),
    .sum(if_adder1_output)
);

InstructionMemory m_InstMem(
    .readAddr(if_pc_output),
    .inst(if_instruction)
);

//IF/ID PIPELINE REGISTER
wire [31:0] id_pc, id_instruction;

//mux logic to simulate stall and flush behavior
wire [31:0] next_if_id_inst = if_id_flush ? 32'd0 : (if_id_write ? if_instruction : id_instruction);
wire [31:0] next_if_id_pc = if_id_write ? if_pc_output : id_pc;

IF_ID m_IF_ID (
    .clk(clk),
    .rst(start),
    .pc_in(next_if_id_pc),
    .inst_in(next_if_id_inst),
    .pc_out(id_pc),
    .inst_out(id_instruction)
);

//2 INSTRUCTION DECODE (ID) STAGE
wire id_memRead_ctl, id_branch_ctl, id_memWrite_ctl, id_ALUSrc_ctl, id_regWrite_ctl;
wire [1:0] id_memtoReg_ctl, id_ALUOp_ctl;
wire id_jump_ctl, id_jalr_ctl;

Control m_Control(
    .opcode(id_instruction[6:0]),
    .branch(id_branch_ctl),
    .memRead(id_memRead_ctl),
    .memtoReg(id_memtoReg_ctl),
    .ALUOp(id_ALUOp_ctl),
    .memWrite(id_memWrite_ctl),
    .ALUSrc(id_ALUSrc_ctl),
    .regWrite(id_regWrite_ctl),
    .jump(id_jump_ctl),
    .jalr(id_jalr_ctl)
);

//control mux for load-use nop injection
wire ctrl_memRead = control_mux_sel ? id_memRead_ctl : 1'b0;
wire ctrl_branch = control_mux_sel ? id_branch_ctl : 1'b0;
wire ctrl_memWrite = control_mux_sel ? id_memWrite_ctl : 1'b0;
wire ctrl_ALUSrc = control_mux_sel ? id_ALUSrc_ctl : 1'b0;
wire ctrl_regWrite = control_mux_sel ? id_regWrite_ctl : 1'b0;
wire [1:0] ctrl_memtoReg = control_mux_sel ? id_memtoReg_ctl : 2'b00;
wire [1:0] ctrl_ALUOp = control_mux_sel ? id_ALUOp_ctl : 2'b00;

wire [31:0] id_readData1, id_readData2;

Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(wb_regWrite),
    .readReg1(id_instruction[19:15]),
    .readReg2(id_instruction[24:20]),
    .writeReg(wb_rd),
    .writeData(wb_mux_memtoreg_output),
    .readData1(id_readData1),
    .readData2(id_readData2)
);

wire [31:0] id_imm_output;
ImmGen #(.Width(32)) m_ImmGen(
    .inst(id_instruction),
    .imm(id_imm_output)
);

//early branch resolution logic
reg id_branch_taken;
always @(*) begin
    id_branch_taken = 0;
    if (id_jump_ctl || id_jalr_ctl) begin
        id_branch_taken = 1; 
    end else if (id_branch_ctl) begin
        case (id_instruction[14:12]) 
            3'b000: id_branch_taken = (id_readData1 == id_readData2); 
            3'b001: id_branch_taken = (id_readData1 != id_readData2); 
            3'b100: id_branch_taken = ($signed(id_readData1) < $signed(id_readData2)); 
            3'b101: id_branch_taken = ($signed(id_readData1) >= $signed(id_readData2)); 
            default: id_branch_taken = 0;
        endcase
    end
end
wire [31:0] id_branch_target = id_jalr_ctl ? (id_readData1 + id_imm_output) : (id_pc + id_imm_output);

HazardDetectionUnit m_HazardDetection(
    .id_ex_memRead(ex_memRead),
    .id_ex_rd(ex_rd),
    .if_id_rs1(id_instruction[19:15]),
    .if_id_rs2(id_instruction[24:20]),
    .branch_taken(id_branch_taken),
    .pcWrite(pcWrite),
    .if_id_write(if_id_write),
    .control_mux_sel(control_mux_sel),
    .if_id_flush(if_id_flush)
);

//ID/EX PIPELINE REGISTER
wire ex_regWrite, ex_memRead, ex_memWrite, ex_ALUSrc;
wire [1:0] ex_memtoReg, ex_ALUOp;
wire [31:0] ex_pc, ex_readData1, ex_readData2, ex_imm;
wire [4:0] ex_rs1, ex_rs2, ex_rd;
wire [2:0] ex_funct3;
wire ex_funct7;

ID_EX m_ID_EX (
    .clk(clk),
    .rst(start),
    .regWrite_in(ctrl_regWrite),
    .memtoReg_in(ctrl_memtoReg),
    .memRead_in(ctrl_memRead),
    .memWrite_in(ctrl_memWrite),
    .ALUSrc_in(ctrl_ALUSrc),
    .ALUOp_in(ctrl_ALUOp),
    .pc_in(id_pc),
    .readData1_in(id_readData1),
    .readData2_in(id_readData2),
    .imm_in(id_imm_output),
    .rs1_in(id_instruction[19:15]),
    .rs2_in(id_instruction[24:20]),
    .rd_in(id_instruction[11:7]),
    .funct3_in(id_instruction[14:12]),
    .funct7_in(id_instruction[30]),
    .regWrite_out(ex_regWrite),
    .memtoReg_out(ex_memtoReg),
    .memRead_out(ex_memRead),
    .memWrite_out(ex_memWrite),
    .ALUSrc_out(ex_ALUSrc),
    .ALUOp_out(ex_ALUOp),
    .pc_out(ex_pc),
    .readData1_out(ex_readData1),
    .readData2_out(ex_readData2),
    .imm_out(ex_imm),
    .rs1_out(ex_rs1),
    .rs2_out(ex_rs2),
    .rd_out(ex_rd),
    .funct3_out(ex_funct3),
    .funct7_out(ex_funct7)
);

//3 EXECUTE (EX) STAGE
wire [1:0] forwardA, forwardB;

ForwardingUnit m_ForwardingUnit(
    .ex_mem_regWrite(mem_regWrite),
    .ex_mem_rd(mem_rd),
    .mem_wb_regWrite(wb_regWrite),
    .mem_wb_rd(wb_rd),
    .id_ex_rs1(ex_rs1),
    .id_ex_rs2(ex_rs2),
    .forwardA(forwardA),
    .forwardB(forwardB)
);

//forwarding multiplexers for alu inputs
wire [31:0] forwardA_out = (forwardA == 2'b10) ? mem_aluResult : 
                           (forwardA == 2'b01) ? wb_mux_memtoreg_output : ex_readData1;
                           
wire [31:0] forwardB_out = (forwardB == 2'b10) ? mem_aluResult : 
                           (forwardB == 2'b01) ? wb_mux_memtoreg_output : ex_readData2;

wire [31:0] ex_mux_alu_output;
Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ex_ALUSrc),
    .s0(forwardB_out),
    .s1(ex_imm),
    .out(ex_mux_alu_output)
);

wire [3:0] ex_alu_ctl;
ALUCtrl m_ALUCtrl(
    .ALUOp(ex_ALUOp),
    .funct7(ex_funct7),
    .funct3(ex_funct3),
    .ALUCtl(ex_alu_ctl)
);

wire [31:0] ex_alu_output;
wire ex_zero; 
ALU m_ALU(
    .ALUCtl(ex_alu_ctl),
    .A(forwardA_out),
    .B(ex_mux_alu_output),
    .ALUOut(ex_alu_output),
    .zero(ex_zero)
);

//EX/MEM PIPELINE REGISTER
wire mem_regWrite, mem_memRead, mem_memWrite;
wire [1:0] mem_memtoReg;
wire [31:0] mem_aluResult, mem_writeData, mem_pc;
wire [4:0] mem_rd;

EX_MEM m_EX_MEM (
    .clk(clk),
    .rst(start),
    .regWrite_in(ex_regWrite),
    .memtoReg_in(ex_memtoReg),
    .memRead_in(ex_memRead),
    .memWrite_in(ex_memWrite),
    .aluResult_in(ex_alu_output),
    .writeData_in(forwardB_out),
    .rd_in(ex_rd),
    .pc_in(ex_pc),
    .regWrite_out(mem_regWrite),
    .memtoReg_out(mem_memtoReg),
    .memRead_out(mem_memRead),
    .memWrite_out(mem_memWrite),
    .aluResult_out(mem_aluResult),
    .writeData_out(mem_writeData),
    .rd_out(mem_rd),
    .pc_out(mem_pc)
);

//4 MEMORY (MEM) STAGE
wire [31:0] mem_readData;

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(mem_memWrite),
    .memRead(mem_memRead),
    .address(mem_aluResult),
    .writeData(mem_writeData),
    .readData(mem_readData)
);

//MEM/WB PIPELINE REGISTER
wire wb_regWrite;
wire [1:0] wb_memtoReg;
wire [31:0] wb_readData, wb_aluResult, wb_pc;
wire [4:0] wb_rd;

MEM_WB m_MEM_WB (
    .clk(clk),
    .rst(start),
    .regWrite_in(mem_regWrite),
    .memtoReg_in(mem_memtoReg),
    .readData_in(mem_readData),
    .aluResult_in(mem_aluResult),
    .rd_in(mem_rd),
    .pc_in(mem_pc),
    .regWrite_out(wb_regWrite),
    .memtoReg_out(wb_memtoReg),
    .readData_out(wb_readData),
    .aluResult_out(wb_aluResult),
    .rd_out(wb_rd),
    .pc_out(wb_pc)
);

//5 WRITEBACK (WB) STAGE
wire [31:0] wb_mem_alu_result;
Mux2to1 #(.size(32)) m_Mux_WriteData_Mem(
    .sel(wb_memtoReg[0]),
    .s0(wb_aluResult),
    .s1(wb_readData),
    .out(wb_mem_alu_result)
);

wire [31:0] wb_mux_memtoreg_output;
Mux2to1 #(.size(32)) m_Mux_WriteData_PC( 
    .sel(wb_memtoReg[1]),
    .s0(wb_mem_alu_result),
    .s1(wb_pc + 32'd4),
    .out(wb_mux_memtoreg_output)
);
assign final_result = wb_mux_memtoreg_output;  

endmodule