-makelib ies/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../CFTP_Sat.srcs/sources_1/ip/Master_Clock_Divider/Master_Clock_Divider_clk_wiz.v" \
  "../../../../CFTP_Sat.srcs/sources_1/ip/Master_Clock_Divider/Master_Clock_Divider.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

