library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity avg_asp is
	generic (
		AVG_WINDOW_SIZE : natural
	);
	port (
		clk     : in  std_logic;
		reset   : in  std_logic;

		noc_in  : in  tdma_min_port;
		noc_out : out tdma_min_port
	);
end entity avg_asp;

architecture rtl of avg_asp is
	-- Registers
	signal output_register          : std_logic_vector(31 downto 0);

	-- Control signals
	signal send_output              : std_logic;
	signal output_channel_select    : std_logic;
	signal left_queue_write_enable  : std_logic;
	signal right_queue_write_enable : std_logic;

	-- Intermediary signals
	signal has_data                 : std_logic;
	signal left_queue_full          : std_logic;
	signal left_average             : signed(15 downto 0);
	signal right_queue_full         : std_logic;
	signal right_average            : signed(15 downto 0);

	-- Configure
	signal config_dest              : std_logic_vector(3 downto 0) := "0000";

	-- We need to keep room for the extra bits we obtain when adding
begin

	-- Setup intermediate signals
	has_data <= '1' when noc_in.data(31 downto 28) = "1000" else
		'0';
	noc_out.data <= output_register;
	noc_out.addr <= "0000" & config_dest;

	control_unit : entity work.avg_asp_control_unit
		port map(
			clk                      => clk,
			reset                    => reset,
			has_data                 => has_data,
			data_channel             => noc_in.data(16),
			left_queue_full          => left_queue_full,
			right_queue_full         => right_queue_full,
			left_queue_write_enable  => left_queue_write_enable,
			right_queue_write_enable => right_queue_write_enable,
			output_channel_select    => output_channel_select,
			send_output              => send_output
		);

	-- TODO: Assert AVG_WINDOW_SIZE is a power of 2

	left_channel_queue : entity work.avg_queue
		generic map(
			AVG_WINDOW_SIZE => AVG_WINDOW_SIZE
		)
		port map(
			clk           => clk,
			reset         => reset,
			in_data       => noc_in.data(15 downto 0),
			write_enable  => left_queue_write_enable,
			average_valid => left_queue_full,
			average       => left_average
		);

	right_channel_queue : entity work.avg_queue
		generic map(
			AVG_WINDOW_SIZE => AVG_WINDOW_SIZE
		)
		port map(
			clk           => clk,
			reset         => reset,
			in_data       => noc_in.data(15 downto 0),
			write_enable  => right_queue_write_enable,
			average_valid => right_queue_full,
			average       => right_average
		);

	SEND_PKT : process (clk, reset)
	begin
		if reset = '1' then
			output_register <= (others => '0');
		elsif rising_edge(clk) then
			if send_output = '1' then
				if output_channel_select = '1' then
					output_register <= "1000" & config_dest & "0000000" & '1' & std_logic_vector(right_average);
				else
					output_register <= "1000" & config_dest & "0000000" & '0' & std_logic_vector(left_average);
				end if;
			else
				output_register <= (others => '0');
			end if;
		end if;
	end process;

end architecture;