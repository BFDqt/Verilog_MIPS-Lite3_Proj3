// Instruction Memory for MIPS Multi-cycle Processor
module InstructionMemory(
    input [31:0] address,
    output [31:0] instruction
);

    reg [31:0] memory [1023:0]; // 1KB instruction memory
    
    // Initialize with comprehensive test program
    initial begin
        // Generated from test_program.asm
        memory[0] = 32'h2008000A;  // addi $t0, $zero, 10
        memory[1] = 32'h20090005;  // addi $t1, $zero, 5
        memory[2] = 32'h01095021;  // addu $t2, $t0, $t1
        memory[3] = 32'h01095823;  // subu $t3, $t0, $t1
        memory[4] = 32'h240CFFFF;  // addiu $t4, $zero, -1
        memory[5] = 32'h340D00FF;  // ori $t5, $zero, 0xFF
        memory[6] = 32'h3C0E1000;  // lui $t6, 0x1000
        memory[7] = 32'h0128782A;  // slt $t7, $t1, $t0
        memory[8] = 32'h0109C02A;  // slt $t8, $t0, $t1
        memory[9] = 32'h20100064;  // addi $s0, $zero, 100
        memory[10] = 32'hAE080000; // sw $t0, 0($s0)
        memory[11] = 32'hAE090004; // sw $t1, 4($s0)
        memory[12] = 32'h8E110000; // lw $s1, 0($s0)
        memory[13] = 32'h8E120004; // lw $s2, 4($s0)
        memory[14] = 32'h12280001; // beq $s1, $t0, equal
        memory[15] = 32'h20020001; // addi $v0, $zero, 1
        memory[16] = 32'h20020002; // addi $v0, $zero, 2 (equal:)
        memory[17] = 32'h0C000014; // jal subroutine
        memory[18] = 32'h20030003; // addi $v1, $zero, 3
        memory[19] = 32'h08000016; // j end
        memory[20] = 32'h2004002A; // addi $a0, $zero, 42 (subroutine:)
        memory[21] = 32'h03E00008; // jr $ra
        memory[22] = 32'h20050063; // addi $a1, $zero, 99 (end:)
        memory[23] = 32'h08000016; // j end (infinite loop)
        
        // Initialize rest to NOPs
        for (integer i = 24; i < 1024; i = i + 1) begin
            memory[i] = 32'h00000000;
        end
    end

    assign instruction = memory[address[11:2]]; // Word-aligned access

endmodule
