PROJ = hwterm_top
PCF = icestick.pcf
DEVICE = 1k

all: ${PROJ}.bin

%.bin: %.asc
	icepack $< $@

%.asc: %.json
	nextpnr-ice40 --hx1k --package tq144 --json $< --pcf $(PCF) --asc $@

%.json: verilog/buffer.v verilog/hwterm_top.v verilog/termbuffer.v verilog/uart_rx.v verilog/uart_tx.v
	yosys -p "read_verilog -Iverilog $^; synth_ice40 -flatten -json $@"

.PHONY: prog clean old

prog:
	iceprog ${PROJ}.bin

clean:
	rm -rf *.bin *.vvp *.vcd *.out *.json

vl:
	verilator 

old:
	iverilog -I verilog -o uart_rx_tb.out verilog/uart_rx_tb.v
	iverilog -I verilog -o uart_tx_tb.out verilog/uart_tx_tb.v
	vvp uart_rx_tb.out
	vvp uart_tx_tb.out
	#gtkwave uart_rx.vcd
	#gtkwave uart_tx.vcd
