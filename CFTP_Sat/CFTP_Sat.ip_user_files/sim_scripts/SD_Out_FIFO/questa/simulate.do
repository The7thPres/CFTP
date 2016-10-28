onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib SD_Out_FIFO_opt

do {wave.do}

view wave
view structure
view signals

do {SD_Out_FIFO.udo}

run -all

quit -force
