// Generated machine code
initial begin
    memory[0] = 32'h2008000A;  // 2008000A
    memory[1] = 32'h20090005;  // 20090005
    memory[2] = 32'h01095021;  // 01095021
    memory[3] = 32'h01095823;  // 01095823
    memory[4] = 32'h240CFFFF;  // 240CFFFF
    memory[5] = 32'h340D00FF;  // 340D00FF
    memory[6] = 32'h3C0E1000;  // 3C0E1000
    memory[7] = 32'h0128782A;  // 0128782A
    memory[8] = 32'h0109C02A;  // 0109C02A
    memory[9] = 32'h20100064;  // 20100064
    memory[10] = 32'hAE080000;  // AE080000
    memory[11] = 32'hAE090004;  // AE090004
    memory[12] = 32'h8E110000;  // 8E110000
    memory[13] = 32'h8E120004;  // 8E120004
    memory[14] = 32'h12280001;  // 12280001
    memory[15] = 32'h20020001;  // 20020001
    memory[16] = 32'h20020002;  // 20020002
    memory[17] = 32'h0C000014;  // 0C000014
    memory[18] = 32'h20030003;  // 20030003
    memory[19] = 32'h08000016;  // 08000016
    memory[20] = 32'h2004002A;  // 2004002A
    memory[21] = 32'h03E00008;  // 03E00008
    memory[22] = 32'h20050063;  // 20050063
    memory[23] = 32'h08000016;  // 08000016
    // Fill rest with NOPs
    for (integer i = 24; i < 1024; i = i + 1) begin
        memory[i] = 32'h00000000;
    end
end