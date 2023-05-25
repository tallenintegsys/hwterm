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

.PHONY: prog clean sim

prog:
	iceprog ${PROJ}.bin

clean:
	rm -rf *.bin *.vvp *.vcd *.out *.json

vl:
	verilator 

sim:
	iverilog -Iverilog -o termbuffer_tb.vvp test/termbuffer_tb.v verilog/termbuffer.v verilog/buffer.v
	vvp termbuffer_tb.vvp
