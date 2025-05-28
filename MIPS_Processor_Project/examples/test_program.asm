# 示例 MIPS 汇编程序
# 测试所有支持的指令

main:
    # 算术指令测试
    addi $t0, $zero, 10      # $t0 = 10
    addi $t1, $zero, 5       # $t1 = 5
    addu $t2, $t0, $t1       # $t2 = $t0 + $t1 = 15
    subu $t3, $t0, $t1       # $t3 = $t0 - $t1 = 5
    
    # 立即数指令测试
    addiu $t4, $zero, -1     # $t4 = -1 (0xFFFFFFFF)
    ori $t5, $zero, 0xFF     # $t5 = 255
    lui $t6, 0x1000          # $t6 = 0x10000000
    
    # 比较指令测试
    slt $t7, $t1, $t0        # $t7 = 1 (5 < 10)
    slt $t8, $t0, $t1        # $t8 = 0 (10 > 5)
    
    # 内存操作测试
    addi $s0, $zero, 100     # $s0 = 100 (基地址)
    sw $t0, 0($s0)           # 存储 $t0 到内存[100]
    sw $t1, 4($s0)           # 存储 $t1 到内存[101]
    lw $s1, 0($s0)           # $s1 = 内存[100] = 10
    lw $s2, 4($s0)           # $s2 = 内存[101] = 5
    
    # 分支测试
    beq $s1, $t0, equal      # 如果 $s1 == $t0 则跳转
    addi $v0, $zero, 1       # 这行不应该执行
    
equal:
    addi $v0, $zero, 2       # $v0 = 2
    
    # 跳转测试
    jal subroutine           # 调用子程序
    addi $v1, $zero, 3       # $v1 = 3 (从子程序返回后执行)
    j end                    # 跳转到结束

subroutine:
    addi $a0, $zero, 42      # $a0 = 42
    jr $ra                   # 返回

end:
    addi $a1, $zero, 99      # $a1 = 99
    j end                    # 无限循环
