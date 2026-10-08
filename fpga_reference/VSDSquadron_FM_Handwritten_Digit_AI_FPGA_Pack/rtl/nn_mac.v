// ============================================================================
// File: mac_unit.v
// Module: mac_unit
// Description: Signed 8x8 multiplier with 32-bit accumulator for MNIST MLP.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module mac_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        ce,
    input  wire        clear_acc,
    input  wire        load_bias,
    input  wire signed [31:0] bias_in,
    input  wire signed [7:0]  weight_in,
    input  wire signed [7:0]  act_in,
    output reg  signed [31:0] acc_out
);

    wire signed [15:0] product;
    assign product = weight_in * act_in;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acc_out <= 32'sd0;
        end else if (ce) begin
            if (clear_acc) begin
                acc_out <= 32'sd0;
            end else if (load_bias) begin
                acc_out <= bias_in + {{16{product[15]}}, product};
            end else begin
                acc_out <= acc_out + {{16{product[15]}}, product};
            end
        end
    end

endmodule
