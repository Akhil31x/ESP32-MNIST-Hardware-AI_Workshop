// ============================================================================
// File: argmax_unit.v
// Module: argmax_unit
// Description: Finds the maximum logit index across 10 output classes.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module argmax_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire signed [31:0] logit_in,
    input  wire        logit_valid,
    input  wire [3:0]  digit_index,
    input  wire        done_logits,
    output reg  [3:0]  predicted_digit,
    output reg  signed [31:0] max_logit_out,
    output reg         valid_out
);

    reg signed [31:0] current_max;
    reg [3:0]         current_digit;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_max     <= -32'sd2147483648;
            current_digit   <= 4'd0;
            predicted_digit <= 4'd0;
            max_logit_out   <= 32'sd0;
            valid_out       <= 1'b0;
        end else begin
            if (start) begin
                current_max <= -32'sd2147483648;
                current_digit <= 4'd0;
                valid_out <= 1'b0;
            end else if (logit_valid) begin
                if (logit_in > current_max) begin
                    current_max   <= logit_in;
                    current_digit <= digit_index;
                end
            end

            if (done_logits) begin
                predicted_digit <= current_digit;
                max_logit_out   <= current_max;
                valid_out       <= 1'b1;
            end
        end
    end

endmodule
