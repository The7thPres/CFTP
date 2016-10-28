onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib Signed_Mult_opt

do {wave.do}

view wave
view structure
view signals

do {Signed_Mult.udo}

run -all

quit -force
