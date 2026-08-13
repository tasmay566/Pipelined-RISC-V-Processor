module ALUCtrl (
    input [1:0] ALUOp,
    input funct7, //assuming this is the bit 30 of the instruction format
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    // TODO: implement your ALU ALUCtl here
   // Hint: using ALUOp, funct7, funct3 to select exact operation
always@(*) begin
case(ALUOp)
2'b00: ALUCtl= 4'b0010; //load and store instrcutions  


//creating AluCtl signals for new branch instrcutions based on funct3 field
2'b01: begin
    case(funct3)
    3'b000, 3'b001: ALUCtl= 4'b0110; //beq, bne instruction will have to carry out subtraction
    3'b100, 3'b101: ALUCtl= 4'b0111; /*bge, blt instruction will use slt to check the LSB of Alu result.
                                    If slt=high, blt would be taken. If slt=low then bge taken.*/
    default: ALUCtl= 4'b0110;
    endcase
end


2'b10, 2'b11: begin
case(funct3) 
3'b000:  begin  
    if(funct7 && ALUOp==2'b10) 
        ALUCtl= 4'b0110;   /*if funct7[30]=1 and ALUOp=10 then subtract, since the ALUOp for addi is 11,
        we need to explicity mention that ALUOp has to be 10, otherwise, the funct7[30] would be considered as the immediate value.  
        */
    else ALUCtl= 4'b0010;   //if funct7[30]=0 then add
        end   


3'b001: ALUCtl= 4'b0100;  //shift left logical
3'b010: ALUCtl= 4'b0111;  //set less than 
3'b011: ALUCtl= 4'b0101;  //set less than unsigned
3'b100: ALUCtl= 4'b0011;  //bitwise xor 

3'b101:  begin   
    if(funct7) 
    ALUCtl= 4'b1001;//shift right arithmetic
    else ALUCtl= 4'b1000; //shift right logical
        end



3'b110: ALUCtl= 4'b0001; //bitwise Or
3'b111: ALUCtl= 4'b0000;  //bitwise And

default: ALUCtl= 4'b0000;  //deafult value of ALUOp stays 4'b0000, even though it corresponds to And, it doesnt matter as the regWrite signal wont be asserted.
endcase
end
default:  ALUCtl= 4'b0000;
endcase
end 
endmodule

