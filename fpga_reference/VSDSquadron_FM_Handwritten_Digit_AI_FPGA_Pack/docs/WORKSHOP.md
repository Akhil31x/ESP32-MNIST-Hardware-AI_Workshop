# VSDSquadron FM — Handwritten Digit AI Workshop Guide

## Workshop Overview
In this hands-on workshop, you will synthesize and deploy an end-to-end deep learning accelerator for handwritten digit recognition on the **VSDSquadron FM** Lattice iCE40UP5K FPGA using an entirely open-source toolchain (Yosys + NextPNR + IceStorm).

---

## 1. Toolchain Prerequisites

Install the open-source FPGA suite on Linux, macOS, or Windows (via WSL / MSYS2 / OSS CAD Suite):
```bash
# On Ubuntu / Debian
sudo apt-get install yosys nextpnr-ice40 fpga-icestorm
```

Or download the pre-packaged [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build).

---

## 2. Compiling the Bitstream

Navigate to the project root directory:
```bash
# 1. Clean previous build artifacts
make clean

# 2. Synthesize with Yosys, Place & Route with NextPNR, and Pack bitstream
make build
```

This generates `mnist_digit_ai.bin`.

---

## 3. Programming the Hardware

Plug the VSDSquadron FM board into your host computer via USB:
```bash
# Flash the FPGA SPI Flash memory
sudo make flash
```

---

## 4. Hardware Verification & Testing

1. Once programmed, the onboard RGB LED will pulse **White** (Idle mode).
2. Press push button **SW0** (`sw0`, Pin 9):
   - The RGB LED changes to **Blinking Blue** indicating that the 25,818-parameter forward pass is executing.
   - Upon completion, the RGB LED turns **Solid Green**.
   - The 4 discrete LEDs (`led0`..`led3`) light up showing the 4-bit binary representation of the recognized digit!
3. Each subsequent press of **SW0** cycles through the next test sample (digits 0 through 9) from the onboard sample ROM.
