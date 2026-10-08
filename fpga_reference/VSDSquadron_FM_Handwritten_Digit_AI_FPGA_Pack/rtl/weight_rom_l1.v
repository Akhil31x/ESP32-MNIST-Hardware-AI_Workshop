// ============================================================================
// File: weight_rom_l1.v
// Module: weight_rom_l1
// Description: Layer 1 Weight ROM (32 neurons x 784 inputs = 25,088 bytes).
//              Infers Block RAM in Spartan-3E XC3S250E.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module weight_rom_l1 #(
    parameter MEM_FILE = "weights_l1.mem"
)(
    input  wire        clk,
    input  wire        ce,
    input  wire [14:0] addr, // 0 to 25087
    output reg  signed [7:0] data_out
);

    // 25088 x 8-bit ROM
    reg signed [7:0] rom [0:25087];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    always @(posedge clk) begin
        if (ce) begin
            data_out <= rom[addr];
        end
    end

endmodule
