module Control (
input [6:0] opcode,
output  reg branch,
output  reg memRead,
output  reg [1:0] memtoReg, //changing to 2 bits to support PC+4 return address being loaded in a register
output  reg [1:0] ALUOp,
output  reg memWrite,
output  reg ALUSrc,
output  reg regWrite,
output  reg jump,  /*adding two new control signals to control the reg_write mux and the pc_mux
jump is for both jal and jalr whereas jalr is specifiaclly for jalr instruction*/
output  reg jalr
);

// TODO: implement your Control here
// Hint: follow the Architecture to set output signal
always @(*) begin
{branch, memRead, ALUOp, memtoReg,memWrite, ALUSrc, regWrite,jump,jalr}= 0; //initializing these signals so as to prevent any latches.

case(opcode[6:2])  //here, I am ignoring the 2 LSBs of opcode because they are the same for all the instructions, this would reduce the hardware

//branch instruction
5'b11000: begin

ALUOp= 2'b01;  //branch instruction would correspond to ALUOp=01
branch= 1'b1;

end

//load instruction

5'b00000:begin
ALUOp= 2'b00; //load instructions cprrespond to ALUop=00
ALUSrc= 1'b1;  //the ALU needs to take the immediate value (from the immediate generator) which is the offset to the memory address, thats why ALUsrc is asserted.
memRead= 1'b1; //after the calculation of the updated address by ALU, this signal is asserted to get the value of the desired data from the memory address in the data memory.
memtoReg= 2'b01; /*since we need to take the value from the data memory which contains the value to be loaded and not the
updated address calculated by the ALU, we choose the mux select line as 1 */
regWrite= 1'b1; //this is asserted so that the data to be loaded get written onto the desired destination register.
end

//store instruction
5'b01000:begin
ALUOp= 2'b00; //store instructions correspond to ALUop=00
ALUSrc= 1'b1; //the ALU needs to take the immediate value (from the immediate generator) which is the offset to the memory address, thats why ALUsrc is asserted.
memWrite= 1'b1; //after the updated address is calculated by the ALU, the data from the source register is written to the data memory in the address caculated.
end

//immediate instruction
5'b00100: begin
ALUOp= 2'b11;  //register (immediate type) correspond to ALUOp=11
ALUSrc=1'b1; //the ALU takes the immediate value(constant) from the immediate generator instead of the registers and thats  why ALUSrc select line is asserted.
regWrite=1'b1; //after the ALU does the operation, the results needs to be stored in the destination register, hence this signal is asserted.
end

//register-register instruction
5'b01100: begin
ALUOp= 2'b10;  //register (register type) correspond to ALUOp=10
regWrite= 1'b1; //after the ALU does the operation, the results needs to be stored in the destination register, hence this signal is asserted.
end

//jal instruction
5'b11011: begin
jump=1'b1;
memtoReg=2'b10;  //the memtoreg mux will select the PC+4 value to store in return register.
regWrite=1'b1;  //the return address needs to be stored in a register
//note: beacause jal instruction does not use ALU at all, there is no need for giving ALUOp signal.
end

//jalr instruction
5'b11001: begin
ALUOp=2'b00; //here, the jalr resembles the load/store for calculating the effective address and hence, ALUOp is 2'b00
jalr=1'b1;
memtoReg=2'b10;   //the memtoreg mux will select the PC+4 value to store in return register.
regWrite=1'b1;   //the return address needs to be stored in a register
ALUSrc=1'b1;   //ALU needs the input from immediate generator
end

default: {branch, memRead, ALUOp, memtoReg,memWrite, ALUSrc, regWrite, jump,jalr}= 0; //default case to prevent any latches.
endcase

end
endmodule