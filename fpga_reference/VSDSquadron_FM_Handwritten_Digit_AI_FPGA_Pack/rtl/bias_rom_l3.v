// ============================================================================
// File: bias_rom_l3.v
// Module: bias_rom_l3
// Description: Layer 3 Bias ROM (10 neurons x 32-bit words).
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module bias_rom_l3 #(
    parameter MEM_FILE = "bias_l3.mem"
)(
    input  wire        clk,
    input  wire        ce,
    input  wire [3:0]  addr, // 0 to 9
    output reg  signed [31:0] data_out
);

    // 10 x 32-bit ROM
    reg signed [31:0] rom [0:9];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    always @(posedge clk) begin
        if (ce) begin
            data_out <= rom[addr];
        end
    end

endmodule
