module ImmGen#(parameter Width = 32) (
input [Width-1:0] inst,
output reg signed [Width-1:0] imm
);
// ImmGen generate imm value based on opcode

wire [4:0] opcode = inst[6:2];  //the first two bits(LSBs) of every instruction is 11, an hence ignoring the first two LSBs this would reduce hardware
always @(*) 
begin
    case(opcode)
        
        // TODO: implement your ImmGen here
        // Hint: follow the RV32I opcode map table to set imm value


    5'b00000, 5'b00100, 5'b11001: begin  //for load, immediate and Jalr intrcutions.
        imm= {{20{inst[31]}},inst[31:20]}; /*this is concatenation, the msb of the instruction (which happens to be the msb of 
                                            the immediate field as well) is
                                            copied to the remaining 20 bits*/
                                    end
    
    5'b11011:begin   //this is for the jal instruction accrding to the J instruction format
        imm={{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};
    end

    5'b01000:  begin
        imm= {{20{inst[31]}},inst[31:25],inst[11:7]}; /*in this case, since the instruction format of the store instruction is different than the 
                                                        load and immediate instructions, the concatenation line is also diffenrent but the logic is same */
    end

    5'b11000: begin
        imm= {{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0}; /*again, the instruction format of branch is different and the concatenation 
                                                                    has been done accordingly. It is implied that the LSB of the immediate value 
                                                                    is 0 in case of branch instruction(because the destination address is always even), 
                                                                    however, because the shift by 1 module is provided, we do not put 1'b0 at lsb.*/
    end
default: imm=32'd0; // default value of immediate is set to all 0s to prevent any latches.

endcase
end
endmodule