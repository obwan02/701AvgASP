onerror {resume}
quietly WaveActivateNextPane {} 0

vcom -work work ../../../test/unit_test.vhd
vsim unit_test

add wave -noupdate /unit_test/clk
add wave -noupdate /unit_test/DUT/control_unit/state
add wave -noupdate -radix hexadecimal /unit_test/DUT/noc_in.data
add wave -noupdate -radix hexadecimal /unit_test/DUT/noc_out.data
add wave -noupdate /unit_test/DUT/queue_read_request
add wave -noupdate /unit_test/DUT/queue_write_request
add wave -noupdate /unit_test/DUT/queue_full
add wave -noupdate -radix hexadecimal /unit_test/DUT/queue_total
add wave -noupdate -radix hexadecimal /unit_test/DUT/average
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {60006 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 292
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {131250 ps}


