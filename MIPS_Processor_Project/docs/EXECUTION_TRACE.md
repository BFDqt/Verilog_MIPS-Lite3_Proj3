# MIPS多周期处理器执行追踪分析

## 📍 基于stress_test.asm的实际执行分析

### 🔬 指令序列分解

基于编译后的stress_test.asm，我们来详细分析前几条指令的多周期执行过程：

#### 指令1: `addi $t0, $zero, -1` (0x2008FFFF)

**周期1 - FETCH状态**:
```
状态: STATE_FETCH (000)
操作: PC(0) → 指令存储器地址
数据路径: memory[0] → instruction_reg
结果: instruction_reg = 0x2008FFFF
下一状态: STATE_DECODE
```

**周期2 - DECODE状态**:
```
状态: STATE_DECODE (001)  
操作: 解析指令字段，读取寄存器
数据路径: 
  - opcode = 0x20 (ADDI)
  - rs = 0 ($zero), rt = 8 ($t0)
  - immediate = 0xFFFF
  - reg_data1($zero) → a_reg = 0
  - 立即数符号扩展: 0xFFFFFFFF → sign_ext_imm
  - PC+4计算: ALU(PC + 4) → alu_result = 0x04
结果: a_reg = 0, sign_ext_imm = 0xFFFFFFFF
下一状态: STATE_EXECUTE
```

**周期3 - EXECUTE状态**:
```
状态: STATE_EXECUTE (010)
操作: 执行ADDI运算
数据路径:
  - ALU输入: a_reg(0) + sign_ext_imm(0xFFFFFFFF)
  - ALU控制: ALU_ADD
  - ALU输出: alu_result = 0xFFFFFFFF (-1)
控制信号:
  - reg_write = 1, reg_dst = 0 (rt)
  - 写入$t0: 0xFFFFFFFF
结果: $t0 = 0xFFFFFFFF
下一状态: STATE_FETCH (指令完成)
```

**总耗时**: 3个时钟周期

---

#### 指令2: `addi $t1, $zero, 1` (0x20090001)

**周期4-6**: 类似过程
- FETCH: 读取0x20090001
- DECODE: rs=0, rt=9, imm=1
- EXECUTE: ALU(0 + 1) = 1, 写入$t1

**总耗时**: 3个时钟周期

---

#### 指令3: `addu $t2, $t0, $t1` (0x01095021)

**周期7 - FETCH**:
```
状态: STATE_FETCH
操作: 读取R型指令
结果: instruction_reg = 0x01095021
```

**周期8 - DECODE**:
```
状态: STATE_DECODE
操作: R型指令解析
数据路径:
  - opcode = 0x00 (RTYPE)
  - rs = 8 ($t0), rt = 9 ($t1), rd = 10 ($t2)
  - func = 0x21 (ADDU)
  - 读取寄存器: $t0 → a_reg, $t1 → b_reg
结果: a_reg = 0xFFFFFFFF, b_reg = 0x00000001
```

**周期9 - EXECUTE**:
```
状态: STATE_EXECUTE
操作: 执行ADDU运算
数据路径:
  - ALU输入: a_reg + b_reg
  - ALU运算: 0xFFFFFFFF + 0x00000001 = 0x00000000
控制信号:
  - reg_write = 1, reg_dst = 1 (rd)
  - 写入$t2: 0x00000000
结果: $t2 = 0 (-1 + 1 = 0，验证了算术正确性)
```

**总耗时**: 3个时钟周期

---

#### 指令8: `sw $t0, 0($s0)` (0xAE080000)

这是一个需要内存访问的指令，需要4个周期：

**周期22 - FETCH**:
```
状态: STATE_FETCH
操作: 读取SW指令
结果: instruction_reg = 0xAE080000
```

**周期23 - DECODE**:
```
状态: STATE_DECODE  
操作: 解析SW指令
数据路径:
  - opcode = 0x2B (SW)
  - rs = 16 ($s0), rt = 8 ($t0)
  - offset = 0
  - 读取: $s0 → a_reg, $t0 → b_reg
结果: a_reg = base_addr, b_reg = store_data
```

