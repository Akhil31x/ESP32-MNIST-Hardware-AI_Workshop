# VSDSquadron FM — FPGA Handwritten Digit AI Accelerator Pack

**Target Board**: VSDSquadron FM (FPGA Mini)  
**FPGA Device**: Lattice iCE40UP5K-SG48  
**Toolchain**: Yosys (Synthesis) + nextpnr-ice40 (Place & Route) + Project IceStorm (`icepack` / `iceprog`)  
**Neural Network**: MLP (784 $\to$ 32 $\to$ 16 $\to$ 10, 25,818 parameters)  
**Accuracy**: 95.75% FP32 / 95.76% Fixed-Point INT8

---

## Directory Structure

```text
VSDSquadron_FM_Handwritten_Digit_AI_FPGA_Pack/
├── rtl/
│   ├── top.v                   # Top-level module with SB_HFOSC and button triggers
│   ├── rgb_status.v            # Tri-color RGB LED state machine (Pins 39, 40, 41)
│   ├── nn_mac.v                # Pipelined signed multiplier-accumulator
│   ├── relu.v                  # Fixed-point ReLU activation & requantizer
│   ├── argmax10.v              # 10-class max-logit finder
│   ├── activation_mem.v        # Scratchpad activation memory
│   ├── mnist_core.v            # Complete MLP sequencing state machine
│   ├── mnist_accelerator_top.v # Interconnect top wrapper
│   ├── weight_rom_l1.v         # Layer 1 weight memory (25,088 bytes)
│   ├── weight_rom_l2.v         # Layer 2 weight memory (512 bytes)
│   ├── weight_rom_l3.v         # Layer 3 weight memory (160 bytes)
│   ├── bias_rom_l1.v           # Layer 1 bias memory (32 ints)
│   ├── bias_rom_l2.v           # Layer 2 bias memory (16 ints)
│   ├── bias_rom_l3.v           # Layer 3 bias memory (10 ints)
│   └── sample_rom.v            # Preloaded 10 MNIST test samples ROM
├── model/
│   └── best_model.pt           # Genuine PyTorch golden model checkpoint (SHA256: ccfd0de9...)
├── tools/
│   └── export_weights.py       # Python script for quantizing & exporting weights
├── docs/
│   ├── WORKSHOP.md             # Hands-on student workshop guide
│   └── BOARD_NOTES.md          # Pinout specifications & board details
├── Makefile                    # One-command synthesis & flashing: make build && sudo make flash
├── VSDSquadronFM.pcf           # Physical constraint pin assignments for SG48
└── README.md                   # This overview
```

---

## One-Command Build

```bash
make clean
make build
sudo make flash
```
