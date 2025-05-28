// ALU Module for MIPS Multi-cycle Processor
`include "definitions.vh"

module ALU(
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_ctrl,
    output reg [31:0] result,
    output zero
);

    always @(*) begin
        case (alu_ctrl)
            `ALU_ADD: result = a + b;
            `ALU_SUB: result = a - b;
            `ALU_OR:  result = a | b;
            `ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            `ALU_LUI: result = {b[15:0], 16'h0000};
            default:  result = 32'h0;
        endcase
    end

    assign zero = (result == 32'h0);

endmodule
