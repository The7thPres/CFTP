vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/sem_v4_1_7

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap sem_v4_1_7 activehdl/sem_v4_1_7

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work sem_v4_1_7  -v2k5 \
"../../../ipstatic/hdl/sem_v4_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../CFTP_Sat.srcs/sources_1/ip/sem_0/sim/sem_0.v" \

vlog -work xil_defaultlib "glbl.v"

