module IF_ID (
    input clk,
    input rst,
    
    //Instruction fetch signals
    input [31:0] pc_in,             //seeing the datapath, there are only two signals that enter the IF_ID regiter
    input [31:0] inst_in,
    
    //Instruction decode signals
    output reg [31:0] pc_out,
    output reg [31:0] inst_out
);
    always @(posedge clk) begin
        if (~rst) begin
            pc_out   <= 32'b0;    //reset logic 
            inst_out <= 32'b0; 
        end else begin
            pc_out   <= pc_in;     //dff for pipelining
            inst_out <= inst_in;
        end
    end
endmodule