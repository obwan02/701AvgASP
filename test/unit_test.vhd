library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity unit_test is
	port (
		noc_out : out tdma_min_port
	);
end entity unit_test;

architecture rtl of unit_test is
	signal clk    : std_logic := '0';
	signal reset  : std_logic := '0';
	signal noc_in : tdma_min_port;
begin

	DUT : entity work.avg_asp
		port map(
			clk     => clk,
			reset   => reset,
			noc_in  => noc_in,
			noc_out => noc_out
		);

	CLOCK_GEN : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;

	noc_in.addr <= (others => '0');

	TESTING_SIGNALS : process
	begin
		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= "1000" & "0000" & "0000000" & '1' & x"ABCD";
		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= (others => '0');
		wait until rising_edge(clk);
		wait for 0 ns;
		wait until rising_edge(clk);
		wait for 0 ns;
		wait until rising_edge(clk);
		wait for 0 ns;
	end process;

end architecture;