library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity toplevel is
	port (
		clock_50 : in  std_logic;
		reset    : in  std_logic;

		noc_in   : in  tdma_min_port;
		noc_out  : out tdma_min_port
	);
end entity toplevel;

architecture rtl of toplevel is
begin

	avg_asp_inst : entity work.avg_asp
		generic map(
			AVG_WINDOW_SIZE => 4
		)
		port map(
			clk     => clock_50,
			reset   => reset,
			noc_in  => noc_in,
			noc_out => noc_out
		);

end architecture;