-makelib ies/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "C:/Xilinx/Vivado/2016.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/sem_v4_1_7 \
  "../../../ipstatic/hdl/sem_v4_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../CFTP_Sat.srcs/sources_1/ip/sem_0/sim/sem_0.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

