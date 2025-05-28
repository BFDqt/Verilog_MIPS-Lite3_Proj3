// Sign Extender for MIPS Multi-cycle Processor
module SignExtender(
    input [15:0] imm16,
    input ext_op,
    output [31:0] imm32
);

    assign imm32 = ext_op ? {{16{imm16[15]}}, imm16} : {16'h0, imm16};

endmodule
