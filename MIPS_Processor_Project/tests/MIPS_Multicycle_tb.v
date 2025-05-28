// Testbench for MIPS Multi-cycle Processor
`include "definitions.vh"

module MIPS_Multicycle_tb();

    reg clk;
    reg rst;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Reset generation
    initial begin
        rst = 1;
        #20 rst = 0;
    end
    
    // DUT instantiation
    MIPS_Multicycle cpu(
        .clk(clk),
        .rst(rst)
    );
    
    // Monitor signals
    initial begin
        $dumpfile("mips_multicycle.vcd");
        $dumpvars(0, MIPS_Multicycle_tb);
        
        // Display header
        $display("Time\tPC\tInstr\t\tState\tRegWrite\tRegData");
        $display("----\t--\t-----\t\t-----\t--------\t-------");
        
        // Monitor execution
        $monitor("%4t\t%h\t%h\t%d\t%b\t\t%h", 
                 $time, cpu.pc_reg, cpu.instruction_reg, 
                 cpu.current_state, cpu.reg_write, cpu.write_data);
        
        // Run simulation
        #2000;
        
        // Display register file contents
        $display("\nRegister File Contents:");
        for (integer i = 0; i < 32; i = i + 1) begin
            if (cpu.regfile.registers[i] != 0) begin
                $display("R%2d = %h", i, cpu.regfile.registers[i]);
            end
        end
        
        $finish;
    end
    
    // Optional: Load a test program
    initial begin
        // Wait for reset
        #25;
        
        // Load test instructions into instruction memory
        cpu.imem.memory[0] = 32'h20020005;  // addi $2, $0, 5
        cpu.imem.memory[1] = 32'h20030003;  // addi $3, $0, 3  
        cpu.imem.memory[2] = 32'h00432020;  // add $4, $2, $3
        cpu.imem.memory[3] = 32'h00432022;  // sub $4, $2, $3
        cpu.imem.memory[4] = 32'h3402000F;  // ori $2, $0, 15
        cpu.imem.memory[5] = 32'h3C020001;  // lui $2, 1
        cpu.imem.memory[6] = 32'h0043202A;  // slt $4, $2, $3
        cpu.imem.memory[7] = 32'h08000007;  // j 7 (jump to self)
        
        $display("Test program loaded into instruction memory");
    end

endmodule
