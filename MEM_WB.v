module MEM_WB (
    input clk,
    input rst,

    // WB Control Signals (Finally consumed!)
    input regWrite_in,
    input [1:0] memtoReg_in,

    // Data
    input [31:0] readData_in,  // The data retrieved from DataMemory
    input [31:0] aluResult_in, // Bypassed arithmetic result from EX_MEM
    
    // Pass-throughs
    input [4:0] rd_in,         // The destination register address has finally arrived!
    input [31:0] pc_in,        // To calculate PC+4

    // Outputs
    output reg regWrite_out,
    output reg [1:0] memtoReg_out,
    
    output reg [31:0] readData_out,
    output reg [31:0] aluResult_out,
    output reg [4:0] rd_out,
    output reg [31:0] pc_out
);
    always @(posedge clk) begin
        if (~rst) begin
            {regWrite_out, memtoReg_out} <= 0;
            {readData_out, aluResult_out, pc_out} <= 0;
            rd_out <= 5'b0;
        end else begin
            regWrite_out  <= regWrite_in;
            memtoReg_out  <= memtoReg_in;
            readData_out  <= readData_in;
            aluResult_out <= aluResult_in;
            rd_out        <= rd_in;
            pc_out        <= pc_in;
        end
    end
endmodule