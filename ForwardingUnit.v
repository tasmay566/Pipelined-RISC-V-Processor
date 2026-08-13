//forwarding unit
module ForwardingUnit(
    input ex_mem_regWrite,
    input [4:0] ex_mem_rd,
    input mem_wb_regWrite,
    input [4:0] mem_wb_rd,
    input [4:0] id_ex_rs1,
    input [4:0] id_ex_rs2,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    //evaluating forwarding conditions
    always @(*) begin
        //default to no forwarding
        forwardA = 2'b00;
        forwardB = 2'b00;


    //following is the combinatinal logic for forwarding 
        //ex hazard for rs1
        if (ex_mem_regWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs1)) begin
            forwardA = 2'b10;
        end
        //mem hazard for rs1
        else if (mem_wb_regWrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs1)) begin
            forwardA = 2'b01;
        end

        //ex hazard for rs2
        if (ex_mem_regWrite && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs2)) begin
            forwardB = 2'b10;
        end
        //mem hazard for rs2
        else if (mem_wb_regWrite && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs2)) begin
            forwardB = 2'b01;
        end
    end
endmodule