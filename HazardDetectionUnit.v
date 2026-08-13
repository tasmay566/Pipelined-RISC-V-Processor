//hazard detection unit
module HazardDetectionUnit(
    input id_ex_memRead,
    input [4:0] id_ex_rd,
    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,
    input branch_taken,
    output reg pcWrite,
    output reg if_id_write,
    output reg control_mux_sel,
    output reg if_id_flush
);
    //checking for load-use hazard
    always @(*) begin
        if (id_ex_memRead && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            //stall the pipeline by freezing pc and if/id, and injecting a nop
            pcWrite = 0;
            if_id_write = 0;
            control_mux_sel = 0;
            if_id_flush = 0;
        end else if (branch_taken) begin
            //flush the if/id register on a taken branch
            pcWrite = 1;
            if_id_write = 1;
            control_mux_sel = 1;
            if_id_flush = 1;
        end else begin
            //normal sequential execution
            pcWrite = 1;
            if_id_write = 1;
            control_mux_sel = 1;
            if_id_flush = 0;
        end
    end
endmodule