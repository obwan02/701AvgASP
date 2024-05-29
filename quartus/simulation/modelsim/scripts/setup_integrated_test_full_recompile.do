onerror {resume}
quietly WaveActivateNextPane {} 0

do ./701AvgASP_run_msim_rtl_vhdl.do
do ./scripts/setup_integrated_test.do
