onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+Unsigned_Mult -L xil_defaultlib -L xpm -L xbip_utils_v3_0_7 -L xbip_pipe_v3_0_3 -L xbip_bram18k_v3_0_3 -L mult_gen_v12_0_12 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.Unsigned_Mult xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {Unsigned_Mult.udo}

run -all

endsim

quit -force
