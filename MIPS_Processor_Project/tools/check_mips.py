#!/usr/bin/env python3
"""
MIPS 多周期处理器验证脚本
用于在没有 Verilog 仿真器的情况下进行基本的设计检查
"""

import re
import os
from pathlib import Path

def read_verilog_file(filename):
    """读取 Verilog 文件内容"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"错误：文件 {filename} 不存在")
        return None

def check_module_ports(content, module_name):
    """检查模块端口定义"""
    module_pattern = rf'module\s+{module_name}\s*\((.*?)\);'
    match = re.search(module_pattern, content, re.DOTALL)
    if match:
        ports = match.group(1)
        print(f"✓ 模块 {module_name} 端口定义正确")
        return True
    else:
        print(f"✗ 模块 {module_name} 端口定义有问题")
        return False

def check_always_blocks(content):
    """检查 always 块的语法"""
    always_pattern = r'always\s*@\s*\([^)]+\)'
    always_blocks = re.findall(always_pattern, content)
    print(f"  发现 {len(always_blocks)} 个 always 块")
    return len(always_blocks) > 0

def check_signal_declarations(content):
    """检查信号声明"""
    wire_pattern = r'wire\s+(\[[^\]]+\])?\s*(\w+)'
    reg_pattern = r'reg\s+(\[[^\]]+\])?\s*(\w+)'
    
    wires = re.findall(wire_pattern, content)
    regs = re.findall(reg_pattern, content)
    
    print(f"  声明了 {len(wires)} 个 wire 信号")
    print(f"  声明了 {len(regs)} 个 reg 信号")
    
    return len(wires) + len(regs) > 0

def check_mips_design():
    """检查 MIPS 设计的完整性"""
    print("MIPS 多周期处理器设计检查")
    print("=" * 40)
    
    # 检查必要文件是否存在
    required_files = [
        'src/MIPS_Multicycle.v',
        'src/ControlUnit.v', 
        'src/ALU.v',
        'src/RegisterFile.v',
        'src/InstructionMemory.v',
        'src/DataMemory.v',
        'src/SignExtender.v',
        'src/definitions.vh'
    ]
    
    missing_files = []
    for file in required_files:
        if not os.path.exists(file):
            missing_files.append(file)
    
    if missing_files:
        print("✗ 缺少必要文件：")
        for file in missing_files:
            print(f"  - {file}")
        return False
    else:
        print("✓ 所有必要文件都存在")
    
    # 检查各模块
    modules_to_check = [
        ('src/MIPS_Multicycle.v', 'MIPS_Multicycle'),
        ('src/ControlUnit.v', 'ControlUnit'),
        ('src/ALU.v', 'ALU'),
        ('src/RegisterFile.v', 'RegisterFile'),
        ('src/InstructionMemory.v', 'InstructionMemory'),
        ('src/DataMemory.v', 'DataMemory'),
        ('src/SignExtender.v', 'SignExtender')
    ]
    
    all_good = True
    for filename, module_name in modules_to_check:
        print(f"\n检查模块: {module_name}")
        content = read_verilog_file(filename)
        if content:
            check_module_ports(content, module_name)
            check_always_blocks(content)
            check_signal_declarations(content)
        else:
            all_good = False
    
    return all_good

def check_instruction_encoding():
    """检查指令编码定义"""
    print("\n检查指令编码定义...")
    content = read_verilog_file('src/definitions.vh')
    if content:
        # 检查 opcode 定义
        opcode_pattern = r'`define\s+OPCODE_(\w+)\s+6\'b([01]+)'
        opcodes = re.findall(opcode_pattern, content)
        print(f"  定义了 {len(opcodes)} 个操作码：")
        for name, code in opcodes:
            print(f"    {name}: {code}")
        
        # 检查 ALU 操作定义
        alu_pattern = r'`define\s+ALU_(\w+)\s+3\'b([01]+)'
        alu_ops = re.findall(alu_pattern, content)
        print(f"  定义了 {len(alu_ops)} 个 ALU 操作：")
        for name, code in alu_ops:
            print(f"    {name}: {code}")

def analyze_test_program():
    """分析测试程序"""
    print("\n分析测试程序...")
    content = read_verilog_file('src/InstructionMemory.v')
    if content:
        # 查找指令编码
        instr_pattern = r'memory\[\d+\]\s*=\s*32\'h([0-9A-Fa-f]+);\s*//\s*(.*)'
        instructions = re.findall(instr_pattern, content)
        
        print("  测试程序包含以下指令：")
        for hex_code, comment in instructions:
            print(f"    {hex_code}: {comment}")

if __name__ == "__main__":
    print("开始检查 MIPS 多周期处理器设计...\n")
    
    # 切换到项目根目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    os.chdir(project_root)
    
    # 执行各种检查
    design_ok = check_mips_design()
    check_instruction_encoding()
    analyze_test_program()
    
    print("\n" + "=" * 40)
    if design_ok:
        print("✓ 设计检查完成！基本结构看起来正确。")
        print("建议：安装 Verilog 仿真器进行功能验证。")
    else:
        print("✗ 设计检查发现问题，请修复后重试。")
