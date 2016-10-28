onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Master_Clock_Divider_opt

do {wave.do}

view wave
view structure
view signals

do {Master_Clock_Divider.udo}

run -all

quit -force
