onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Unsigned_Mult_opt

do {wave.do}

view wave
view structure
view signals

do {Unsigned_Mult.udo}

run -all

quit -force
