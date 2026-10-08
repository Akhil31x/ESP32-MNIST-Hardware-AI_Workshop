// ============================================================================
// File: weight_rom_l2.v
// Module: weight_rom_l2
// Description: Layer 2 Weight ROM (16 neurons x 32 inputs = 512 bytes).
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module weight_rom_l2 #(
    parameter MEM_FILE = "weights_l2.mem"
)(
    input  wire        clk,
    input  wire        ce,
    input  wire [8:0]  addr, // 0 to 511
    output reg  signed [7:0] data_out
);

    // 512 x 8-bit ROM
    reg signed [7:0] rom [0:511];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    always @(posedge clk) begin
        if (ce) begin
            data_out <= rom[addr];
        end
    end

endmodule