**周期24 - EXECUTE**:
```
状态: STATE_EXECUTE
操作: 计算内存地址
数据路径:
  - ALU计算: a_reg + sign_ext_offset
  - 地址计算: base + 0 = 内存地址
结果: alu_out_reg = 内存地址
下一状态: STATE_MEMORY (需要内存访问)
```

**周期25 - MEMORY**:
```
状态: STATE_MEMORY
操作: 写入数据存储器
数据路径:
  - 地址: alu_out_reg
  - 数据: b_reg ($t0的值)
  - 内存写使能: mem_write = 1
结果: memory[地址] = $t0的值
下一状态: STATE_FETCH (SW指令完成)
```

**总耗时**: 4个时钟周期

---

#### 指令10: `lw $s2, 0($s0)` (0x8E120000)

LW指令需要最多的5个周期：

**周期26-28**: FETCH → DECODE → EXECUTE (地址计算)

**周期29 - MEMORY**:
```
状态: STATE_MEMORY
操作: 从数据存储器读取
数据路径:
  - 地址: alu_out_reg  
  - 内存读使能: mem_read = 1
  - 数据: memory[地址] → mem_data_reg
结果: mem_data_reg = 从内存读取的数据
下一状态: STATE_WRITEBACK
```

**周期30 - WRITEBACK**:
```
状态: STATE_WRITEBACK
操作: 将内存数据写入寄存器
数据路径:
  - 数据源: mem_data_reg
  - 目标寄存器: $s2
控制信号:
  - reg_write = 1, mem_to_reg = 1
结果: $s2 = 从内存读取的值
下一状态: STATE_FETCH (LW指令完成)
```

**总耗时**: 5个时钟周期

## 📊 多周期vs单周期性能对比实例

### 前10条指令的周期统计:

| 指令类型 | 指令数量 | 多周期处理器 | 单周期处理器 |
|---------|---------|-------------|-------------|
| ADDI/ADDIU | 6条 | 6×3 = 18周期 | 6×1 = 6周期 |
| ADDU | 1条 | 1×3 = 3周期 | 1×1 = 1周期 |
| LUI | 1条 | 1×3 = 3周期 | 1×1 = 1周期 |
| ORI | 1条 | 1×3 = 3周期 | 1×1 = 1周期 |
| SW | 1条 | 1×4 = 4周期 | 1×1 = 1周期 |
| **总计** | **10条** | **31周期** | **10周期** |

### 性能分析:

**假设时钟频率关系**:
- 单周期处理器: 100MHz (受LW指令限制)
- 多周期处理器: 250MHz (较短关键路径)

**实际执行时间**:
- 单周期: 10 ÷ 100MHz = 100ns
- 多周期: 31 ÷ 250MHz = 124ns

在这种情况下，尽管多周期CPI更高，但由于时钟频率的优势还是很小的性能损失。

## 🎯 多周期的关键优势体现

### 1. 硬件资源复用
```verilog
// 同一个ALU在不同周期执行不同操作:
// FETCH: PC + 4
// DECODE: 分支目标计算  
// EXECUTE: 指令运算
// 单周期需要3个独立的ALU单元
```

### 2. 存储器时分复用
```verilog
// 同一存储器在不同周期访问:
// FETCH: 读取指令
// MEMORY: 读写数据
// 单周期需要独立的指令和数据存储器
```

### 3. 控制信号简化
```verilog
// 每个状态的控制信号相对简单
// 单周期需要复杂的组合逻辑生成所有控制信号
```

## 🔍 调试和验证优势

多周期设计提供了更好的调试可见性：

```verilog
// 状态输出便于调试
output [2:0] current_state

// 中间结果寄存器可观察
reg [31:0] a_reg, b_reg;      // 源操作数
reg [31:0] alu_out_reg;       // ALU结果
reg [31:0] mem_data_reg;      // 内存数据
```

这种可见性使得验证和调试变得更加直观和高效。

## 📈 总结

通过stress_test.asm的实际执行分析，我们可以看到多周期处理器的核心特征：

1. **状态驱动**: 每条指令通过明确定义的状态序列执行
2. **资源复用**: 硬件单元在不同周期执行不同功能
3. **时间换空间**: 用更多周期换取更简单的硬件
4. **灵活性**: 不同指令可以使用不同的周期数

这种设计为现代处理器的流水线架构奠定了重要基础。
