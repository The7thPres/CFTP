vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/xbip_utils_v3_0_7
vlib activehdl/xbip_pipe_v3_0_3
vlib activehdl/xbip_bram18k_v3_0_3
vlib activehdl/mult_gen_v12_0_12

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap xbip_utils_v3_0_7 activehdl/xbip_utils_v3_0_7
vmap xbip_pipe_v3_0_3 activehdl/xbip_pipe_v3_0_3
vmap xbip_bram18k_v3_0_3 activehdl/xbip_bram18k_v3_0_3
vmap mult_gen_v12_0_12 activehdl/mult_gen_v12_0_12

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_7 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_3 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_3 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_12 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../CFTP_Sat.srcs/sources_1/ip/Unsigned_Mult/sim/Unsigned_Mult.vhd" \


vlog -work xil_defaultlib "glbl.v"
