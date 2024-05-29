library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
	signal avg_queue   : avg_queue_t                                       := (others => (others => '0'));
	signal queue_total : signed((15 + log2Ceil(AVG_WINDOW_SIZE)) downto 0) := (others => '0');
begin

	assert (to_unsigned(AVG_WINDOW_SIZE, 32) and (to_unsigned(AVG_WINDOW_SIZE, 32) - 1)) = (31 downto 0 => '0') report "AVG_WINDOW_SIZE must be a power of 2" severity failure;

	-- Custom shift right arithmetic b.c. numeric_std only has it 
	-- in VHDL 2008
	average       <= resize(queue_total / AVG_WINDOW_SIZE, 16);
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

			end if;
		end if;
	end process;

	TOTAL_PROCESS : process (clk, reset)
	begin

		if reset = '1' then
			queue_total <= (others => '0');
		elsif rising_edge(clk) then
			if write_enable = '1' then
				queue_total <= queue_total + signed(in_data(15 downto 0)) - signed(avg_queue(avg_queue'high)(15 downto 0));
			end if;
		end if;

	end process;

end architecture;