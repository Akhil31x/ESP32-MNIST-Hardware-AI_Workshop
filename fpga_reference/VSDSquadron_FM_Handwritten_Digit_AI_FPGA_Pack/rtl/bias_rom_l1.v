// ============================================================================
// File: bias_rom_l1.v
// Module: bias_rom_l1
// Description: Layer 1 Bias ROM (32 neurons x 32-bit words).
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module bias_rom_l1 #(
    parameter MEM_FILE = "bias_l1.mem"
)(
    input  wire        clk,
    input  wire        ce,
    input  wire [4:0]  addr, // 0 to 31
    output reg  signed [31:0] data_out
);

    // 32 x 32-bit ROM
    reg signed [31:0] rom [0:31];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    always @(posedge clk) begin
        if (ce) begin
            data_out <= rom[addr];
        end
    end

endmodule
