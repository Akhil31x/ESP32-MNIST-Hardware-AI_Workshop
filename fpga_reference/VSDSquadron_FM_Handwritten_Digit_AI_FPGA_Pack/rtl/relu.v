// ============================================================================
// File: relu_requant.v
// Module: relu_requant
// Description: Fixed-point ReLU activation and requantization scaler.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module relu_requant (
    input  wire signed [31:0] acc_in,
    input  wire        [15:0] mult_factor,
    input  wire        [4:0]  shift_amount,
    output wire        [7:0]  act_out
);

    wire [31:0] acc_pos;
    assign acc_pos = (acc_in > 32'sd0) ? acc_in[31:0] : 32'd0;

    // 32-bit positive accumulator * 16-bit multiplier factor = 48-bit product
    wire [47:0] raw_product;
    assign raw_product = acc_pos * mult_factor;

    // Rounding offset: 1 << (shift_amount - 1)
    wire [47:0] rounded_product;
    assign rounded_product = raw_product + (48'd1 << (shift_amount - 1));

    wire [47:0] shifted_value;
    assign shifted_value = rounded_product >> shift_amount;

    // Saturate to 7-bit positive integer [0, 127]
    assign act_out = (acc_in <= 32'sd0) ? 8'd0 :
                     (shifted_value > 48'd127) ? 8'd127 : shifted_value[7:0];

endmodule
