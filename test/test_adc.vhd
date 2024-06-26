library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.TdmaMinTypes.all;

entity test_adc is
	generic (
		forward : natural
	);
	port (
		clock : in  std_logic;
		send  : out tdma_min_port;
		recv  : in  tdma_min_port
	);
end entity;

architecture sim of test_adc is

	signal channel_0 : signed(15 downto 0);

begin

	send.addr <= std_logic_vector(to_unsigned(forward, tdma_min_addr'length));

	process
		type binary is file of integer;
		file audio    : binary;
		variable word : integer;
		variable data : std_logic_vector(31 downto 0);
	begin
		file_open(audio, "../../../test/tones.wav", read_mode);

		-- Skip wave header
		for i in 1 to 11 loop
			read(audio, word);
		end loop;

		-- Send data
		while not endfile(audio) loop
			read(audio, word);
			data := std_logic_vector(to_signed(word, 32));
			channel_0 <= signed(data(15 downto 0));
			wait for 0 ns; -- Wait one delta cycle so that registers have time to update
			send.data <= x"8000" & data(15 downto 0);
			wait for 20 ns;
			wait for 0 ns;
			send.data <= (others => '0');
			wait for 280 ns;
		end loop;

		file_close(audio);
	end process;

end architecture;