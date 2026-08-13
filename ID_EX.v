module ID_EX (
    input clk,
    input rst,

    //WB Control Signals
    input regWrite_in,
    input [1:0] memtoReg_in, // 2-bits for your JAL/JALR logic
    
    //MEM Control Signals
    input memRead_in,
    input memWrite_in,
    
    //EX Control Signals
    input ALUSrc_in,
    input [1:0] ALUOp_in,
    
    //Data and Addresses
    input [31:0] pc_in,
    input [31:0] readData1_in,
    input [31:0] readData2_in,
    input [31:0] imm_in,
    
    //Instruction Fields 
    input [4:0] rs1_in,    
    input [4:0] rs2_in,    
    input [4:0] rd_in,     //destination register (MUST travel to the end)
    input [2:0] funct3_in, 
    input funct7_in,       

    //Outputs
    output reg regWrite_out,
    output reg [1:0] memtoReg_out,
    output reg memRead_out,
    output reg memWrite_out,
    output reg ALUSrc_out,
    output reg [1:0] ALUOp_out,
    
    output reg [31:0] pc_out,
    output reg [31:0] readData1_out,
    output reg [31:0] readData2_out,
    output reg [31:0] imm_out,
    
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,
    output reg funct7_out
);
    always @(posedge clk) begin
        if (~rst) begin
            {regWrite_out, memtoReg_out, memRead_out, memWrite_out, ALUSrc_out, ALUOp_out} <= 0;        //reset logic
            {pc_out, readData1_out, readData2_out, imm_out} <= 0;
            {rs1_out, rs2_out, rd_out, funct3_out, funct7_out} <= 0;
        end else begin
            regWrite_out <= regWrite_in;
            memtoReg_out <= memtoReg_in;
            memRead_out  <= memRead_in;
            memWrite_out <= memWrite_in;
            ALUSrc_out   <= ALUSrc_in;
            ALUOp_out    <= ALUOp_in;
            pc_out        <= pc_in;
            readData1_out <= readData1_in;
            readData2_out <= readData2_in;
            imm_out       <= imm_in;
            rs1_out    <= rs1_in;
            rs2_out    <= rs2_in;
            rd_out     <= rd_in;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;
        end
    end
endmodule