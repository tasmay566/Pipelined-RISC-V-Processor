module ALU (
    input [3:0] ALUCtl,
    input [31:0] A,B,
    output reg [31:0] ALUOut,
    output zero
);
    // ALU has two operand, it execute different operator based on ALUctl wire 
    // output zero is for determining taking branch or not 

    // TODO: implement your ALU here
    // Hint: you can use operator to implement

always @(*) begin
    
case(ALUCtl) 
// This is the logical unit:
4'b0000: ALUOut= A&B;   //Bitwise And
4'b0001: ALUOut= A|B;   //Bitwise Or
4'b0011: ALUOut= A^B;   //Bitwise Xor

//This is the arithmetic unit:
4'b0010: ALUOut= A+B;  //Add
4'b0110: ALUOut= A-B;   //Subtract

//This is the shift unit:
4'b0100: ALUOut= A<<B[4:0];   //Shift left logical by the amount specified by operand B, since max shift limit is 32, B is 5 bits wide.
4'b1000: ALUOut= A>>B[4:0];   //Shift right logical
4'b1001: ALUOut= $signed(A)>>>B[4:0];   //Shift right arithmetic, it performs right shift along with sign extension.


//This is the set less than (slt) unit:
4'b0101: ALUOut= (A<B)? 32'd1:32'd0;   //(sltu) if operand A is less than operand B, it sets the LSB of output as 1, otherwise 0
4'b0111: ALUOut= ($signed(A) < $signed(B)) ?  32'd1:32'd0;  //set less than signed


default: ALUOut= 32'b0;    //if no operation is specified, the output of alu is all zeros.
endcase
end

assign zero= (ALUOut==0);    //if the output of the ALU is zero, it will assert the Zero flag.
   
endmodule

