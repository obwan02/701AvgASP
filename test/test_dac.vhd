library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.TdmaMinTypes.all;

entity test_dac is
	port (
		clock : in  std_logic;
		send  : out tdma_min_port;
		recv  : in  tdma_min_port
	);
end entity;

architecture sim of test_dac is

	signal channel_0 : signed(15 downto 0);
begin

	process (clock)
	begin
		if rising_edge(clock) then
			if recv.data(31 downto 28) = "1000" then
				channel_0 <= signed(recv.data(15 downto 0));
			end if;
		end if;
	end process;

end architecture;