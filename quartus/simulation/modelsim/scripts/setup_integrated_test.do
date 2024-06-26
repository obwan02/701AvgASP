onerror {resume}
quietly WaveActivateNextPane {} 0

vcom -work work ../../../test/test_adc.vhd
vcom -work work ../../../test/test_dac.vhd
vcom -work work ../../../test/integrated_test.vhd
vsim integrated_test

add wave -noupdate /integrated_test/clock
add wave -noupdate /integrated_test/asp_avg/control_unit/state
add wave -noupdate -format Analog-Step -height 74 -max 65532.0 -radix unsigned /integrated_test/asp_adc/channel_0
add wave -noupdate -format Analog-Step -height 74 -max 47514.0 -radix unsigned /integrated_test/asp_dac/channel_0
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


