// ============================================================================
// File: mnist_accelerator_top.v
// Module: mnist_accelerator_top
// Description: Top-level standalone MNIST Neural Network Accelerator module.
//              Integrates inference core, weight ROMs, bias ROMs, and sample ROM.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module mnist_accelerator_top #(
    parameter WEIGHTS_L1_FILE = "weights_l1.mem",
    parameter WEIGHTS_L2_FILE = "weights_l2.mem",
    parameter WEIGHTS_L3_FILE = "weights_l3.mem",
    parameter BIAS_L1_FILE    = "bias_l1.mem",
    parameter BIAS_L2_FILE    = "bias_l2.mem",
    parameter BIAS_L3_FILE    = "bias_l3.mem",
    parameter SAMPLES_FILE    = "samples_all.mem"
)(
    input  wire        clk,
    input  wire        reset,
    
    // Control interface
    input  wire        start,
    input  wire [3:0]  sample_select,   // 0 to 9 selects preloaded test image
    
    // External pixel interface (optional, if external_source = 1)
    input  wire        external_source,
    input  wire [7:0]  ext_pixel_data,
    output wire [9:0]  ext_pixel_addr,
    
    // Status & Result outputs
    output wire        busy,
    output wire        done,
    output wire [3:0]  predicted_digit,
    output wire signed [31:0] max_logit,
    output wire [3:0]  layer_state
);

    // Internal interconnects
    wire [9:0]  core_pixel_addr;
    wire [7:0]  core_pixel_data;
    wire [7:0]  rom_pixel_data;

    wire [14:0] w1_addr;
    wire signed [7:0]  w1_data;
    wire [4:0]  b1_addr;
    wire signed [31:0] b1_data;

    wire [8:0]  w2_addr;
    wire signed [7:0]  w2_data;
    wire [3:0]  b2_addr;
    wire signed [31:0] b2_data;

    wire [7:0]  w3_addr;
    wire signed [7:0]  w3_data;
    wire [3:0]  b3_addr;
    wire signed [31:0] b3_data;

    assign ext_pixel_addr  = core_pixel_addr;
    assign core_pixel_data = external_source ? ext_pixel_data : rom_pixel_data;

    // ------------------------------------------------------------------------
    // Sample ROM (10 Preloaded MNIST Test Images)
    // ------------------------------------------------------------------------
    sample_rom #(
        .MEM_FILE(SAMPLES_FILE)
    ) sample_rom_inst (
        .clk        (clk),
        .ce         (1'b1),
        .sample_idx (sample_select),
        .pixel_addr (core_pixel_addr),
        .pixel_data (rom_pixel_data)
    );

    // ------------------------------------------------------------------------
    // Weight & Bias ROMs
    // ------------------------------------------------------------------------
    weight_rom_l1 #(.MEM_FILE(WEIGHTS_L1_FILE)) w_rom1 (.clk(clk), .ce(1'b1), .addr(w1_addr), .data_out(w1_data));
    bias_rom_l1   #(.MEM_FILE(BIAS_L1_FILE))    b_rom1 (.clk(clk), .ce(1'b1), .addr(b1_addr), .data_out(b1_data));

    weight_rom_l2 #(.MEM_FILE(WEIGHTS_L2_FILE)) w_rom2 (.clk(clk), .ce(1'b1), .addr(w2_addr), .data_out(w2_data));
    bias_rom_l2   #(.MEM_FILE(BIAS_L2_FILE))    b_rom2 (.clk(clk), .ce(1'b1), .addr(b2_addr), .data_out(b2_data));

    weight_rom_l3 #(.MEM_FILE(WEIGHTS_L3_FILE)) w_rom3 (.clk(clk), .ce(1'b1), .addr(w3_addr), .data_out(w3_data));
    bias_rom_l3   #(.MEM_FILE(BIAS_L3_FILE))    b_rom3 (.clk(clk), .ce(1'b1), .addr(b3_addr), .data_out(b3_data));

    // ------------------------------------------------------------------------
    // MNIST Inference Core
    // ------------------------------------------------------------------------
    mnist_core core_inst (
        .clk               (clk),
        .reset             (reset),
        .start             (start),
        .pixel_addr        (core_pixel_addr),
        .pixel_data        (core_pixel_data),
        .w1_addr           (w1_addr),
        .w1_data           (w1_data),
        .b1_addr           (b1_addr),
        .b1_data           (b1_data),
        .w2_addr           (w2_addr),
        .w2_data           (w2_data),
        .b2_addr           (b2_addr),
        .b2_data           (b2_data),
        .w3_addr           (w3_addr),
        .w3_data           (w3_data),
        .b3_addr           (b3_addr),
        .b3_data           (b3_data),
        .busy              (busy),
        .done              (done),
        .predicted_digit   (predicted_digit),
        .max_logit         (max_logit),
        .current_state_out (layer_state)
    );

endmodule
