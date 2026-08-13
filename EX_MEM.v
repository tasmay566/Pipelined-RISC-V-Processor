module EX_MEM (
    input clk,
    input rst,

    // WB Control Signals (Passed straight through)
    input regWrite_in,
    input [1:0] memtoReg_in,

    // MEM Control Signals (Consumed in the next stage)
    input memRead_in,
    input memWrite_in,

    // Data 
    input [31:0] aluResult_in, // The calculated memory address or math result
    input [31:0] writeData_in, // The rs2 data to be written to memory (for store instructions)
    
    // Pass-throughs
    input [4:0] rd_in,         
    input [31:0] pc_in,        // Passed down so WB stage can do PC+4 for JAL/JALR

    // Outputs
    output reg regWrite_out,
    output reg [1:0] memtoReg_out,
    output reg memRead_out,
    output reg memWrite_out,
    
    output reg [31:0] aluResult_out,
    output reg [31:0] writeData_out,
    output reg [4:0] rd_out,
    output reg [31:0] pc_out
);
    always @(posedge clk) begin
        if (~rst) begin
            {regWrite_out, memtoReg_out, memRead_out, memWrite_out} <= 0;
            {aluResult_out, writeData_out, pc_out} <= 0;
            rd_out <= 5'b0;
        end else begin
            regWrite_out  <= regWrite_in;
            memtoReg_out  <= memtoReg_in;
            memRead_out   <= memRead_in;
            memWrite_out  <= memWrite_in;
            aluResult_out <= aluResult_in;
            writeData_out <= writeData_in;
            rd_out        <= rd_in;
            pc_out        <= pc_in;
        end
    end
endmodule