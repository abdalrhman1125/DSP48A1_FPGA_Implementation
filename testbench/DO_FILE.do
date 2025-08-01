vlib work
vlog pipeline_mux.v DSP.v DSP_tb.v 
vsim -voptargs=+acc work.DSP_tb
add wave *
run -all
#quit -sim
