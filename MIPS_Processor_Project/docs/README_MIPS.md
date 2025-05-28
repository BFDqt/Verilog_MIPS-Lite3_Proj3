# MIPS 多周期处理器实现

这是一个完整的MIPS多周期处理器实现，支持13条MIPS指令。

## 支持的指令

### R型指令
- **ADDU** (无符号加法): `addu rd, rs, rt`
- **SUBU** (无符号减法): `subu rd, rs, rt`  
- **SLT** (小于置位): `slt rd, rs, rt`
- **JR** (寄存器跳转): `jr rs`

### I型指令
- **ADDI** (立即数加法): `addi rt, rs, imm16`
- **ADDIU** (无符号立即数加法): `addiu rt, rs, imm16`
- **ORI** (立即数或): `ori rt, rs, imm16`
- **LUI** (载入高位立即数): `lui rt, imm16`
- **LW** (载入字): `lw rt, offset(rs)`
- **SW** (存储字): `sw rt, offset(rs)`
- **BEQ** (相等分支): `beq rs, rt, offset`

### J型指令
- **J** (跳转): `j target`
- **JAL** (跳转并链接): `jal target`

## 文件结构

```
definitions.vh          # 系统定义和常数
ALU.v                   # 算术逻辑单元
RegisterFile.v          # 32个寄存器文件
InstructionMemory.v     # 指令存储器 (1KB)
DataMemory.v           # 数据存储器 (1KB)
SignExtender.v         # 符号/零扩展单元
ControlUnit.v          # 多周期控制单元
MIPS_Multicycle.v      # 顶层处理器模块
MIPS_Multicycle_tb.v   # 测试台
Makefile              # 构建脚本
```

## 多周期设计

处理器采用5阶段多周期设计：

1. **取指 (Fetch)**: 从指令存储器获取指令
2. **译码 (Decode)**: 译码指令并读取寄存器
3. **执行 (Execute)**: 执行ALU操作或地址计算
4. **访存 (Memory)**: 访问数据存储器 (仅LW/SW指令)
5. **写回 (Writeback)**: 将结果写回寄存器文件

## 指令执行周期数

- **R型指令**: 4个时钟周期
- **I型算术指令**: 4个时钟周期  
- **载入指令 (LW)**: 5个时钟周期
- **存储指令 (SW)**: 4个时钟周期
- **分支指令**: 3个时钟周期
- **跳转指令**: 3个时钟周期

## 安装仿真器

### macOS

使用Homebrew安装Icarus Verilog:
```bash
brew install icarus-verilog
brew install gtkwave  # 波形查看器
```

或者手动从源码编译:
```bash
# 下载并编译Icarus Verilog
git clone https://github.com/steveicarus/iverilog.git
cd iverilog
sh autoconf.sh
./configure
make
sudo make install
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install iverilog gtkwave
```

### Linux (CentOS/RHEL)

```bash
sudo yum install iverilog gtkwave
# 或者在较新版本中
sudo dnf install iverilog gtkwave
```

## 编译和运行

安装仿真器后，可以使用以下命令：

```bash
# 编译设计
make compile

# 运行仿真
make run

# 查看波形 (需要gtkwave)
make view

# 清理生成的文件
make clean
```

## 手动编译运行

如果Make不可用，可以手动执行：

```bash
# 编译
iverilog -o mips_multicycle definitions.vh ALU.v RegisterFile.v InstructionMemory.v DataMemory.v SignExtender.v ControlUnit.v MIPS_Multicycle.v MIPS_Multicycle_tb.v

# 运行
./mips_multicycle

# 查看波形
gtkwave mips_multicycle.vcd
```

## 测试程序

测试台包含以下示例程序：

```assembly
addi $2, $0, 5      # $2 = 5
addi $3, $0, 3      # $3 = 3  
add  $4, $2, $3     # $4 = $2 + $3 = 8
sub  $4, $2, $3     # $4 = $2 - $3 = 2
ori  $2, $0, 15     # $2 = 0 | 15 = 15
lui  $2, 1          # $2 = 1 << 16 = 65536
slt  $4, $2, $3     # $4 = ($2 < $3) ? 1 : 0
j    7              # 无限循环
```

## 控制信号

控制单元生成以下控制信号：

- `alu_ctrl[2:0]`: ALU操作选择
- `alu_src_a[1:0]`, `alu_src_b[1:0]`: ALU输入源选择
- `mem_read`, `mem_write`: 存储器访问控制
- `reg_write`: 寄存器文件写使能
- `reg_dst[1:0]`: 写寄存器选择
- `mem_to_reg[1:0]`: 写数据源选择
- `pc_src[1:0]`: PC源选择
- `pc_write`, `pc_write_cond`: PC更新控制
- `ir_write`: 指令寄存器写使能
- `ext_op`: 符号扩展控制

## 数据通路

```
┌─────────────┐    ┌──────────────┐    ┌─────────┐
│Instruction  │───→│   Control    │───→│  ALU    │
│   Memory    │    │    Unit      │    │         │
└─────────────┘    └──────────────┘    └─────────┘
       │                   │                 │
       │            ┌─────────────┐          │
       └───────────→│  Register   │←─────────┘
                    │    File     │
                    └─────────────┘
                           │
                    ┌─────────────┐
                    │    Data     │
                    │   Memory    │
                    └─────────────┘
```

## 扩展功能

该设计可以扩展支持：

- 更多MIPS指令
- 流水线实现
- 缓存存储器
- 异常处理
- 浮点运算单元
- 性能计数器

## 注意事项

- 处理器使用字对齐的存储器访问
- 寄存器$0恒为零
- 设计适合FPGA实现
- 所有指令都是32位定长
- 存储器为测试目的进行了初始化

## 调试提示

1. 使用`$display`语句监控关键信号
2. 检查波形文件了解时序关系
3. 验证状态机正确转换
4. 确认控制信号在正确时间生成

## 故障排除

如果遇到编译错误：
1. 检查所有文件是否在同一目录
2. 确保`definitions.vh`被正确包含
3. 验证Verilog语法
4. 检查仿真器是否正确安装

如果仿真结果不正确：
1. 检查时钟和复位信号
2. 验证指令编码
3. 确认数据通路连接
4. 检查控制信号时序
