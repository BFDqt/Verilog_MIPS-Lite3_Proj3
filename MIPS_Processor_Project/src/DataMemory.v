// Data Memory for MIPS Multi-cycle Processor
module DataMemory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] memory [1023:0]; // 1KB data memory
    
    // Initialize memory
    initial begin
        for (integer i = 0; i < 1024; i = i + 1) begin
            memory[i] = 32'h0;
        end
    end

    // Write operation
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[11:2]] <= write_data;
        end
    end

    // Read operation
    assign read_data = mem_read ? memory[address[11:2]] : 32'h0;

endmodule
