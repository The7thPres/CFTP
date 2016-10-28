#Fast to Slow Clock
set_multicycle_path -setup -start -from [get_clocks -filter {NAME =~ *clk_out2_Master_Clock_Divider}] -to [get_clocks -filter {NAME =~ *clk_out1_Master_Clock_Divider}] 2
set_multicycle_path -hold -start -from [get_clocks -filter {NAME =~ *clk_out2_Master_Clock_Divider}] -to [get_clocks -filter {NAME =~ *clk_out1_Master_Clock_Divider}] 1

#Slow to Fast Clock
set_multicycle_path -setup -end -from [get_clocks -filter {NAME =~ *clk_out1_Master_Clock_Divider}] -to [get_clocks -filter {NAME =~ *clk_out2_Master_Clock_Divider}] 2
set_multicycle_path -hold -end -from [get_clocks -filter {NAME =~ *clk_out1_Master_Clock_Divider}] -to [get_clocks -filter {NAME =~ *clk_out2_Master_Clock_Divider}] 1
