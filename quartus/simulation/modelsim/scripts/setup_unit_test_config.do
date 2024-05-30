onerror {resume}
quietly WaveActivateNextPane {} 0

vcom -work work ../../../test/unit_test_config.vhd
vsim unit_test_config

add wave -noupdate /unit_test_config/clk
add wave -noupdate /unit_test_config/DUT/control_unit/state
add wave -noupdate -radix hexadecimal /unit_test_config/DUT/noc_in.data
add wave -noupdate -radix hexadecimal /unit_test_config/DUT/noc_out.data
add wave -noupdate /unit_test_config/DUT/queue_read_request
add wave -noupdate /unit_test_config/DUT/queue_write_request
add wave -noupdate /unit_test_config/DUT/queue_full
add wave -noupdate -radix hexadecimal /unit_test_config/DUT/queue_total
add wave -noupdate -radix hexadecimal /unit_test_config/DUT/average
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

