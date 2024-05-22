library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity test_toplevel is
	port (
		noc_out : out tdma_min_port
	);
end entity test_toplevel;

architecture rtl of test_toplevel is
	signal clk    : std_logic := '0';
	signal reset  : std_logic := '0';
	signal noc_in : tdma_min_port;
begin

	DUT : entity work.avg_asp
		generic map(
			AVG_WINDOW_SIZE => 4
		)
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
		wait for 40 ns;
		noc_in.data <= "1000" & "0000" & "0000000" & '1' & x"ABCD";
		wait for 20 ns;
		noc_in.data <= (others => '0');
		wait for 40 ns;
		noc_in.data <= "1000" & "0000" & "0000000" & '0' & x"B0FF";
		wait for 20 ns;
		noc_in.data <= (others => '0');
	end process;

end architecture;