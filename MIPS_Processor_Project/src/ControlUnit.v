// Control Unit for MIPS Multi-cycle Processor
`include "definitions.vh"

module ControlUnit(
    input clk,
    input rst,
    input [31:0] instr,
    input zero,
    
    // Control signals
    output reg [2:0] alu_ctrl,
    output reg [1:0] alu_src_a,
    output reg [1:0] alu_src_b,
    output reg mem_read,
    output reg mem_write,
    output reg reg_write,
    output reg [1:0] reg_dst,
    output reg [1:0] mem_to_reg,
    output reg [1:0] pc_src,
    output reg pc_write,
    output reg pc_write_cond,
    output reg ir_write,
    output reg ext_op,
    
    // State output for debugging
    output [2:0] current_state
);

    // State registers
    reg [2:0] state, next_state;
    
    // Instruction decode signals
    wire [5:0] opcode, func;
    wire ADDU, SUBU, ORI, LW, SW, BEQ, LUI, ADDI, ADDIU, SLT, J, JAL, JR;
    
    assign opcode = instr[31:26];
    assign func = instr[5:0];
    assign current_state = state;
    
    // Instruction type detection
    assign ADDU = (opcode == `OPCODE_RTYPE) && (func == `FUNC_ADDU);
    assign SUBU = (opcode == `OPCODE_RTYPE) && (func == `FUNC_SUBU);
    assign SLT = (opcode == `OPCODE_RTYPE) && (func == `FUNC_SLT);
    assign JR = (opcode == `OPCODE_RTYPE) && (func == `FUNC_JR);
    assign ORI = (opcode == `OPCODE_ORI);
    assign LW = (opcode == `OPCODE_LW);
    assign SW = (opcode == `OPCODE_SW);
    assign BEQ = (opcode == `OPCODE_BEQ);
    assign LUI = (opcode == `OPCODE_LUI);
    assign ADDI = (opcode == `OPCODE_ADDI);
    assign ADDIU = (opcode == `OPCODE_ADDIU);
    assign J = (opcode == `OPCODE_J);
    assign JAL = (opcode == `OPCODE_JAL);

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= `STATE_FETCH;
        else
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (state)
            `STATE_FETCH: next_state = `STATE_DECODE;
            `STATE_DECODE: next_state = `STATE_EXECUTE;
            `STATE_EXECUTE: begin
                if (LW || SW)
                    next_state = `STATE_MEMORY;
                else
                    next_state = `STATE_FETCH;
            end
            `STATE_MEMORY: begin
                if (LW)
                    next_state = `STATE_WRITEBACK;
                else
                    next_state = `STATE_FETCH;
            end
            `STATE_WRITEBACK: next_state = `STATE_FETCH;
            default: next_state = `STATE_FETCH;
        endcase
    end

    // Control signal generation
    always @(*) begin
        // Default values
        alu_ctrl = `ALU_ADD;
        alu_src_a = 2'b00;
        alu_src_b = 2'b00;
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b0;
        reg_dst = 2'b00;
        mem_to_reg = 2'b00;
        pc_src = 2'b00;
        pc_write = 1'b0;
        pc_write_cond = 1'b0;
        ir_write = 1'b0;
        ext_op = 1'b0;

        case (state)
            `STATE_FETCH: begin
                alu_src_a = 2'b00; // PC
                alu_src_b = 2'b01; // Constant 4
                alu_ctrl = `ALU_ADD;
                pc_write = 1'b1;
                ir_write = 1'b1;
                pc_src = 2'b00; // ALU result
            end
            
            `STATE_DECODE: begin
                alu_src_a = 2'b00; // PC
                alu_src_b = 2'b11; // Sign-extended immediate << 2
                alu_ctrl = `ALU_ADD;
                ext_op = 1'b1;
            end
            
            `STATE_EXECUTE: begin
                if (ADDU || SUBU || SLT) begin
                    alu_src_a = 2'b01; // Register A
                    alu_src_b = 2'b00; // Register B
                    if (ADDU) alu_ctrl = `ALU_ADD;
                    else if (SUBU) alu_ctrl = `ALU_SUB;
                    else if (SLT) alu_ctrl = `ALU_SLT;
                    reg_write = 1'b1;
                    reg_dst = 2'b01; // rd
                    mem_to_reg = 2'b00; // ALU result
                end
                else if (ADDI || ADDIU) begin
                    alu_src_a = 2'b01; // Register A
                    alu_src_b = 2'b10; // Sign-extended immediate
                    alu_ctrl = `ALU_ADD;
                    ext_op = 1'b1;
                    reg_write = 1'b1;
                    reg_dst = 2'b00; // rt
                    mem_to_reg = 2'b00; // ALU result
                end
                else if (ORI) begin
                    alu_src_a = 2'b01; // Register A
                    alu_src_b = 2'b10; // Zero-extended immediate
                    alu_ctrl = `ALU_OR;
                    ext_op = 1'b0;
                    reg_write = 1'b1;
                    reg_dst = 2'b00; // rt
                    mem_to_reg = 2'b00; // ALU result
                end
                else if (LUI) begin
                    alu_src_b = 2'b10; // Immediate
                    alu_ctrl = `ALU_LUI;
                    ext_op = 1'b0;
                    reg_write = 1'b1;
                    reg_dst = 2'b00; // rt
                    mem_to_reg = 2'b00; // ALU result
                end
                else if (LW || SW) begin
                    alu_src_a = 2'b01; // Register A
                    alu_src_b = 2'b10; // Sign-extended immediate
                    alu_ctrl = `ALU_ADD;
                    ext_op = 1'b1;
                end
                else if (BEQ) begin
                    alu_src_a = 2'b01; // Register A
                    alu_src_b = 2'b00; // Register B
                    alu_ctrl = `ALU_SUB;
                    pc_write_cond = 1'b1;
                    pc_src = 2'b01; // ALU_out (branch target calculated in decode)
                end
                else if (J || JAL) begin
                    pc_write = 1'b1;
                    pc_src = 2'b10; // Jump target
                    if (JAL) begin
                        reg_write = 1'b1;
                        reg_dst = 2'b10; // $ra
                        mem_to_reg = 2'b10; // PC+4
                    end
                end
                else if (JR) begin
                    pc_write = 1'b1;
                    pc_src = 2'b11; // Register A
                end
            end
            
            `STATE_MEMORY: begin
                if (LW) begin
                    mem_read = 1'b1;
                end
                else if (SW) begin
                    mem_write = 1'b1;
                end
            end
            
            `STATE_WRITEBACK: begin
                if (LW) begin
                    reg_write = 1'b1;
                    reg_dst = 2'b00; // rt
                    mem_to_reg = 2'b01; // Memory data
                end
            end
        endcase
    end

endmodule
