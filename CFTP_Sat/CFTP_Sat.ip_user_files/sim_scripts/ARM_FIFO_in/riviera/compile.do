vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/fifo_generator_v13_1_2

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap fifo_generator_v13_1_2 riviera/fifo_generator_v13_1_2

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_1_2  -v2k5 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_2 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_2  -v2k5 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_in/sim/ARM_FIFO_in.v" \

vlog -work xil_defaultlib "glbl.v"

