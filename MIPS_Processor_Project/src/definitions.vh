// MIPS Multi-cycle Processor Definitions
`ifndef DEFINITIONS_VH
`define DEFINITIONS_VH

// Instruction opcodes
`define OPCODE_RTYPE    6'b000000
`define OPCODE_ADDI     6'b001000
`define OPCODE_ADDIU    6'b001001
`define OPCODE_ORI      6'b001101
`define OPCODE_LUI      6'b001111
`define OPCODE_LW       6'b100011
`define OPCODE_SW       6'b101011
`define OPCODE_BEQ      6'b000100
`define OPCODE_J        6'b000010
`define OPCODE_JAL      6'b000011

// Function codes for R-type instructions
`define FUNC_ADDU       6'b100001
`define FUNC_SUBU       6'b100011
`define FUNC_SLT        6'b101010
`define FUNC_JR         6'b001000

// ALU operations
`define ALU_ADD         3'b000
`define ALU_SUB         3'b001
`define ALU_OR          3'b010
`define ALU_SLT         3'b011
`define ALU_LUI         3'b100

// Processor states
`define STATE_FETCH     3'b000
`define STATE_DECODE    3'b001
`define STATE_EXECUTE   3'b010
`define STATE_MEMORY    3'b011
`define STATE_WRITEBACK 3'b100

`endif
