library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity avg_asp is
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
	signal config_write_enable      : std_logic := '0';
	signal send_output              : std_logic;
	signal output_channel_select    : std_logic;
	signal left_queue_write_enable  : std_logic;
	signal right_queue_write_enable : std_logic;

	-- Intermediary signals
	signal left_queue_full          : std_logic;
	signal left_average             : signed(15 downto 0);
	signal right_queue_full         : std_logic;
	signal right_average            : signed(15 downto 0);

	-- Configure
	signal config_dest              : std_logic_vector(3 downto 0) := "0000";
	signal config_enable            : std_logic                    := '1';
	signal config_passthrough       : std_logic                    := '0';
	signal config_flush             : std_logic                    := '0';
	signal config_queue_size_flag   : std_logic_vector(2 downto 0) := "001";
	-- "000" -> 1
	-- "001" -> 2
	-- "010" -> 4
	-- "011" -> 8
	-- "100" -> 16
	-- "101" -> 32
	-- "110" -> 64
	-- "111" -> 128

	-- Internal reset that we can use to reset from NOC
	signal internal_reset           : std_logic;
begin

	-- Setup intermediate signals
	noc_out.data   <= output_register;
	noc_out.addr   <= "0000" & config_dest;
	internal_reset <= config_flush or reset;

	control_unit : entity work.avg_asp_control_unit
		port map(
			clk                      => clk,
			reset                    => reset,
			pkt_in                   => noc_in.data,
			left_queue_full          => left_queue_full,
			right_queue_full         => right_queue_full,
			left_queue_write_enable  => left_queue_write_enable,
			right_queue_write_enable => right_queue_write_enable,
			output_channel_select    => output_channel_select,
			config_write_enable      => config_write_enable,
			send_output              => send_output
		);

	left_channel_queue : entity work.avg_queue
		port map(
			clk                     => clk,
			reset                   => internal_reset,
			in_data                 => noc_in.data(15 downto 0),
			write_enable            => left_queue_write_enable,
			current_queue_size_flag => config_queue_size_flag,
			average_valid           => left_queue_full,
			average                 => left_average
		);

	right_channel_queue : entity work.avg_queue
		port map(
			clk                     => clk,
			reset                   => internal_reset,
			in_data                 => noc_in.data(15 downto 0),
			write_enable            => right_queue_write_enable,
			current_queue_size_flag => config_queue_size_flag,
			average_valid           => right_queue_full,
			average                 => right_average
		);

	-- CONFIG PACKET STRUCTURE
	-- +------------+------------+------+------+-------+------------+-----------+----------+
	-- | [31 .. 28] | [27 .. 24] | [23] | [22] | [21]  | [15 .. 12] | [11 .. 6] | [5 .. 0] |
	-- |  1 1 1 1   |    next    |  pt  |  en  | flush |   uint_p1  |  uint_p2  | uint_p3  |
	-- +-------------------------+------+------+-------+------------+-----------+----------+
	--
	-- uint_p3 -> averaging window size

	CONFIG_RECV_PKT : process (clk, reset)
	begin
		if reset = '1' then
			config_dest            <= "0000";
			config_passthrough     <= '0';
			config_enable          <= '1';
			config_flush           <= '0';
			config_queue_size_flag <= "001";
		elsif rising_edge(clk) then
			if config_flush = '1' then
				config_flush <= '0';
			end if;

			if config_write_enable = '1' then
				config_dest            <= noc_in.data(27 downto 24);
				config_passthrough     <= noc_in.data(23);
				config_enable          <= noc_in.data(22);
				config_flush           <= noc_in.data(21);
				config_queue_size_flag <= noc_in.data(2 downto 0);
			end if;
		end if;
	end process;

	SEND_PKT : process (clk, reset)
	begin
		if reset = '1' then
			output_register <= (others => '0');
		elsif rising_edge(clk) then
			if config_passthrough = '1' then
				output_register <= "1000" & config_dest & "0000000" & noc_in.data(16 downto 0);
			elsif send_output = '1' and config_enable = '1' then
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