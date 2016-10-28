onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ARM_FIFO_out_opt

do {wave.do}

view wave
view structure
view signals

do {ARM_FIFO_out.udo}

run -all

quit -force
