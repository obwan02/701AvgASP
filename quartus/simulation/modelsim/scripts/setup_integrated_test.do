onerror {resume}
quietly WaveActivateNextPane {} 0

vcom -work work ../../../test/test_adc.vhd
vcom -work work ../../../test/test_dac.vhd
vcom -work work ../../../test/integrated_test.vhd
vsim integrated_test

add wave -noupdate /integrated_test/clock
add wave -noupdate /integrated_test/asp_avg/control_unit/state
add wave -noupdate -expand /integrated_test/asp_avg/noc_in
add wave -noupdate /integrated_test/asp_avg/left_channel_queue/write_enable
add wave -noupdate /integrated_test/asp_avg/right_channel_queue/write_enable
add wave -noupdate -radix hexadecimal -childformat {{/integrated_test/asp_avg/left_channel_queue/avg_queue(0) -radix hexadecimal} {/integrated_test/asp_avg/left_channel_queue/avg_queue(1) -radix hexadecimal} {/integrated_test/asp_avg/left_channel_queue/avg_queue(2) -radix hexadecimal} {/integrated_test/asp_avg/left_channel_queue/avg_queue(3) -radix hexadecimal}} -expand -subitemconfig {/integrated_test/asp_avg/left_channel_queue/avg_queue(0) {-radix hexadecimal} /integrated_test/asp_avg/left_channel_queue/avg_queue(1) {-radix hexadecimal} /integrated_test/asp_avg/left_channel_queue/avg_queue(2) {-radix hexadecimal} /integrated_test/asp_avg/left_channel_queue/avg_queue(3) {-radix hexadecimal}} /integrated_test/asp_avg/left_channel_queue/avg_queue
add wave -noupdate -radix hexadecimal -childformat {{/integrated_test/asp_avg/right_channel_queue/avg_queue(0) -radix hexadecimal} {/integrated_test/asp_avg/right_channel_queue/avg_queue(1) -radix hexadecimal} {/integrated_test/asp_avg/right_channel_queue/avg_queue(2) -radix hexadecimal} {/integrated_test/asp_avg/right_channel_queue/avg_queue(3) -radix hexadecimal}} -expand -subitemconfig {/integrated_test/asp_avg/right_channel_queue/avg_queue(0) {-radix hexadecimal} /integrated_test/asp_avg/right_channel_queue/avg_queue(1) {-radix hexadecimal} /integrated_test/asp_avg/right_channel_queue/avg_queue(2) {-radix hexadecimal} /integrated_test/asp_avg/right_channel_queue/avg_queue(3) {-radix hexadecimal}} /integrated_test/asp_avg/right_channel_queue/avg_queue
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
