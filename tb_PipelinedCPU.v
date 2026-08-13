`timescale 1ns / 1ps

module tb_PipelinedCPU();

//inputs to the cpu
    reg clk;
    reg start;

//instantiate the unit under test (uut)
    PipelinedCPU uut (
        .clk(clk),
        .start(start)
    );

//debug wires (hierarchical referencing)
//these grab the array values directly from the register file
    wire [31:0] debug_ra = uut.m_Register.regs[1];
    wire [31:0] debug_t0 = uut.m_Register.regs[5];
    wire [31:0] debug_t1 = uut.m_Register.regs[6];
    wire [31:0] debug_t2 = uut.m_Register.regs[7];
    wire [31:0] debug_t3 = uut.m_Register.regs[28];
    wire [31:0] debug_t4 = uut.m_Register.regs[29];
    wire [31:0] debug_t5 = uut.m_Register.regs[30];
    wire [31:0] debug_t6 = uut.m_Register.regs[31];

//clock generation: 10ns time period (100 mhz)
    always #5 clk = ~clk;

    initial begin
//initialize inputs and assert reset
        clk = 0;
        start = 0; 

//setup waveform dumping
        $dumpfile("pipeline_tb.vcd");
        $dumpvars(0, tb_PipelinedCPU);

//hold reset for a couple of clock cycles
        #15;
        
//release reset and start cpu
        start = 1; 

//let the cpu run
//increased to 500ns (50 cycles) to allow time for all stalls and flushes to resolve
        #500;

//print the final steady-state values to the terminal for instant verification
       
        $display("final register states (steady state):");

        $display("t0 (x5)  = %0d  (expected: 5)", debug_t0);
        $display("t1 (x6)  = %0d (expected: 10)", debug_t1);
        $display("t2 (x7)  = %0d (expected: 15)", debug_t2);
        $display("t3 (x28) = %0d (expected: 15)", debug_t3);
        $display("t4 (x29) = %0d (expected: 15)", debug_t4);
        $display("t6 (x31) = %0d  (expected: 1)", debug_t6);
        $display("t5 (x30) = %0d (expected: 58)", debug_t5);
       

//end simulation
        $finish;
    end

endmodule