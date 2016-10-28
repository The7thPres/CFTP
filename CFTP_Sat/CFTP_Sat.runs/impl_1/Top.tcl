proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set ACTIVE_STEP init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir C:/Users/Chance/CFTP_Sat/CFTP_Sat.cache/wt [current_project]
  set_property parent.project_path C:/Users/Chance/CFTP_Sat/CFTP_Sat.xpr [current_project]
  set_property ip_output_repo C:/Users/Chance/CFTP_Sat/CFTP_Sat.cache/ip [current_project]
  set_property ip_cache_permissions {read write} [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet C:/Users/Chance/CFTP_Sat/CFTP_Sat.runs/synth_1/Top.dcp
  read_xdc -ref SD_Out_FIFO -cells U0 c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/SD_Out_FIFO/SD_Out_FIFO/SD_Out_FIFO.xdc
  set_property processing_order EARLY [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/SD_Out_FIFO/SD_Out_FIFO/SD_Out_FIFO.xdc]
  read_xdc -ref ARM_FIFO_in -cells U0 c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_in/ARM_FIFO_in/ARM_FIFO_in.xdc
  set_property processing_order EARLY [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_in/ARM_FIFO_in/ARM_FIFO_in.xdc]
  read_xdc -ref ARM_FIFO_out -cells U0 c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_out/ARM_FIFO_out/ARM_FIFO_out.xdc
  set_property processing_order EARLY [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_out/ARM_FIFO_out/ARM_FIFO_out.xdc]
  read_xdc -prop_thru_buffers -ref Master_Clock_Divider -cells inst c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/Master_Clock_Divider/Master_Clock_Divider_board.xdc
  set_property processing_order EARLY [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/Master_Clock_Divider/Master_Clock_Divider_board.xdc]
  read_xdc -ref Master_Clock_Divider -cells inst c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/Master_Clock_Divider/Master_Clock_Divider.xdc
  set_property processing_order EARLY [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/Master_Clock_Divider/Master_Clock_Divider.xdc]
  read_xdc C:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/constrs_1/imports/Desktop/Sources-On_Sat/mercury_kx1_top.xdc
  read_xdc C:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/constrs_1/imports/Desktop/Sources/Constraints/timing.xdc
  read_xdc -ref ARM_FIFO_in -cells U0 c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_in/ARM_FIFO_in/ARM_FIFO_in_clocks.xdc
  set_property processing_order LATE [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_in/ARM_FIFO_in/ARM_FIFO_in_clocks.xdc]
  read_xdc -ref ARM_FIFO_out -cells U0 c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_out/ARM_FIFO_out/ARM_FIFO_out_clocks.xdc
  set_property processing_order LATE [get_files c:/Users/Chance/CFTP_Sat/CFTP_Sat.srcs/sources_1/ip/ARM_FIFO_out/ARM_FIFO_out/ARM_FIFO_out_clocks.xdc]
  link_design -top Top -part xc7k325tffg676-2
  write_hwdef -file Top.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
  unset ACTIVE_STEP 
}

start_step opt_design
set ACTIVE_STEP opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force Top_opt.dcp
  report_drc -file Top_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
  unset ACTIVE_STEP 
}

start_step place_design
set ACTIVE_STEP place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force Top_placed.dcp
  report_io -file Top_io_placed.rpt
  report_utilization -file Top_utilization_placed.rpt -pb Top_utilization_placed.pb
  report_control_sets -verbose -file Top_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
  unset ACTIVE_STEP 
}

start_step route_design
set ACTIVE_STEP route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force Top_routed.dcp
  report_drc -file Top_drc_routed.rpt -pb Top_drc_routed.pb -rpx Top_drc_routed.rpx
  report_methodology -file Top_methodology_drc_routed.rpt -rpx Top_methodology_drc_routed.rpx
  report_timing_summary -warn_on_violation -max_paths 10 -file Top_timing_summary_routed.rpt -rpx Top_timing_summary_routed.rpx
  report_power -file Top_power_routed.rpt -pb Top_power_summary_routed.pb -rpx Top_power_routed.rpx
  report_route_status -file Top_route_status.rpt -pb Top_route_status.pb
  report_clock_utilization -file Top_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  write_checkpoint -force Top_routed_error.dcp
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
  unset ACTIVE_STEP 
}

