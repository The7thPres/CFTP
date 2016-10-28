onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+ARM_FIFO_in -L xil_defaultlib -L xpm -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.ARM_FIFO_in xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {ARM_FIFO_in.udo}

run -all

endsim

quit -force
