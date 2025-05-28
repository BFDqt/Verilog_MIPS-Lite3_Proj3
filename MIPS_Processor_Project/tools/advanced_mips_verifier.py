#!/usr/bin/env python3
"""
Advanced MIPS Multi-cycle Processor Verification Script
Performs high-level simulation and comprehensive design validation
"""

import re
import os
from typing import Dict, List, Tuple, Optional

class MIPSProcessor:
    """High-level MIPS processor simulator for verification"""
    
    def __init__(self):
        # Initialize registers (32 registers, each 32 bits)
        self.registers = [0] * 32
        self.memory = {}  # Address -> Data mapping
        self.pc = 0  # Program counter
        self.instructions = []  # List of (address, instruction) tuples
        self.cycle_count = 0
        self.state = "FETCH"  # Current processor state
        
        # Instruction decode cache
        self.current_instruction = None
        self.instruction_type = None
        
    def load_instructions(self, instructions: List[str]):
        """Load instructions into the processor"""
        self.instructions = []
        for i, instr in enumerate(instructions):
            if instr.strip() and not instr.strip().startswith('//'):
                # Remove memory initialization syntax and extract hex
                hex_match = re.search(r'[0-9A-Fa-f]{8}', instr)
                if hex_match:
                    hex_val = hex_match.group()
                    self.instructions.append((i * 4, int(hex_val, 16)))
    
    def decode_instruction(self, instr: int) -> Dict:
        """Decode a 32-bit instruction"""
        opcode = (instr >> 26) & 0x3F
        rs = (instr >> 21) & 0x1F
        rt = (instr >> 16) & 0x1F
        rd = (instr >> 11) & 0x1F
        shamt = (instr >> 6) & 0x1F
        funct = instr & 0x3F
        immediate = instr & 0xFFFF
        target = instr & 0x3FFFFFF
        
        # Sign extend immediate
        if immediate & 0x8000:
            immediate_signed = immediate - 0x10000
        else:
            immediate_signed = immediate
            
        return {
            'opcode': opcode, 'rs': rs, 'rt': rt, 'rd': rd,
            'shamt': shamt, 'funct': funct, 'immediate': immediate,
            'immediate_signed': immediate_signed, 'target': target
        }
    
    def get_instruction_type(self, decoded: Dict) -> str:
        """Determine instruction type and mnemonic"""
        opcode = decoded['opcode']
        funct = decoded['funct']
        
        if opcode == 0x00:  # R-type
            if funct == 0x21: return "ADDU"
            elif funct == 0x23: return "SUBU"
            elif funct == 0x2A: return "SLT"
            elif funct == 0x08: return "JR"
            else: return f"R-type (funct={funct:02X})"
        elif opcode == 0x08: return "ADDI"
        elif opcode == 0x09: return "ADDIU"
        elif opcode == 0x0D: return "ORI"
        elif opcode == 0x0F: return "LUI"
        elif opcode == 0x23: return "LW"
        elif opcode == 0x2B: return "SW"
        elif opcode == 0x04: return "BEQ"
        elif opcode == 0x02: return "J"
        elif opcode == 0x03: return "JAL"
        else: return f"Unknown (opcode={opcode:02X})"
    
    def execute_instruction(self, decoded: Dict, instr_type: str) -> bool:
        """Execute a single instruction. Returns True if execution should continue."""
        rs_val = self.registers[decoded['rs']]
        rt_val = self.registers[decoded['rt']]
        
        if instr_type == "ADDU":
            self.registers[decoded['rd']] = (rs_val + rt_val) & 0xFFFFFFFF
        elif instr_type == "SUBU":
            self.registers[decoded['rd']] = (rs_val - rt_val) & 0xFFFFFFFF
        elif instr_type == "SLT":
            # Treat as signed comparison
            rs_signed = rs_val if rs_val < 0x80000000 else rs_val - 0x100000000
            rt_signed = rt_val if rt_val < 0x80000000 else rt_val - 0x100000000
            self.registers[decoded['rd']] = 1 if rs_signed < rt_signed else 0
        elif instr_type == "ADDI" or instr_type == "ADDIU":
            self.registers[decoded['rt']] = (rs_val + decoded['immediate_signed']) & 0xFFFFFFFF
        elif instr_type == "ORI":
            self.registers[decoded['rt']] = (rs_val | decoded['immediate']) & 0xFFFFFFFF
        elif instr_type == "LUI":
            self.registers[decoded['rt']] = (decoded['immediate'] << 16) & 0xFFFFFFFF
        elif instr_type == "LW":
            addr = (rs_val + decoded['immediate_signed']) & 0xFFFFFFFF
            self.registers[decoded['rt']] = self.memory.get(addr, 0)
        elif instr_type == "SW":
            addr = (rs_val + decoded['immediate_signed']) & 0xFFFFFFFF
            self.memory[addr] = rt_val
        elif instr_type == "BEQ":
            if rs_val == rt_val:
                self.pc += (decoded['immediate_signed'] << 2)
        elif instr_type == "J":
            self.pc = (decoded['target'] << 2) & 0xFFFFFFFF
            return True  # Skip normal PC increment
        elif instr_type == "JAL":
            self.registers[31] = self.pc + 4  # Save return address
            self.pc = (decoded['target'] << 2) & 0xFFFFFFFF
            return True  # Skip normal PC increment
        elif instr_type == "JR":
            self.pc = rs_val
            return True  # Skip normal PC increment
        
        # Keep $zero register always zero
        self.registers[0] = 0
        return False
    
    def simulate_cycles(self, max_cycles: int = 1000) -> List[Dict]:
        """Simulate the processor for a given number of cycles"""
        trace = []
        
        for cycle in range(max_cycles):
            if self.pc // 4 >= len(self.instructions):
                break
                
            # Fetch
            if self.pc // 4 < len(self.instructions):
                addr, instr = self.instructions[self.pc // 4]
                decoded = self.decode_instruction(instr)
                instr_type = self.get_instruction_type(decoded)
                
                # Record state before execution
                state_record = {
                    'cycle': cycle,
                    'pc': self.pc,
                    'instruction': f"{instr:08X}",
                    'type': instr_type,
                    'registers_before': self.registers.copy(),
                    'memory_before': self.memory.copy()
                }
                
                # Execute
                skip_increment = self.execute_instruction(decoded, instr_type)
                
                # Record state after execution
                state_record['registers_after'] = self.registers.copy()
                state_record['memory_after'] = self.memory.copy()
                
                trace.append(state_record)
                
                # Update PC
                if not skip_increment:
                    self.pc += 4
                    
            self.cycle_count += 1
            
        return trace

class MIPSVerifier:
    """Comprehensive MIPS design verifier"""
    
    def __init__(self, base_path: str):
        self.base_path = base_path
        self.files = {}
        self.processor = MIPSProcessor()
        
    def load_files(self) -> bool:
        """Load all MIPS design files"""
        required_files = [
            'src/MIPS_Multicycle.v', 'src/ControlUnit.v', 'src/ALU.v', 'src/RegisterFile.v',
            'src/InstructionMemory.v', 'src/DataMemory.v', 'src/SignExtender.v', 'src/definitions.vh'
        ]
        
        for filename in required_files:
            filepath = os.path.join(self.base_path, filename)
            if os.path.exists(filepath):
                with open(filepath, 'r') as f:
                    self.files[filename] = f.read()
            else:
                print(f"❌ Missing file: {filename}")
                return False
        
        print(f"✓ Loaded {len(self.files)} design files")
        return True
    
    def extract_test_instructions(self) -> List[str]:
        """Extract instructions from InstructionMemory.v"""
        if 'src/InstructionMemory.v' not in self.files:
            return []
            
        content = self.files['src/InstructionMemory.v']
        instructions = []
        
        # Look for memory initialization assignments
        pattern = r'memory\[\d+\]\s*=\s*32\'h([0-9A-Fa-f]{8})'
        matches = re.findall(pattern, content)
        
        for match in matches:
            instructions.append(match)
            
        return instructions
    
    def check_state_machine(self) -> bool:
        """Analyze the control unit state machine"""
        if 'ControlUnit.v' not in self.files or 'definitions.vh' not in self.files:
            return False
            
        control_content = self.files['ControlUnit.v']
        defs_content = self.files['definitions.vh']
        
        # Check for state definitions in definitions.vh
        state_pattern = r'`define\s+STATE_(\w+)\s+3\'b(\d+)'
        states = re.findall(state_pattern, defs_content)
        
        print(f"\n状态机分析:")
        print(f"  发现 {len(states)} 个状态:")
        for state_name, state_value in states:
            print(f"    {state_name}: {state_value}")
        
        # Check for state transitions in control unit
        always_blocks = re.findall(r'always\s*@[^}]+?end', control_content, re.DOTALL)
        print(f"  发现 {len(always_blocks)} 个 always 块")
        
        # Look for common issues
        issues = []
        if 'next_state' not in control_content:
            issues.append("缺少 next_state 信号")
        if 'current_state' not in control_content:
            issues.append("缺少 current_state 信号")
            
        if issues:
            print(f"  ⚠️  发现问题: {', '.join(issues)}")
            return False
        else:
            print(f"  ✓ 状态机结构正常")
            return True
    
    def run_simulation(self) -> bool:
        """Run high-level simulation"""
        instructions = self.extract_test_instructions()
        if not instructions:
            print("❌ 无法提取测试指令")
            return False
            
        print(f"\n开始高级仿真...")
        print(f"  加载了 {len(instructions)} 条指令")
        
        self.processor.load_instructions(instructions)
        trace = self.processor.simulate_cycles(100)
        
        print(f"  执行了 {len(trace)} 个周期")
        
        # Analyze execution trace
        self.analyze_trace(trace)
        
        return True
    
    def analyze_trace(self, trace: List[Dict]):
        """Analyze the execution trace for correctness"""
        print(f"\n执行轨迹分析:")
        
        instruction_counts = {}
        register_changes = {}
        memory_accesses = []
        
        for step in trace:
            instr_type = step['type']
            instruction_counts[instr_type] = instruction_counts.get(instr_type, 0) + 1
            
            # Check for register changes
            for i in range(32):
                if step['registers_before'][i] != step['registers_after'][i]:
                    if i not in register_changes:
                        register_changes[i] = []
                    register_changes[i].append({
                        'cycle': step['cycle'],
                        'before': step['registers_before'][i],
                        'after': step['registers_after'][i],
                        'instruction': step['type']
                    })
            
            # Check for memory accesses
            if step['memory_before'] != step['memory_after']:
                memory_accesses.append({
                    'cycle': step['cycle'],
                    'instruction': step['type'],
                    'changes': len(step['memory_after']) - len(step['memory_before'])
                })
        
        # Report instruction frequency
        print(f"  指令执行统计:")
        for instr, count in sorted(instruction_counts.items()):
            print(f"    {instr}: {count} 次")
        
        # Report register usage
        print(f"  寄存器使用:")
        for reg_num, changes in sorted(register_changes.items()):
            if reg_num != 0:  # Skip $zero
                print(f"    $r{reg_num}: {len(changes)} 次修改")
        
        # Report memory accesses
        if memory_accesses:
            print(f"  内存访问: {len(memory_accesses)} 次")
        
        # Show first few execution steps
        print(f"\n前5个执行步骤:")
        for i, step in enumerate(trace[:5]):
            print(f"    周期{step['cycle']}: PC={step['pc']:04X} {step['instruction']} ({step['type']})")
    
    def run_comprehensive_check(self) -> bool:
        """Run all verification checks"""
        print("开始全面的 MIPS 处理器验证...")
        print("=" * 50)
        
        # Load files
        if not self.load_files():
            return False
        
        # Check state machine
        if not self.check_state_machine():
            print("⚠️  状态机检查发现问题")
        
        # Run simulation
        if not self.run_simulation():
            return False
        
        print("\n" + "=" * 50)
        print("✓ 验证完成！")
        return True

def main():
    # Use relative path from tools directory to project root
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_path = os.path.dirname(script_dir)
    verifier = MIPSVerifier(base_path)
    verifier.run_comprehensive_check()

if __name__ == "__main__":
    main()
