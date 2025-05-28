# MIPS Stress Test Program
# Tests edge cases and intensive operations

main:
    # Test 1: Arithmetic edge cases
    addi $t0, $zero, -1        # Load -1 (0xFFFFFFFF)
    addi $t1, $zero, 1         # Load 1
    addu $t2, $t0, $t1         # -1 + 1 = 0
    
    # Test 2: Large immediate values
    lui $t3, 0x8000            # Load 0x80000000 (largest negative)
    ori $t3, $t3, 0x0000       # Complete the value
    addiu $t4, $zero, 32767    # Load 0x7FFF
    
    # Test 3: Memory boundary testing
    addi $s0, $zero, 0         # Base address 0
    addi $s1, $zero, 1020      # Near end of 1KB memory
    
    sw $t0, 0($s0)             # Store at address 0
    sw $t1, 4($s0)             # Store at address 4
    
    lw $s2, 0($s0)             # Load from address 0
    lw $s3, 4($s0)             # Load from address 4
    
    # Test 4: Nested subroutine calls
    jal subroutine1            # Call first subroutine
    addi $v0, $v0, 100         # Add 100 to result
    
    # Test 5: Complex branching
    addi $t5, $zero, 5
    addi $t6, $zero, 5
    beq $t5, $t6, equal_test   # Should branch
    addi $v1, $zero, 0         # Should not execute
    j end
    
equal_test:
    addi $v1, $zero, 42        # Should execute
    
subroutine1:
    jal subroutine2            # Call nested subroutine
    addi $v0, $v0, 10          # Add 10 to result
    jr $ra                     # Return

subroutine2:
    addi $v0, $zero, 1         # Return value 1
    jr $ra                     # Return

end:
    j end                      # Infinite loop
