// mnist_infer.h
// Pure-integer MLP inference engine: bit-exact port of mnist_core.v / nn_mac.v
// from the VSDSquadron FPGA golden reference (784 -> 32 -> 16 -> 10).
// No floating point. No external ML library. Works on any MCU with 32-bit ints.
#pragma once
#include <stdint.h>
#include "weights.h"

// Requantize one accumulator value: ReLU, then multiply-shift-round, then clip to [0,127]
static inline uint8_t relu_requant(int32_t acc, uint32_t mult, uint32_t shift) {
    int64_t relu = acc > 0 ? acc : 0;
    int64_t val = (relu * (int64_t)mult + ((int64_t)1 << (shift - 1))) >> shift;
    if (val < 0) val = 0;
    if (val > 127) val = 127;
    return (uint8_t)val;
}

// Runs the full forward pass on one 784-byte quantized image (values 0..127).
// Returns predicted digit (0-9). If logits_out is non-null, writes the 10 raw
// int32 logits there (useful for a confidence display).
static inline int mnist_infer(const uint8_t *input_u8, int32_t *logits_out) {
    static int32_t a1[L1_OUT];
    static int32_t a2_tmp;
    uint8_t a1_q[L1_OUT];
    uint8_t a2_q[L2_OUT];
    int32_t acc3[L3_OUT];

    // Layer 1: 784 -> 32
    for (int n = 0; n < L1_OUT; n++) {
        int64_t acc = BIAS_L1[n];
        const int8_t *w_row = &W1[n * L1_IN];
        for (int k = 0; k < L1_IN; k++) {
            acc += (int32_t)w_row[k] * (int32_t)input_u8[k];
        }
        a1_q[n] = relu_requant((int32_t)acc, L1_MULT, L1_SHIFT);
    }

    // Layer 2: 32 -> 16
    for (int n = 0; n < L2_OUT; n++) {
        int64_t acc = BIAS_L2[n];
        const int8_t *w_row = &W2[n * L2_IN];
        for (int k = 0; k < L2_IN; k++) {
            acc += (int32_t)w_row[k] * (int32_t)a1_q[k];
        }
        a2_q[n] = relu_requant((int32_t)acc, L2_MULT, L2_SHIFT);
    }

    // Layer 3: 16 -> 10 (raw logits, no requant)
    for (int n = 0; n < L3_OUT; n++) {
        int64_t acc = BIAS_L3[n];
        const int8_t *w_row = &W3[n * L3_IN];
        for (int k = 0; k < L3_IN; k++) {
            acc += (int32_t)w_row[k] * (int32_t)a2_q[k];
        }
        acc3[n] = (int32_t)acc;
    }

    if (logits_out) {
        for (int n = 0; n < L3_OUT; n++) logits_out[n] = acc3[n];
    }

    int best = 0;
    for (int n = 1; n < L3_OUT; n++) {
        if (acc3[n] > acc3[best]) best = n;
    }
    return best;
}

