onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider FUT
add wave -noupdate /virtualtester/FUT/clk
add wave -noupdate /virtualtester/FUT/NbarT
add wave -noupdate /virtualtester/FUT/rst
add wave -noupdate /virtualtester/FUT/PbarS
add wave -noupdate /virtualtester/FUT/Si
add wave -noupdate /virtualtester/FUT/Si_SAYAC_Logic
add wave -noupdate /virtualtester/faultInjection
add wave -noupdate /virtualtester/EN
add wave -noupdate /virtualtester/FI/detected
add wave -noupdate -divider Decompressor
add wave -noupdate /virtualtester/RL_Decompressor_INST/clk
add wave -noupdate /virtualtester/RL_Decompressor_INST/d_in
add wave -noupdate /virtualtester/RL_Decompressor_INST/data_out
add wave -noupdate /virtualtester/RL_Decompressor_INST/diff_out
add wave -noupdate /virtualtester/RL_Decompressor_INST/Do
add wave -noupdate /virtualtester/RL_Decompressor_INST/lcw
add wave -noupdate /virtualtester/RL_Decompressor_INST/load
add wave -noupdate /virtualtester/RL_Decompressor_INST/ready
add wave -noupdate /virtualtester/RL_Decompressor_INST/rst
add wave -noupdate /virtualtester/RL_Decompressor_INST/shift
add wave -noupdate /virtualtester/RL_Decompressor_INST/start
add wave -noupdate /virtualtester/RL_Decompressor_INST/TV_Length
add wave -noupdate /virtualtester/RL_Decompressor_INST/valid
add wave -noupdate /virtualtester/RL_Decompressor_INST/valid_wire
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {439325380 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {2541811125 ps}
