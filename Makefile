SIM_DIR = sim
RTL_SRC = rtl/fifo_mem.sv rtl/sync_r2w.sv rtl/sync_w2r.sv rtl/wptr_full.sv rtl/rptr_empty.sv rtl/async_fifo.sv
TB_SRC  = tb/sva_assertions.sv tb/async_fifo_tb.sv

all: sim_fifo

sim_fifo:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/fifo_sim.vvp $(RTL_SRC) $(TB_SRC)
	vvp $(SIM_DIR)/fifo_sim.vvp

wave_fifo: sim_fifo
	gtkwave $(SIM_DIR)/async_fifo_trace.vcd &

clean:
	rm -rf $(SIM_DIR)
