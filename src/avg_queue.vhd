library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real;
use work.TdmaMinTypes.all;

entity avg_queue is
	generic (
		AVG_WINDOW_SIZE : natural
	);
	port (
		clk           : in  std_logic;
		reset         : in  std_logic;

		-- Inputs
		in_data       : in  std_logic_vector(15 downto 0);
		write_enable  : in  std_logic;

		-- Outputs
		average_valid : out std_logic;
		average       : out signed(15 downto 0)
	);
end entity avg_queue;

architecture rtl of avg_queue is
	type avg_queue_t is array (0 to AVG_WINDOW_SIZE - 1) of std_logic_vector(16 downto 0);

	-- Registers
	signal avg_queue   : avg_queue_t := (others => (others => '0'));
	signal queue_total : signed((15 + log2Ceil(AVG_WINDOW_SIZE)) downto 0);
begin

	assert (math_real.floor(math_real.log2(real(AVG_WINDOW_SIZE))) - math_real.log2(real(AVG_WINDOW_SIZE))) = 0.0 report "AVG_WINDOW_SIZE must be a power of 2" severity failure;

	average       <= resize(queue_total srl log2Ceil(AVG_WINDOW_SIZE), average'length);
	average_valid <= '1' when avg_queue(AVG_WINDOW_SIZE - 1)(16) = '1' else
		'0';

	SHIFT_QUEUE : process (clk, reset)
	begin
		if reset = '1' then
			avg_queue <= (others => (others => '0'));
		elsif rising_edge(clk) then
			if write_enable = '1' then
				-- Put in data to the start of the queue. 
				-- The highest bit indicates that the data is valid
				avg_queue(0) <= "1" & in_data;
				for i in 0 to AVG_WINDOW_SIZE - 2 loop
					avg_queue(i + 1) <= avg_queue(i);
				end loop;

				queue_total <= queue_total + resize(signed(in_data(15 downto 0)), queue_total'length) - resize(signed(avg_queue(avg_queue'high)(15 downto 0)), queue_total'length);
			end if;
		end if;
	end process;

end architecture;