onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider FUT
add wave -noupdate /virtualtester/FUT/clk
add wave -noupdate /virtualtester/FUT/rst
add wave -noupdate /virtualtester/FUT/NbarT
add wave -noupdate /virtualtester/FUT/Si
add wave -noupdate /virtualtester/FUT/Si_SAYAC_Logic
add wave -noupdate /virtualtester/faultInjection
add wave -noupdate /virtualtester/FUT/PbarS
add wave -noupdate /virtualtester/FI/detected
add wave -noupdate -divider Decomp
add wave -noupdate /virtualtester/END_OF_TV
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/CLK
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/tester_clk
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/RST
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/start
add wave -noupdate /virtualtester/valid
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/data_out
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/Do
add wave -noupdate -radix unsigned /virtualtester/TS_cnt_out
add wave -noupdate /virtualtester/END_OF_TS
add wave -noupdate -divider Synch1
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/Synch_1_INST/rst
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/Synch_1_INST/CMP_TV
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/Synch_1_INST/ready
add wave -noupdate /virtualtester/Golomb_Decompressor_INST/Synch_1_INST/d_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21051533 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {41949600 ps}
