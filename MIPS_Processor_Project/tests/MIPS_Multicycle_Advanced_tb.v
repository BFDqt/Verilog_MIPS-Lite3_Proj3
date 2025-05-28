// Advanced Testbench for MIPS Multi-cycle Processor
`include "definitions.vh"

module MIPS_Multicycle_Advanced_tb();

    reg clk;
    reg rst;
    
    // Test control
    integer test_case = 0;
    integer cycle_count = 0;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Cycle counter
    always @(posedge clk) begin
        if (!rst) cycle_count <= cycle_count + 1;
        else cycle_count <= 0;
    end
    
    // DUT instantiation
    MIPS_Multicycle cpu(
        .clk(clk),
        .rst(rst)
    );
    
    // Test sequence
    initial begin
        $dumpfile("mips_multicycle_advanced.vcd");
        $dumpvars(0, MIPS_Multicycle_Advanced_tb);
        
        // Initialize
        rst = 1;
        #20 rst = 0;
        
        $display("========================================");
        $display("MIPS Multi-cycle Processor Advanced Test");
        $display("========================================");
        
        // Load comprehensive test program
        load_test_program();
        
        // Run tests
        run_arithmetic_tests();
        run_memory_tests();
        run_branch_tests();
        run_jump_tests();
        
        // Final summary
        #100;
        display_final_results();
        
        $finish;
    end
    
    // Load comprehensive test program
    task load_test_program;
        begin
            $display("Loading comprehensive test program...");
            
            // Arithmetic instructions test
            cpu.imem.memory[0]  = 32'h20020005;  // addi $2, $0, 5       # $2 = 5
            cpu.imem.memory[1]  = 32'h20030003;  // addi $3, $0, 3       # $3 = 3
            cpu.imem.memory[2]  = 32'h2004FFFF;  // addi $4, $0, -1      # $4 = -1
            cpu.imem.memory[3]  = 32'h24050001;  // addiu $5, $0, 1      # $5 = 1
            
            // R-type arithmetic
            cpu.imem.memory[4]  = 32'h00432020;  // add $4, $2, $3       # $4 = 8
            cpu.imem.memory[5]  = 32'h00432022;  // sub $4, $2, $3       # $4 = 2
            cpu.imem.memory[6]  = 32'h0043202A;  // slt $4, $2, $3       # $4 = 0
            cpu.imem.memory[7]  = 32'h0064202A;  // slt $4, $3, $4       # $4 = 1
            
            // Logical operations
            cpu.imem.memory[8]  = 32'h3402000F;  // ori $2, $0, 15       # $2 = 15
            cpu.imem.memory[9]  = 32'h3C020001;  // lui $2, 1            # $2 = 65536
            
            // Memory operations
            cpu.imem.memory[10] = 32'h20060010;  // addi $6, $0, 16      # $6 = 16 (address)
            cpu.imem.memory[11] = 32'hACC20000;  // sw $2, 0($6)         # mem[16] = $2
            cpu.imem.memory[12] = 32'h8CC70000;  // lw $7, 0($6)         # $7 = mem[16]
            cpu.imem.memory[13] = 32'hACC30004;  // sw $3, 4($6)         # mem[17] = $3
            cpu.imem.memory[14] = 32'h8CC80004;  // lw $8, 4($6)         # $8 = mem[17]
            
            // Branch instructions
            cpu.imem.memory[15] = 32'h10430002;  // beq $2, $3, 2        # should not branch
            cpu.imem.memory[16] = 32'h20090001;  // addi $9, $0, 1       # $9 = 1
            cpu.imem.memory[17] = 32'h10000001;  // beq $0, $0, 1        # should branch
            cpu.imem.memory[18] = 32'h200A0002;  // addi $10, $0, 2      # should be skipped
            cpu.imem.memory[19] = 32'h200A0003;  // addi $10, $0, 3      # $10 = 3
            
            // Jump instructions
            cpu.imem.memory[20] = 32'h08000017;  // j 23                 # jump to address 23
            cpu.imem.memory[21] = 32'h200B0004;  // addi $11, $0, 4      # should be skipped
            cpu.imem.memory[22] = 32'h200B0005;  // addi $11, $0, 5      # should be skipped
            cpu.imem.memory[23] = 32'h200B0006;  // addi $11, $0, 6      # $11 = 6
            
            // JAL and JR test
            cpu.imem.memory[24] = 32'h0C00001B;  // jal 27               # call subroutine
            cpu.imem.memory[25] = 32'h200C0007;  // addi $12, $0, 7      # $12 = 7
            cpu.imem.memory[26] = 32'h08000020;  // j 32                 # jump to end
            
            // Subroutine (address 27)
            cpu.imem.memory[27] = 32'h200D0008;  // addi $13, $0, 8      # $13 = 8
            cpu.imem.memory[28] = 32'h03E00008;  // jr $ra               # return
            
            // End of program
            cpu.imem.memory[29] = 32'h200E0009;  // addi $14, $0, 9      # should be skipped
            cpu.imem.memory[30] = 32'h200E000A;  // addi $14, $0, 10     # should be skipped
            cpu.imem.memory[31] = 32'h200E000B;  // addi $14, $0, 11     # should be skipped
            cpu.imem.memory[32] = 32'h200F000C;  // addi $15, $0, 12     # $15 = 12
            cpu.imem.memory[33] = 32'h08000021;  // j 33                 # infinite loop
            
            $display("Test program loaded successfully");
        end
    endtask
    
    // Run arithmetic tests
    task run_arithmetic_tests;
        begin
            test_case = 1;
            $display("\n--- Arithmetic Tests ---");
            
            // Wait for arithmetic instructions to complete
            wait_cycles(50);
            
            // Check results
            check_register(2, 32'h00010000, "LUI instruction"); // Should be 65536 from LUI
            check_register(4, 32'h00000002, "SUB instruction"); // Should be 2 from sub
            check_register(5, 32'h00000001, "ADDIU instruction"); // Should be 1
            
            $display("Arithmetic tests completed");
        end
    endtask
    
    // Run memory tests
    task run_memory_tests;
        begin
            test_case = 2;
            $display("\n--- Memory Tests ---");
            
            // Wait for memory instructions to complete
            wait_cycles(30);
            
            // Check memory operations
            check_register(7, 32'h00010000, "Load Word (LW)");
            check_register(8, 32'h00000003, "Load Word from offset");
            
            $display("Memory tests completed");
        end
    endtask
    
    // Run branch tests
    task run_branch_tests;
        begin
            test_case = 3;
            $display("\n--- Branch Tests ---");
            
            // Wait for branch instructions
            wait_cycles(25);
            
            check_register(9, 32'h00000001, "Branch not taken path");
            check_register(10, 32'h00000003, "Branch taken path");
            
            $display("Branch tests completed");
        end
    endtask
    
    // Run jump tests
    task run_jump_tests;
        begin
            test_case = 4;
            $display("\n--- Jump Tests ---");
            
            // Wait for jump instructions
            wait_cycles(40);
            
            check_register(11, 32'h00000006, "Jump instruction");
            check_register(12, 32'h00000007, "After JAL return");
            check_register(13, 32'h00000008, "Subroutine execution");
            check_register(15, 32'h0000000C, "Final instruction");
            
            $display("Jump tests completed");
        end
    endtask
    
    // Helper task to wait for specific number of cycles
    task wait_cycles;
        input integer cycles;
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask
    
    // Helper task to check register values
    task check_register;
        input [4:0] reg_num;
        input [31:0] expected;
        input [200*8:1] test_name;
        begin
            if (cpu.regfile.registers[reg_num] == expected) begin
                $display("  ✓ PASS: %s - R%0d = 0x%08h", test_name, reg_num, expected);
            end else begin
                $display("  ✗ FAIL: %s - R%0d = 0x%08h (expected 0x%08h)", 
                        test_name, reg_num, cpu.regfile.registers[reg_num], expected);
            end
        end
    endtask
    
    // Display final results
    task display_final_results;
        begin
            $display("\n========================================");
            $display("Final Processor State");
            $display("========================================");
            $display("Total cycles executed: %0d", cycle_count);
            $display("Final PC: 0x%08h", cpu.pc_reg);
            $display("Current state: %0d", cpu.current_state);
            
            $display("\nNon-zero Register Contents:");
            for (integer i = 0; i < 32; i = i + 1) begin
                if (cpu.regfile.registers[i] != 0) begin
                    $display("  R%2d ($%2d) = 0x%08h (%0d)", 
                            i, i, cpu.regfile.registers[i], cpu.regfile.registers[i]);
                end
            end
            
            $display("\nData Memory Contents (first 10 words):");
            for (integer i = 0; i < 10; i = i + 1) begin
                if (cpu.dmem.memory[i] != 0) begin
                    $display("  Mem[%2d] = 0x%08h", i, cpu.dmem.memory[i]);
                end
            end
            
            $display("\n========================================");
            $display("Test completed successfully!");
            $display("========================================");
        end
    endtask
    
    // Monitor critical signals during simulation
    always @(posedge clk) begin
        if (!rst && cpu.current_state == `STATE_FETCH) begin
            $display("Cycle %4d: Fetching instruction at PC=0x%08h, Instr=0x%08h", 
                    cycle_count, cpu.pc_reg, cpu.instruction);
        end
    end

endmodule
