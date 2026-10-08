// ============================================================================
// File: top.v
// Module: top
// Description: Top-level module for VSDSquadron FM (Lattice iCE40UP5K).
//              Integrates internal 48 MHz oscillator (or external 12 MHz clock),
//              MNIST inference engine, sample ROM, and RGB status LEDs.
// ============================================================================

`timescale 1ns/1ps

module top (
    // External hardware clock (Pin 20 if present, or optional)
    input  wire        hw_clk,

    // Push switches (active-high or active-low debounced)
    input  wire        sw0,            // Run inference trigger
    input  wire        sw1,            // Reset

    // Discrete board LEDs (Pins 13, 18, 19, 21 - active-low)
    output wire        led0,           // Predicted digit bit 0
    output wire        led1,           // Predicted digit bit 1
    output wire        led2,           // Predicted digit bit 2
    output wire        led3,           // Predicted digit bit 3

    // RGB LED pins (Pins 39, 40, 41 - active-low)
    output wire        led_red,
    output wire        led_blue,
    output wire        led_green
);

    // Clock Selection:
    // On Lattice iCE40, we can use the internal high-frequency oscillator SB_HFOSC (48 MHz)
    // or the external clock input. Here we instantiate SB_HFOSC for self-contained operation.
    wire clk_48mhz;
    
    // SB_HFOSC primitive configured for 48 MHz (DIV = 0b00: 48 MHz)
    SB_HFOSC #(.CLKHF_DIV("0b00")) osc_inst (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk_48mhz)
    );

    // Clock divider to generate a stable 12 MHz clock for inference core
    reg [1:0] clk_div;
    always @(posedge clk_48mhz) begin
        clk_div <= clk_div + 2'b01;
    end
    wire sys_clk = clk_div[1]; // 12 MHz

    // Active-high reset logic
    wire rst = sw1;

    // Trigger logic
    reg [2:0] start_sync;
    always @(posedge sys_clk or posedge rst) begin
        if (rst)
            start_sync <= 3'b000;
        else
            start_sync <= {start_sync[1:0], sw0};
    end
    wire start_pulse = (start_sync[2:1] == 2'b01);

    // Preloaded sample selection counter (cycles 0 through 9 on each press)
    reg [3:0] sample_sel;
    always @(posedge sys_clk or posedge rst) begin
        if (rst) begin
            sample_sel <= 4'd0;
        end else if (start_pulse) begin
            if (sample_sel == 4'd9)
                sample_sel <= 4'd0;
            else
                sample_sel <= sample_sel + 4'd1;
        end
    end

    // Core Interconnects
    wire        core_busy;
    wire        core_done;
    wire [3:0]  pred_digit;
    wire signed [31:0] max_logit;
    wire [3:0]  layer_state;

    // Instantiate MNIST Accelerator Top
    // Reuses verified ROMs and arithmetic core
    mnist_accelerator_top #(
        .WEIGHTS_L1_FILE("weights_l1.mem"),
        .WEIGHTS_L2_FILE("weights_l2.mem"),
        .WEIGHTS_L3_FILE("weights_l3.mem"),
        .BIAS_L1_FILE("bias_l1.mem"),
        .BIAS_L2_FILE("bias_l2.mem"),
        .BIAS_L3_FILE("bias_l3.mem"),
        .SAMPLES_FILE("samples_all.mem")
    ) accel_inst (
        .clk(sys_clk),
        .reset(rst),
        .start(start_pulse),
        .sample_select(sample_sel),
        .external_source(1'b0),
        .ext_pixel_data(8'd0),
        .ext_pixel_addr(),
        .busy(core_busy),
        .done(core_done),
        .predicted_digit(pred_digit),
        .max_logit(max_logit),
        .layer_state(layer_state)
    );

    // Discrete 4-bit output LEDs (active-low on VSDSquadron FM)
    assign led0 = ~pred_digit[0];
    assign led1 = ~pred_digit[1];
    assign led2 = ~pred_digit[2];
    assign led3 = ~pred_digit[3];

    // Instantiate RGB Status Controller
    rgb_status rgb_inst (
        .clk(sys_clk),
        .reset(rst),
        .busy(core_busy),
        .done(core_done),
        .predicted_digit(pred_digit),
        .led_red(led_red),
        .led_green(led_green),
        .led_blue(led_blue)
    );

endmodule
