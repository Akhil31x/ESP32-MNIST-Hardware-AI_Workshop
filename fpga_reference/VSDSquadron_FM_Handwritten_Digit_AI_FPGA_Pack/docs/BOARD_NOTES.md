# VSDSquadron FM — Board Notes & Architecture Reference

## 1. Hardware Specifications
- **FPGA Chip**: Lattice iCE40UP5K-SG48 (UltraPlus family)
- **Logic Cells**: 5,280 Logic Elements
- **DSP Blocks**: 8 dedicated $16 \times 16$ multipliers (used for MAC units)
- **Embedded Memory**:
  - 120 Kbit sysMEM Block RAM (30 blocks of 4 Kb each)
  - 1,024 Kbit Single-Port RAM (SPRAM, 4 blocks of 256 Kb each)
- **Clocking**:
  - Internal High-Frequency Oscillator (`SB_HFOSC` @ 48 MHz)
  - External oscillator header on Pin 20 (optional)
- **Programming Interface**: Onboard FTDI FT232H USB-to-SPI bridge (`iceprog`).

---

## 2. Pin Mapping Table (`VSDSquadronFM.pcf`)

| Signal Name | Physical Pin | Direction | Description |
|---|---|---|---|
| `hw_clk` | **20** | Input | Optional external hardware clock input |
| `sw0` | **9** | Input | Inference trigger push button |
| `sw1` | **10** | Input | Active-high reset push button |
| `led0` | **13** | Output | Predicted digit output bit 0 (Active-Low) |
| `led1` | **18** | Output | Predicted digit output bit 1 (Active-Low) |
| `led2` | **19** | Output | Predicted digit output bit 2 (Active-Low) |
| `led3` | **21** | Output | Predicted digit output bit 3 (Active-Low) |
| `led_red` | **39** | Output | High-current RGB LED Red channel |
| `led_blue` | **40** | Output | High-current RGB LED Blue channel |
| `led_green` | **41** | Output | High-current RGB LED Green channel |

---

## 3. RGB LED Status Indication
- **Yellow (Red + Green ON)**: System held in Reset (`sw1 = 1`).
- **Pulsing Blue**: Neural network inference executing in hardware.
- **Solid Green**: Inference complete and predicted digit displayed on `led[0..3]`.
- **Pulsing White**: Idle / standby mode ready for trigger.
