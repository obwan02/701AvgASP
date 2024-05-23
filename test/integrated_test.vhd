library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.TdmaMinTypes.all;

entity test_with_adc is
	generic (
		ports : positive := 2
	);
end entity;

architecture sim of test_with_adc is

	signal clock   : std_logic := '1';
	signal adc_out : tdma_min_port;
	signal avg_out : tdma_min_port;
	signal empty   : tdma_min_port;

begin

	empty.addr <= (others => '0');
	empty.data <= (others => '0');

	clock      <= not clock after 10 ns;

	asp_adc : entity work.test_adc
		generic map(
			forward => 1
		)
		port map(
			clock => clock,
			send  => adc_out,
			recv  => empty
		);

	asp_avg : entity work.avg_asp
		port map(
			clk     => clock,
			reset   => '0',
			noc_in  => adc_out,
			noc_out => avg_out
		);

	test_dac_inst : entity work.test_dac
		port map(
			clock => clock,
			recv  => avg_out,
			send  => open
		);

end architecture;