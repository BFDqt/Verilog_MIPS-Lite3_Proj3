// MIPS Multi-cycle Processor Top Module
`include "definitions.vh"

module MIPS_Multicycle(
    input clk,
    input rst
);

    // Internal signals
    wire [31:0] pc_next;
    wire [31:0] instruction;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] alu_result, alu_a, alu_b;
    wire [31:0] mem_data;
    wire [31:0] write_data;
    wire [31:0] sign_ext_imm;
    wire [4:0] write_reg;
    wire zero;
    
    // Control signals
    wire [2:0] alu_ctrl;
    wire [1:0] alu_src_a, alu_src_b;
    wire mem_read, mem_write;
    wire reg_write;
    wire [1:0] reg_dst, mem_to_reg;
    wire [1:0] pc_src;
    wire pc_write, pc_write_cond;
    wire ir_write, ext_op;
    wire [2:0] current_state;
    
    // Registers for multi-cycle operation
    reg [31:0] pc_reg;
    reg [31:0] instruction_reg;
    reg [31:0] a_reg, b_reg;
    reg [31:0] alu_out_reg;
    reg [31:0] mem_data_reg;
    
    // PC logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 32'h0;
        end else if (pc_write || (pc_write_cond && zero)) begin
            pc_reg <= pc_next;
        end
    end
    
    // PC next calculation
    wire [31:0] pc_plus_4 = pc_reg + 32'h4;
    wire [31:0] branch_target = alu_out_reg; // Calculated in decode stage
    wire [31:0] jump_target = {pc_plus_4[31:28], instruction_reg[25:0], 2'b00};
    
    always @(*) begin
        case (pc_src)
            2'b00: pc_next = alu_result; // PC+4 from fetch stage
            2'b01: pc_next = alu_out_reg; // Branch target
            2'b10: pc_next = jump_target; // Jump target
            2'b11: pc_next = a_reg; // JR target
            default: pc_next = pc_plus_4;
        endcase
    end
    
    // Instruction register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instruction_reg <= 32'h0;
        end else if (ir_write) begin
            instruction_reg <= instruction;
        end
    end
    
    // A and B registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_reg <= 32'h0;
            b_reg <= 32'h0;
        end else if (current_state == `STATE_DECODE) begin
            a_reg <= reg_data1;
            b_reg <= reg_data2;
        end
    end
    
    // ALU output register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alu_out_reg <= 32'h0;
        end else begin
            alu_out_reg <= alu_result;
        end
    end
    
    // Memory data register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_data_reg <= 32'h0;
        end else if (current_state == `STATE_MEMORY) begin
            mem_data_reg <= mem_data;
        end
    end
    
    // ALU input multiplexers
    always @(*) begin
        case (alu_src_a)
            2'b00: alu_a = pc_reg; // PC
            2'b01: alu_a = a_reg;  // Register data
            default: alu_a = pc_reg;
        endcase
    end
    
    always @(*) begin
        case (alu_src_b)
            2'b00: alu_b = b_reg;           // Register data
            2'b01: alu_b = 32'h4;           // Constant 4
            2'b10: alu_b = sign_ext_imm;    // Immediate
            2'b11: alu_b = sign_ext_imm << 2; // Shifted immediate for branch
            default: alu_b = b_reg;
        endcase
    end
    
    // Register write address multiplexer
    assign write_reg = (reg_dst == 2'b00) ? instruction_reg[20:16] :  // rt
                       (reg_dst == 2'b01) ? instruction_reg[15:11] :  // rd
                       5'h1f;  // $ra for JAL
    
    // Register write data multiplexer
    assign write_data = (mem_to_reg == 2'b00) ? alu_out_reg :        // ALU result
                        (mem_to_reg == 2'b01) ? mem_data_reg :       // Memory data
                        pc_reg + 32'h4;  // PC+4 for JAL
    
    // Module instantiations
    InstructionMemory imem(
        .address(pc_reg),
        .instruction(instruction)
    );
    
    RegisterFile regfile(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(instruction_reg[25:21]),
        .read_reg2(instruction_reg[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );
    
    ALU alu(
        .a(alu_a),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );
    
    DataMemory dmem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_out_reg),
        .write_data(b_reg),
        .read_data(mem_data)
    );
    
    SignExtender sign_ext(
        .imm16(instruction_reg[15:0]),
        .ext_op(ext_op),
        .imm32(sign_ext_imm)
    );
    
    ControlUnit control(
        .clk(clk),
        .rst(rst),
        .instr(instruction_reg),
        .zero(zero),
        .alu_ctrl(alu_ctrl),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg),
        .pc_src(pc_src),
        .pc_write(pc_write),
        .pc_write_cond(pc_write_cond),
        .ir_write(ir_write),
        .ext_op(ext_op),
        .current_state(current_state)
    );

endmodule
