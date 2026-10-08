// ============================================================================
// File: weight_rom_l3.v
// Module: weight_rom_l3
// Description: Layer 3 Weight ROM (10 neurons x 16 inputs = 160 bytes).
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module weight_rom_l3 #(
    parameter MEM_FILE = "weights_l3.mem"
)(
    input  wire        clk,
    input  wire        ce,
    input  wire [7:0]  addr, // 0 to 159
    output reg  signed [7:0] data_out
);

    // 160 x 8-bit ROM
    reg signed [7:0] rom [0:159];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    always @(posedge clk) begin
        if (ce) begin
            data_out <= rom[addr];
        end
    end

endmodule
