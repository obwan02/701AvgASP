# 701 Averaging ASP

## Building for an FGPA

To put the ASP on a FPGA, all that you be
required is:

1. Open `quartus/701AvgAsp.qpf` in Quartus Prime (18.1 std)
2. Compile the design
3. Program the FPGA

## Folder Structure

- `src` contains VHDL source files
- `test` contains VHDL test benches
- `quartus` contains quartus files

## Simulating in ModelSim

First, the processor needs to be compiled in Quartus. Then
ModelSim needs to be opened from Quartus. To do that, you
need to tell Quartus where ModelSim lives. This can be set
under the `Tools > Options > General > EDA Tools Options`
menu. In that menu, the `ModelSim-Altera` folder needs to be
changed.

Then, to open up ModelSim for simulation, hit the 
`Tools > Run Simulation Tool > RTL Simulation` button.

### Test Benches

Currently, there is a single unit test bench that tests components in isolation:
- `test/test_adc.vhd`

The other test benches test
- `test/integrated_test.vhd` tests the averaging ASP inside a fake TDMA-Min network
    - `test/test_adc.vhd` contains a fake ADC for this test
    - `test/test_dac.vhd` contains a fake DAC for this test

### Running Test Benches

To run one of the above test benches, you must have ModelSim opened from Quartus
(see above instructions). Then the `Compile > Compile` button needs to be clicked. This
will open up a file explorer in which you can navigate to where the test benches live. In this
file explorer you just need to double click any test bench you want to compile and then close the
explorer.

Note that for the integrated test bench, you first need to compile the `tests/test_adc.vhd` and then
the `tests/test_dac.vhd` file before compiling `test/integrated_test.vhd`.

Then, you need to navigate to the library window, and find the test bench component that you want to
run under the `work` library. Right click on it and click simulate. You can then add any waves you
want to the wave viewer.

To start the simulation you can type `run X ns` into the ModelSim command prompt, replacing `X` with
the number of nano seconds you want to simulate the testbench for. You can restart a simulation by typing 
`restart` into the ModelSim command prompt. 

#### Re-compiling

To recompile and re-testbench your code, you need to close ModelSim, recompile in Quartus, and repeat the instructions
above to get ModelSim open, and the testbench compiled.