// ============================================================================
// File: sample_rom.v
// Module: sample_rom
// Description: On-chip test sample ROM containing 10 pre-loaded MNIST test digits
//              (Digits 0-9, 784 bytes each = 7,840 bytes total).
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module sample_rom #(
    parameter MEM_FILE = "samples_all.mem"
)(
    input  wire        clk,
    input  wire        ce,
    input  wire [3:0]  sample_idx, // 0 to 9
    input  wire [9:0]  pixel_addr, // 0 to 783
    output reg  [7:0]  pixel_data
);

    // 7840 x 8-bit ROM
    reg [7:0] rom [0:7839];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    wire [12:0] full_addr;
    assign full_addr = (sample_idx * 10'd784) + pixel_addr;

    always @(posedge clk) begin
        if (ce) begin
            pixel_data <= rom[full_addr];
        end
    end

endmodule
