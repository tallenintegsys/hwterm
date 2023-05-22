PROJ = hwterm
PCF = icestick.pcf
DEVICE = 1k

all: ${PROJ}.bin

sim: termbuffer_tb.vcd uart_tx_tb.vcd uart_rx_tb.vcd

%.vvp: verilog/%.v
	iverilog -I verilog $< -o $@

%.vcd: %.vvp
	vvp $<

%.bin: %.asc
	icepack $< $@

%.asc: %.json
	nextpnr-ice40 --hx1k --package tq144 --json $< --pcf $(PCF) --asc $@

%.json: verilog/*
	yosys -p "read_verilog -Iverilog verilog/glitchGen_top.v; synth_ice40 -flatten -json $@"

.PHONY: prog clean old

prog:
	iceprog ${PROJ}.bin

clean:
	rm -rf *.bin *.vvp *.vcd *.out

old:
	iverilog -I verilog -o uart_rx_tb.out verilog/uart_rx_tb.v
	iverilog -I verilog -o uart_tx_tb.out verilog/uart_tx_tb.v
	vvp uart_rx_tb.out
	vvp uart_tx_tb.out
	#gtkwave uart_rx.vcd
	#gtkwave uart_tx.vcd
