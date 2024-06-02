library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity unit_test_config is
	port (
		noc_out : out tdma_min_port
	);
end entity unit_test_config;

architecture rtl of unit_test_config is
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

	-- CONFIG PACKET STRUCTURE
	-- +------------+------------+------+------+-------+------------+-----------+----------+
	-- | [31 .. 28] | [27 .. 24] | [23] | [22] | [21]  | [15 .. 12] | [11 .. 6] | [5 .. 0] |
	-- |  1 1 1 1   |    next    |  pt  |  en  | flush |   uint_p1  |  uint_p2  | uint_p3  |
	-- +-------------------------+------+------+-------+------------+-----------+----------+

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
		noc_in.data <= "1000" & "0000" & "0000000" & '0' & x"B0FF";

		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= (others => '0');

		wait until rising_edge(clk);
		wait for 0 ns;
		-- passthrough on, enable on, flush off
		noc_in.data <= "1111" & "0011" & "110" & "XXXXX" & x"0000";
		for i in 0 to 10 loop
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '1' & std_logic_vector(to_unsigned(i, 16));

			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= (others => '0');

			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '0' & std_logic_vector(to_unsigned(1234 - i, 16));

			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= (others => '0');
		end loop;

		-- Here, we want to ensure config 
		-- packets don't get passed through
		wait until rising_edge(clk);
		wait for 0 ns;
		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= "1111" & "1000" & "110" & "XXXXX" & x"CAFE";

		-- Send some more packets
		for i in 0 to 10 loop
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '1' & std_logic_vector(to_unsigned(i, 16));
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '0' & std_logic_vector(to_unsigned(1234 - i, 16));
		end loop;

		-- Test the flush packet
		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= "1111" & "1000" & "011" & "XXXXX" & x"CAFE";

		-- Send some more packets
		for i in 0 to 10 loop
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '1' & std_logic_vector(to_unsigned(i, 16));
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '0' & std_logic_vector(to_unsigned(1234 - i, 16));
		end loop;

		-- Test the disable packet
		wait until rising_edge(clk);
		wait for 0 ns;
		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= "1111" & "1100" & "000" & "XXXXX" & x"CAFE";

		-- Send some more packets
		for i in 0 to 10 loop
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '1' & std_logic_vector(to_unsigned(i, 16));
			wait until rising_edge(clk);
			wait for 0 ns;
			noc_in.data <= "1000" & "0000" & "0000000" & '0' & std_logic_vector(to_unsigned(1234 - i, 16));
		end loop;

		wait until rising_edge(clk);
		wait for 0 ns;
		noc_in.data <= (others => '0');
		wait;
	end process;

end architecture;