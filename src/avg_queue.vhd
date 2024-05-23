library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity avg_queue is
	port (
		clk                     : in  std_logic;
		reset                   : in  std_logic;

		-- Inputs
		in_data                 : in  std_logic_vector(15 downto 0);
		write_enable            : in  std_logic;
		current_queue_size_flag : in  std_logic_vector(2 downto 0);
		-- "000" -> 1
		-- "001" -> 2
		-- "010" -> 4
		-- "011" -> 8
		-- "100" -> 16
		-- "101" -> 32
		-- "110" -> 64
		-- "111" -> 128

		-- Outputs
		average_valid           : out std_logic;
		average                 : out signed(15 downto 0)
	);
end entity avg_queue;

architecture rtl of avg_queue is
	type avg_queue_t is array (0 to 127) of std_logic_vector(16 downto 0);

	-- Registers
	signal avg_queue     : avg_queue_t                           := (others => (others => '0'));
	signal queue_total   : signed((15 + log2Ceil(128)) downto 0) := (others => '0');

	-- Top index
	signal largest_index : integer range 0 to 127;
begin

	average       <= signed(to_stdlogicvector(to_bitvector(std_logic_vector(queue_total)) sra to_integer(unsigned(current_queue_size_flag)))(15 downto 0));
	average_valid <= '1' when avg_queue(to_integer(unsigned(to_stdlogicvector(to_bitvector("00000001") sll to_integer(unsigned(current_queue_size_flag))))) - 1)(16) = '1' else
		'0';

	SHIFT_QUEUE : process (clk, reset)
	begin
		if reset = '1' then
			avg_queue   <= (others => (others => '0'));
			queue_total <= (others => '0');
		elsif rising_edge(clk) then
			if write_enable = '1' then
				-- Put in data to the start of the queue. 
				-- The highest bit indicates that the data is valid
				avg_queue(0) <= "1" & in_data;
				for i in 0 to 126 loop
					avg_queue(i + 1) <= avg_queue(i);
				end loop;

				queue_total <= queue_total + signed(in_data(15 downto 0)) - signed(avg_queue(to_integer(unsigned(to_stdlogicvector(to_bitvector("00000001") sll to_integer(unsigned(current_queue_size_flag))))) - 1)(15 downto 0));
			end if;
		end if;
	end process;

end architecture;