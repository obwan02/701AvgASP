onerror {resume}
quietly WaveActivateNextPane {} 0

vcom -work work ../../../test/unit_test.vhd
vsim unit_test

add wave -noupdate /unit_test/clk
add wave -noupdate /unit_test/DUT/control_unit/state
add wave -noupdate -expand /unit_test/DUT/noc_in
add wave -noupdate /unit_test/DUT/left_channel_queue/write_enable
add wave -noupdate /unit_test/DUT/right_channel_queue/write_enable
add wave -noupdate -radix hexadecimal -childformat {{/unit_test/DUT/left_channel_queue/avg_queue(0) -radix hexadecimal} {/unit_test/DUT/left_channel_queue/avg_queue(1) -radix hexadecimal} {/unit_test/DUT/left_channel_queue/avg_queue(2) -radix hexadecimal} {/unit_test/DUT/left_channel_queue/avg_queue(3) -radix hexadecimal}} -expand -subitemconfig {/unit_test/DUT/left_channel_queue/avg_queue(0) {-radix hexadecimal} /unit_test/DUT/left_channel_queue/avg_queue(1) {-radix hexadecimal} /unit_test/DUT/left_channel_queue/avg_queue(2) {-radix hexadecimal} /unit_test/DUT/left_channel_queue/avg_queue(3) {-radix hexadecimal}} /unit_test/DUT/left_channel_queue/avg_queue
add wave -noupdate -radix hexadecimal -childformat {{/unit_test/DUT/right_channel_queue/avg_queue(0) -radix hexadecimal} {/unit_test/DUT/right_channel_queue/avg_queue(1) -radix hexadecimal} {/unit_test/DUT/right_channel_queue/avg_queue(2) -radix hexadecimal} {/unit_test/DUT/right_channel_queue/avg_queue(3) -radix hexadecimal}} -expand -subitemconfig {/unit_test/DUT/right_channel_queue/avg_queue(0) {-radix hexadecimal} /unit_test/DUT/right_channel_queue/avg_queue(1) {-radix hexadecimal} /unit_test/DUT/right_channel_queue/avg_queue(2) {-radix hexadecimal} /unit_test/DUT/right_channel_queue/avg_queue(3) {-radix hexadecimal}} /unit_test/DUT/right_channel_queue/avg_queue
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
