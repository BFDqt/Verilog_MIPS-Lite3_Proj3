#!/usr/bin/env python3
"""
Simple MIPS Assembler for the multi-cycle processor
Supports the 13 instructions implemented in the processor
"""

import re
import sys

class MIPSAssembler:
    def __init__(self):
        # Instruction encodings
        self.opcodes = {
            'addi': 0x08, 'addiu': 0x09, 'ori': 0x0D, 'lui': 0x0F,
            'lw': 0x23, 'sw': 0x2B, 'beq': 0x04, 'j': 0x02, 'jal': 0x03
        }
        
        self.r_type_funcs = {
            'addu': 0x21, 'subu': 0x23, 'slt': 0x2A, 'jr': 0x08
        }
        
        # Register mappings
        self.registers = {
            '$zero': 0, '$0': 0, '$at': 1, '$1': 1,
            '$v0': 2, '$2': 2, '$v1': 3, '$3': 3,
            '$a0': 4, '$4': 4, '$a1': 5, '$5': 5,
            '$a2': 6, '$6': 6, '$a3': 7, '$7': 7,
            '$t0': 8, '$8': 8, '$t1': 9, '$9': 9,
            '$t2': 10, '$10': 10, '$t3': 11, '$11': 11,
            '$t4': 12, '$12': 12, '$t5': 13, '$13': 13,
            '$t6': 14, '$14': 14, '$t7': 15, '$15': 15,
            '$s0': 16, '$16': 16, '$s1': 17, '$17': 17,
            '$s2': 18, '$18': 18, '$s3': 19, '$19': 19,
            '$s4': 20, '$20': 20, '$s5': 21, '$21': 21,
            '$s6': 22, '$22': 22, '$s7': 23, '$23': 23,
            '$t8': 24, '$24': 24, '$t9': 25, '$25': 25,
            '$k0': 26, '$26': 26, '$k1': 27, '$27': 27,
            '$gp': 28, '$28': 28, '$sp': 29, '$29': 29,
            '$fp': 30, '$30': 30, '$ra': 31, '$31': 31
        }
        
        self.labels = {}
        self.instructions = []
    
    def parse_register(self, reg_str):
        """Parse register string and return register number"""
        reg_str = reg_str.strip().rstrip(',')
        if reg_str in self.registers:
            return self.registers[reg_str]
        else:
            raise ValueError(f"Unknown register: {reg_str}")
    
    def parse_immediate(self, imm_str):
        """Parse immediate value"""
        imm_str = imm_str.strip().rstrip(',')
        if imm_str.startswith('0x'):
            return int(imm_str, 16)
        elif imm_str in self.labels:
            return self.labels[imm_str]
        else:
            return int(imm_str)
    
    def parse_offset(self, offset_str):
        """Parse offset(register) format"""
        match = re.match(r'(-?\d+)\((\$\w+)\)', offset_str.strip())
        if match:
            offset = int(match.group(1))
            reg = self.parse_register(match.group(2))
            return offset, reg
        else:
            raise ValueError(f"Invalid offset format: {offset_str}")
    
    def first_pass(self, lines):
        """First pass: collect labels"""
        pc = 0
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            if ':' in line:
                label = line.split(':')[0].strip()
                self.labels[label] = pc
                line = line.split(':', 1)[1].strip()
            
            if line and not line.startswith('#'):
                pc += 1
    
    def assemble_r_type(self, parts):
        """Assemble R-type instruction"""
        op = parts[0]
        
        if op == 'jr':
            rs = self.parse_register(parts[1])
            return (0 << 26) | (rs << 21) | (0 << 16) | (0 << 11) | (0 << 6) | self.r_type_funcs[op]
        else:
            rd = self.parse_register(parts[1])
            rs = self.parse_register(parts[2])
            rt = self.parse_register(parts[3])
            return (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (0 << 6) | self.r_type_funcs[op]
    
    def assemble_i_type(self, parts, pc):
        """Assemble I-type instruction"""
        op = parts[0]
        opcode = self.opcodes[op]
        
        if op in ['lw', 'sw']:
            rt = self.parse_register(parts[1])
            offset, rs = self.parse_offset(parts[2])
            return (opcode << 26) | (rs << 21) | (rt << 16) | (offset & 0xFFFF)
        elif op == 'beq':
            rs = self.parse_register(parts[1])
            rt = self.parse_register(parts[2])
            if parts[3] in self.labels:
                target = self.labels[parts[3]]
                offset = target - pc - 1
            else:
                offset = self.parse_immediate(parts[3])
            return (opcode << 26) | (rs << 21) | (rt << 16) | (offset & 0xFFFF)
        else:  # addi, addiu, ori, lui
            rt = self.parse_register(parts[1])
            if op == 'lui':
                rs = 0
            else:
                rs = self.parse_register(parts[2])
            if op == 'lui':
                imm = self.parse_immediate(parts[2])
            else:
                imm = self.parse_immediate(parts[3])
            return (opcode << 26) | (rs << 21) | (rt << 16) | (imm & 0xFFFF)
    
    def assemble_j_type(self, parts):
        """Assemble J-type instruction"""
        op = parts[0]
        opcode = self.opcodes[op]
        
        if parts[1] in self.labels:
            target = self.labels[parts[1]]
        else:
            target = self.parse_immediate(parts[1])
        
        return (opcode << 26) | (target & 0x3FFFFFF)
    
    def assemble_line(self, line, pc):
        """Assemble a single line"""
        line = line.strip()
        if not line or line.startswith('#'):
            return None
        
        # Remove label if present
        if ':' in line:
            line = line.split(':', 1)[1].strip()
        
        if not line or line.startswith('#'):
            return None
        
        # Remove comments
        if '#' in line:
            line = line.split('#')[0].strip()
        
        # Split instruction
        parts = re.split(r'[,\s]+', line)
        parts = [p.strip() for p in parts if p.strip()]
        
        op = parts[0].lower()
        
        # Determine instruction type and assemble
        if op in self.r_type_funcs:
            return self.assemble_r_type(parts)
        elif op in ['addi', 'addiu', 'ori', 'lui', 'lw', 'sw', 'beq']:
            return self.assemble_i_type(parts, pc)
        elif op in ['j', 'jal']:
            return self.assemble_j_type(parts)
        else:
            raise ValueError(f"Unknown instruction: {op}")
    
    def assemble(self, assembly_code):
        """Assemble the complete program"""
        lines = assembly_code.strip().split('\n')
        
        # First pass: collect labels
        self.first_pass(lines)
        
        # Second pass: assemble instructions
        machine_code = []
        pc = 0
        
        for line in lines:
            instruction = self.assemble_line(line, pc)
            if instruction is not None:
                machine_code.append(instruction)
                pc += 1
        
        return machine_code
    
    def generate_verilog_memory(self, machine_code, output_file=None):
        """Generate Verilog memory initialization"""
        output = []
        output.append("// Generated machine code")
        output.append("initial begin")
        
        for i, instruction in enumerate(machine_code):
            output.append(f"    memory[{i}] = 32'h{instruction:08X};  // {instruction:08X}")
        
        # Fill rest with NOPs
        output.append(f"    // Fill rest with NOPs")
        output.append(f"    for (integer i = {len(machine_code)}; i < 1024; i = i + 1) begin")
        output.append(f"        memory[i] = 32'h00000000;")
        output.append(f"    end")
        output.append("end")
        
        result = '\n'.join(output)
        
        if output_file:
            with open(output_file, 'w') as f:
                f.write(result)
        
        return result

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 mips_assembler.py <assembly_file> [output_file]")
        sys.exit(1)
    
    assembler = MIPSAssembler()
    
    try:
        with open(sys.argv[1], 'r') as f:
            assembly_code = f.read()
        
        machine_code = assembler.assemble(assembly_code)
        
        print("Assembly successful!")
        print(f"Generated {len(machine_code)} instructions")
        
        # Generate Verilog output
        verilog_output = assembler.generate_verilog_memory(machine_code)
        
        if len(sys.argv) > 2:
            with open(sys.argv[2], 'w') as f:
                f.write(verilog_output)
            print(f"Verilog memory file written to: {sys.argv[2]}")
        else:
            print("\nVerilog memory initialization:")
            print(verilog_output)
        
        # Print machine code
        print("\nMachine code:")
        for i, instruction in enumerate(machine_code):
            print(f"  [{i:2d}] 0x{instruction:08X}")
    
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
