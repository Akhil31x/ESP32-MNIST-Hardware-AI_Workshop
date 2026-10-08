// ============================================================================
// File: mnist_core.v
// Module: mnist_core
// Description: Multi-Layer Perceptron (MLP 784 -> 32 -> 16 -> 10) Inference FSM.
//              Sequences MAC unit, ROMs, activation RAM, ReLU/Requant, and Argmax.
// Target: Xilinx Spartan-3E XC3S250E (Synthesizable with ISE 8.1i+)
// Standard: Verilog-2001
// ============================================================================

`timescale 1ns/1ps

module mnist_core (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    
    // Pixel stream / memory read interface
    output reg  [9:0]  pixel_addr,       // 0 to 783
    input  wire [7:0]  pixel_data,       // Input pixel intensity (unsigned 8-bit [0, 127])
    
    // Weight & Bias ROM interfaces
    output reg  [14:0] w1_addr,
    input  wire signed [7:0]  w1_data,
    output reg  [4:0]  b1_addr,
    input  wire signed [31:0] b1_data,
    
    output reg  [8:0]  w2_addr,
    input  wire signed [7:0]  w2_data,
    output reg  [3:0]  b2_addr,
    input  wire signed [31:0] b2_data,
    
    output reg  [7:0]  w3_addr,
    input  wire signed [7:0]  w3_data,
    output reg  [3:0]  b3_addr,
    input  wire signed [31:0] b3_data,
    
    // Control & Status Outputs
    output reg         busy,
    output reg         done,
    output wire [3:0]  predicted_digit,
    output wire signed [31:0] max_logit,
    output reg  [3:0]  current_state_out
);

    // Requantization parameters (calibrated golden reference)
    localparam [15:0] L1_MULT  = 16'd4518;
    localparam [4:0]  L1_SHIFT = 5'd24;
    localparam [15:0] L2_MULT  = 16'd53032;
    localparam [4:0]  L2_SHIFT = 5'd24;

    // FSM States
    localparam [3:0]
        ST_IDLE      = 4'd0,
        ST_L1_INIT   = 4'd1,
        ST_L1_MAC    = 4'd2,
        ST_L1_STORE  = 4'd3,
        ST_L2_INIT   = 4'd4,
        ST_L2_MAC    = 4'd5,
        ST_L2_STORE  = 4'd6,
        ST_L3_INIT   = 4'd7,
        ST_L3_MAC    = 4'd8,
        ST_L3_STORE  = 4'd9,
        ST_DONE      = 4'd10;

    reg [3:0] state;
    
    // Counters
    reg [5:0] neuron_idx; // up to 32
    reg [9:0] k_idx;      // up to 784

    // Activation memory control
    reg        l1_we;
    reg [4:0]  l1_waddr;
    wire [7:0] l1_wdata;
    reg [4:0]  l1_raddr;
    wire [7:0] l1_rdata;

    reg        l2_we;
    reg [3:0]  l2_waddr;
    wire [7:0] l2_wdata;
    reg [3:0]  l2_raddr;
    wire [7:0] l2_rdata;

    // Instantiate Activation Memory
    activation_mem act_mem_inst (
        .clk      (clk),
        .reset    (reset),
        .l1_we    (l1_we),
        .l1_waddr (l1_waddr),
        .l1_wdata (l1_wdata),
        .l1_raddr (l1_raddr),
        .l1_rdata (l1_rdata),
        .l2_we    (l2_we),
        .l2_waddr (l2_waddr),
        .l2_wdata (l2_wdata),
        .l2_raddr (l2_raddr),
        .l2_rdata (l2_rdata)
    );

    // MAC Unit signals
    reg         mac_ce;
    reg         mac_clear;
    reg         mac_load_bias;
    reg  signed [31:0] mac_bias_in;
    reg  signed [7:0]  mac_weight_in;
    reg  signed [7:0]  mac_act_in;
    wire signed [31:0] mac_acc_out;

    mac_unit mac_inst (
        .clk       (clk),
        .reset     (reset),
        .ce        (mac_ce),
        .clear_acc (mac_clear),
        .load_bias (mac_load_bias),
        .bias_in   (mac_bias_in),
        .weight_in (mac_weight_in),
        .act_in    (mac_act_in),
        .acc_out   (mac_acc_out)
    );

    // ReLU / Requant Unit signals (combinatorially connected to mac_acc_out)
    wire [15:0] relu_mult;
    wire [4:0]  relu_shift;
    wire [7:0]  relu_act_out;

    assign relu_mult   = (state == ST_L2_STORE) ? L2_MULT : L1_MULT;
    assign relu_shift  = 5'd24;
    assign l1_wdata    = relu_act_out;
    assign l2_wdata    = relu_act_out;

    relu_requant relu_inst (
        .acc_in       (mac_acc_out),
        .mult_factor  (relu_mult),
        .shift_amount (relu_shift),
        .act_out      (relu_act_out)
    );

    // Argmax Unit signals
    reg         argmax_start;
    reg         argmax_logit_valid;
    reg  [3:0]  argmax_digit_idx;
    reg         argmax_done_logits;
    wire        argmax_valid;

    argmax_unit argmax_inst (
        .clk             (clk),
        .reset           (reset),
        .start           (argmax_start),
        .logit_in        (mac_acc_out),
        .logit_valid     (argmax_logit_valid),
        .digit_index     (argmax_digit_idx),
        .done_logits     (argmax_done_logits),
        .predicted_digit (predicted_digit),
        .max_logit_out   (max_logit),
        .valid_out       (argmax_valid)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state              <= ST_IDLE;
            busy               <= 1'b0;
            done               <= 1'b0;
            neuron_idx         <= 6'd0;
            k_idx              <= 10'd0;
            pixel_addr         <= 10'd0;
            w1_addr            <= 15'd0;
            b1_addr            <= 5'd0;
            w2_addr            <= 9'd0;
            b2_addr            <= 4'd0;
            w3_addr            <= 8'd0;
            b3_addr            <= 4'd0;
            l1_we              <= 1'b0;
            l1_waddr           <= 5'd0;
            l1_raddr           <= 5'd0;
            l2_we              <= 1'b0;
            l2_waddr           <= 4'd0;
            l2_raddr           <= 4'd0;
            mac_ce             <= 1'b0;
            mac_clear          <= 1'b0;
            mac_load_bias      <= 1'b0;
            mac_bias_in        <= 32'sd0;
            mac_weight_in      <= 8'sd0;
            mac_act_in         <= 8'sd0;
            argmax_start       <= 1'b0;
            argmax_logit_valid <= 1'b0;
            argmax_digit_idx   <= 4'd0;
            argmax_done_logits <= 1'b0;
            current_state_out  <= ST_IDLE;
        end else begin
            // Default strobe resets
            done               <= 1'b0;
            l1_we              <= 1'b0;
            l2_we              <= 1'b0;
            mac_ce             <= 1'b0;
            mac_clear          <= 1'b0;
            mac_load_bias      <= 1'b0;
            argmax_start       <= 1'b0;
            argmax_logit_valid <= 1'b0;
            argmax_done_logits <= 1'b0;
            current_state_out  <= state;

            case (state)

                ST_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy         <= 1'b1;
                        neuron_idx   <= 6'd0;
                        k_idx        <= 10'd0;
                        b1_addr      <= 5'd0;
                        argmax_start <= 1'b1;
                        state        <= ST_L1_INIT;
                    end
                end

                // ============================================================
                // LAYER 1: 784 -> 32
                // ============================================================
                ST_L1_INIT: begin
                    mac_ce        <= 1'b1;
                    mac_load_bias <= 1'b1;
                    mac_bias_in   <= b1_data;
                    mac_weight_in <= 8'sd0;
                    mac_act_in    <= 8'sd0;
                    
                    // Setup first weight and input address
                    w1_addr       <= (neuron_idx * 10'd784) + 10'd0;
                    pixel_addr    <= 10'd0;
                    k_idx         <= 10'd0;
                    state         <= ST_L1_MAC;
                end

                ST_L1_MAC: begin
                    mac_ce        <= 1'b1;
                    mac_load_bias <= 1'b0;
                    mac_weight_in <= w1_data;
                    mac_act_in    <= {1'b0, pixel_data[6:0]}; // Unsigned [0, 127] as signed 8-bit

                    if (k_idx < 10'd783) begin
                        k_idx      <= k_idx + 10'd1;
                        w1_addr    <= (neuron_idx * 10'd784) + (k_idx + 10'd1);
                        pixel_addr <= k_idx + 10'd1;
                    end else begin
                        state <= ST_L1_STORE;
                    end
                end

                ST_L1_STORE: begin
                    l1_we    <= 1'b1;
                    l1_waddr <= neuron_idx[4:0];

                    if (neuron_idx < 6'd31) begin
                        neuron_idx <= neuron_idx + 6'd1;
                        b1_addr    <= neuron_idx[4:0] + 5'd1;
                        state      <= ST_L1_INIT;
                    end else begin
                        // Layer 1 Complete -> Transition to Layer 2
                        neuron_idx <= 6'd0;
                        b2_addr    <= 4'd0;
                        state      <= ST_L2_INIT;
                    end
                end

                // ============================================================
                // LAYER 2: 32 -> 16
                // ============================================================
                ST_L2_INIT: begin
                    mac_ce        <= 1'b1;
                    mac_load_bias <= 1'b1;
                    mac_bias_in   <= b2_data;
                    mac_weight_in <= 8'sd0;
                    mac_act_in    <= 8'sd0;

                    w2_addr  <= (neuron_idx[3:0] * 6'd32) + 6'd0;
                    l1_raddr <= 5'd0;
                    k_idx    <= 10'd0;
                    state    <= ST_L2_MAC;
                end

                ST_L2_MAC: begin
                    mac_ce        <= 1'b1;
                    mac_load_bias <= 1'b0;
                    mac_weight_in <= w2_data;
                    mac_act_in    <= l1_rdata;

                    if (k_idx < 10'd31) begin
                        k_idx    <= k_idx + 10'd1;
                        w2_addr  <= (neuron_idx[3:0] * 6'd32) + (k_idx[4:0] + 5'd1);
                        l1_raddr <= k_idx[4:0] + 5'd1;
                    end else begin
                        state <= ST_L2_STORE;
                    end
                end

                ST_L2_STORE: begin
                    l2_we    <= 1'b1;
                    l2_waddr <= neuron_idx[3:0];

                    if (neuron_idx < 6'd15) begin
                        neuron_idx <= neuron_idx + 6'd1;
                        b2_addr    <= neuron_idx[3:0] + 4'd1;
                        state      <= ST_L2_INIT;
                    end else begin
                        // Layer 2 Complete -> Transition to Layer 3
                        neuron_idx <= 6'd0;
                        b3_addr    <= 4'd0;
                        state      <= ST_L3_INIT;
                    end
                end

                // ============================================================
                // LAYER 3: 16 -> 10 (Logits)
                // ============================================================
                ST_L3_INIT: begin
                    mac_ce        <= 1'b1;
                    mac_load_bias <= 1'b1;
                    mac_bias_in   <= b3_data;
                    mac_weight_in <= 8'sd0;
                    mac_act_in    <= 8'sd0;

                    w3_addr  <= (neuron_idx[3:0] * 5'd16) + 5'd0;
                    l2_raddr <= 4'd0;
                    k_idx    <= 10'd0;
                    state    <= ST_L3_MAC;
                end

                ST_L3_MAC: begin
                    mac_ce        <= 1'b1;
                    mac_load_bias <= 1'b0;
                    mac_weight_in <= w3_data;
                    mac_act_in    <= l2_rdata;

                    if (k_idx < 10'd15) begin
                        k_idx    <= k_idx + 10'd1;
                        w3_addr  <= (neuron_idx[3:0] * 5'd16) + (k_idx[3:0] + 4'd1);
                        l2_raddr <= k_idx[3:0] + 4'd1;
                    end else begin
                        state <= ST_L3_STORE;
                    end
                end

                ST_L3_STORE: begin
                    // Send raw logit to argmax unit
                    argmax_digit_idx   <= neuron_idx[3:0];
                    argmax_logit_valid <= 1'b1;

                    if (neuron_idx < 6'd9) begin
                        neuron_idx <= neuron_idx + 6'd1;
                        b3_addr    <= neuron_idx[3:0] + 4'd1;
                        state      <= ST_L3_INIT;
                    end else begin
                        // All 10 logits calculated
                        argmax_done_logits <= 1'b1;
                        state              <= ST_DONE;
                    end
                end

                ST_DONE: begin
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    state <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
