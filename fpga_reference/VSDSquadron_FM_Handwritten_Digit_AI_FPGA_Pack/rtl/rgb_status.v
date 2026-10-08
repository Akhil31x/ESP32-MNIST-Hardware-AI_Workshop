// ============================================================================
// File: rgb_status.v
// Module: rgb_status
// Description: Multi-state RGB LED status driver for VSDSquadron FM.
//              Pins 39 (Red), 40 (Blue), 41 (Green) on Lattice iCE40UP5K.
//              Note: On iCE40, onboard LEDs are active-low.
// ============================================================================

`timescale 1ns/1ps

module rgb_status (
    input  wire       clk,
    input  wire       reset,
    input  wire       busy,
    input  wire       done,
    input  wire [3:0] predicted_digit,
    output reg        led_red,
    output reg        led_green,
    output reg        led_blue
);

    // Simple heartbeat / blink counter
    reg [23:0] blink_cnt;
    always @(posedge clk or posedge reset) begin
        if (reset)
            blink_cnt <= 24'd0;
        else
            blink_cnt <= blink_cnt + 24'd1;
    end

    // Active-LOW LED control: 0 = ON, 1 = OFF
    always @(*) begin
        if (reset) begin
            // Solid Yellow (Red + Green ON, Blue OFF) during reset
            led_red   = 1'b0;
            led_green = 1'b0;
            led_blue  = 1'b1;
        end else if (busy) begin
            // Blinking Blue during inference
            led_red   = 1'b1;
            led_green = 1'b1;
            led_blue  = blink_cnt[21]; // fast blink
        end else if (done) begin
            // Green ON, Red OFF, Blue OFF when inference done and valid
            led_red   = 1'b1;
            led_green = 1'b0; // Solid Green
            led_blue  = 1'b1;
        end else begin
            // Idle: Breathing / slow pulsing White (Red + Green + Blue)
            led_red   = blink_cnt[23];
            led_green = blink_cnt[23];
            led_blue  = blink_cnt[23];
        end
    end

endmodule
