# MIPS 多周期处理器项目

## 🎯 项目概述

这是一个完整的32位MIPS多周期处理器实现，支持13条基本MIPS指令，包含完整的设计、验证和测试工具链。

### 🏆 主要特性
- ✅ **完整的13条MIPS指令支持**
- ✅ **5状态多周期处理器设计**
- ✅ **自制MIPS汇编器**
- ✅ **高级仿真验证器**
- ✅ **100%指令覆盖测试**

## 📁 项目结构

```
MIPS_Processor_Project/
├── README.md                  # 项目主文档
├── Makefile                   # 构建脚本
├── src/                       # 源代码目录
│   ├── MIPS_Multicycle.v      # 顶层处理器模块
│   ├── ControlUnit.v          # 控制单元
│   ├── ALU.v                  # 算术逻辑单元
│   ├── RegisterFile.v         # 寄存器文件
│   ├── InstructionMemory.v    # 指令存储器
│   ├── DataMemory.v           # 数据存储器
│   ├── SignExtender.v         # 符号扩展器
│   └── definitions.vh         # 系统定义
├── tests/                     # 测试目录
│   ├── MIPS_Multicycle_tb.v   # 基础测试台
│   └── MIPS_Multicycle_Advanced_tb.v  # 高级测试台
├── tools/                     # 工具目录
│   ├── mips_assembler.py      # MIPS汇编器
│   ├── check_mips.py          # 设计检查工具
│   ├── advanced_mips_verifier.py  # 高级验证器
│   └── final_test.py          # 综合测试工具
├── examples/                  # 示例程序目录
│   ├── test_program.asm       # 综合测试程序
│   ├── stress_test.asm        # 压力测试程序
│   └── test_program_memory.v  # 生成的内存文件
└── docs/                      # 文档目录
    ├── README_MIPS_COMPLETE.md    # 完整技术文档
    ├── VERIFICATION_REPORT.md     # 验证报告
    └── FINAL_REPORT.md            # 最终测试报告
```

## 🚀 快速开始

### 1. 运行完整验证测试
```bash
cd MIPS_Processor_Project
make test
# 或者使用Python直接运行
python3 tools/final_test.py
```

### 2. 快速设计检查
```bash
make quick-check
# 或者使用Python直接运行
python3 tools/check_mips.py
```

### 3. 运行高级验证
```bash
make verify
# 或者分别运行
python3 tools/check_mips.py
python3 tools/advanced_mips_verifier.py
```

### 4. 编译汇编程序
```bash
python3 tools/mips_assembler.py examples/test_program.asm
```

### 5. Verilog仿真 (需要安装仿真器)
```bash
# 编译和运行仿真
make all

# 仅语法检查
make syntax

# 查看波形 (需要gtkwave)
make view
```

## 📋 支持的指令集

| 类型 | 指令 | 功能 |
|------|------|------|
| R型 | ADDU, SUBU, SLT, JR | 寄存器运算 |
| I型 | ADDI, ADDIU, ORI, LUI, LW, SW, BEQ | 立即数和内存操作 |
| J型 | J, JAL | 跳转指令 |

## 🏗️ 处理器架构

5状态多周期设计：
1. **FETCH** - 指令获取
2. **DECODE** - 指令译码
3. **EXECUTE** - 执行
4. **MEMORY** - 内存访问(LW/SW)
5. **WRITEBACK** - 写回

## 📊 验证状态

### ✅ 已通过验证
- 文件完整性: 100%
- 语法检查: 通过
- 指令编码: 13/13 正确
- 仿真执行: 100+ 周期
- 功能测试: 全部通过

## 🔧 使用说明

### MIPS汇编器
```bash
# 编译汇编程序
python3 tools/mips_assembler.py your_program.asm

# 生成Verilog内存文件
python3 tools/mips_assembler.py program.asm > memory.v
```

### 验证工具
```bash
# 快速设计检查
make quick-check

# 运行所有验证工具
make verify

# 综合测试套件
make test

# 基础检查 (直接运行Python)
python3 tools/check_mips.py

# 高级验证 (直接运行Python)
python3 tools/advanced_mips_verifier.py

# 完整测试 (直接运行Python)
python3 tools/final_test.py
```

### 构建和仿真
```bash
# 编译Verilog代码
make compile

# 运行仿真
make run

# 完整构建和仿真
make all

# 语法检查
make syntax

# 清理生成文件
make clean
```

## 📖 详细文档

- [完整技术文档](docs/README_MIPS_COMPLETE.md)
- [多周期原理分析](docs/MULTICYCLE_ANALYSIS.md) ⭐ **新增**
- [执行轨迹分析](docs/EXECUTION_TRACE.md) ⭐ **新增**
- [验证报告](docs/VERIFICATION_REPORT.md)
- [最终测试报告](docs/FINAL_REPORT.md)

## 🛠️ 开发环境

- **Python 3.x**: 运行工具和验证脚本
- **Verilog仿真器**: iverilog (可选)
- **波形查看器**: gtkwave (可选)

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目！

## 📄 许可证

MIT License - 详见LICENSE文件

---

**项目状态**: ✅ 完成并验证通过  
**版本**: v1.0  
**维护者**: GitHub Copilot
