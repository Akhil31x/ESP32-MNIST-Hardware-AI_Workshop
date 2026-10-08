// ============================================================================
// File: activation_mem.v
// Module: activation_mem
// Description: On-chip activation buffer for Layer 1 (32 bytes) and Layer 2 (16 bytes).
//              Synthesizes into distributed LUT RAM / registers in Spartan-3E.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module activation_mem (
    input  wire        clk,
    input  wire        reset,
    
    // Layer 1 write port (from L1 ReLU/requant)
    input  wire        l1_we,
    input  wire [4:0]  l1_waddr, // 0 to 31
    input  wire [7:0]  l1_wdata,
    
    // Layer 1 read port (to L2 MAC)
    input  wire [4:0]  l1_raddr, // 0 to 31
    output wire [7:0]  l1_rdata,
    
    // Layer 2 write port (from L2 ReLU/requant)
    input  wire        l2_we,
    input  wire [3:0]  l2_waddr, // 0 to 15
    input  wire [7:0]  l2_wdata,
    
    // Layer 2 read port (to L3 MAC)
    input  wire [3:0]  l2_raddr, // 0 to 15
    output wire [7:0]  l2_rdata
);

    reg [7:0] l1_mem [0:31];
    reg [7:0] l2_mem [0:15];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                l1_mem[i] <= 8'd0;
            end
            for (i = 0; i < 16; i = i + 1) begin
                l2_mem[i] <= 8'd0;
            end
        end else begin
            if (l1_we) begin
                l1_mem[l1_waddr] <= l1_wdata;
            end
            if (l2_we) begin
                l2_mem[l2_waddr] <= l2_wdata;
            end
        end
    end

    assign l1_rdata = l1_mem[l1_raddr];
    assign l2_rdata = l2_mem[l2_raddr];

endmodule
