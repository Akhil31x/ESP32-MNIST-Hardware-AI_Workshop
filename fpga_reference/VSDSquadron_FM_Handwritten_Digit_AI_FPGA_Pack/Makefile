# ==============================================================================
# Makefile for VSDSquadron FM (Lattice iCE40UP5K-SG48)
# Toolchain: Yosys + nextpnr-ice40 + Project IceStorm (icepack, iceprog)
# ==============================================================================

PROJ = mnist_digit_ai
DEVICE = up5k
PACKAGE = sg48
PCF = VSDSquadronFM.pcf

SRCS = rtl/top.v \
       rtl/rgb_status.v \
       rtl/mnist_accelerator_top.v \
       rtl/mnist_core.v \
       rtl/nn_mac.v \
       rtl/relu.v \
       rtl/argmax10.v \
       rtl/activation_mem.v \
       rtl/weight_rom_l1.v \
       rtl/weight_rom_l2.v \
       rtl/weight_rom_l3.v \
       rtl/bias_rom_l1.v \
       rtl/bias_rom_l2.v \
       rtl/bias_rom_l3.v \
       rtl/sample_rom.v

all: $(PROJ).bin

$(PROJ).json: $(SRCS)
	yosys -p "synth_ice40 -top top -json $@" $(SRCS)

$(PROJ).asc: $(PROJ).json $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

build: $(PROJ).bin
	@echo "Build complete: $(PROJ).bin"

flash: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin

.PHONY: all build flash clean
