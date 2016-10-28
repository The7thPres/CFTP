vlib work
vlib msim

vlib msim/xil_defaultlib
vlib msim/xpm
vlib msim/sem_v4_1_7

vmap xil_defaultlib msim/xil_defaultlib
vmap xpm msim/xpm
vmap sem_v4_1_7 msim/sem_v4_1_7

vlog -work xil_defaultlib -64 -sv \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work sem_v4_1_7 -64 \
"../../../ipstatic/hdl/sem_v4_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 \
"../../../../CFTP_Sat.srcs/sources_1/ip/sem_0/sim/sem_0.v" \

vlog -work xil_defaultlib "glbl.v"

