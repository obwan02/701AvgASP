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
	signal output_register     : std_logic_vector(31 downto 0);

	-- Control signals
	signal send_output         : std_logic;
	signal queue_write_request : std_logic;
	signal queue_read_request  : std_logic;
	signal config_write_enable : std_logic;
	signal total_write_enable  : std_logic;

	-- Intermediary signals
	signal average             : std_logic_vector(15 downto 0);
	signal division_out        : std_logic_vector(23 downto 0);
	signal queue_total         : unsigned(23 downto 0) := (others => '0');
	signal queue_item_count    : std_logic_vector(7 downto 0);
	signal queue_out           : std_logic_vector(15 downto 0);
	signal noc_value_reg       : std_logic_vector(15 downto 0);

	-- Configure
	signal config_dest         : std_logic_vector(3 downto 0) := "0010";
	signal config_window_size  : unsigned(7 downto 0)         := to_unsigned(16, 8);
	signal config_enable       : std_logic                    := '1';
	signal config_passthrough  : std_logic                    := '0';
	signal config_flush        : std_logic                    := '0';
	signal flush               : std_logic                    := '0';
begin

	-- Setup intermediate signals
	noc_out.addr <= "0000" & config_dest;
	flush        <= config_flush or reset;

	control_unit : entity work.avg_asp_control_unit
		port map(
			clk                 => clk,
			reset               => flush,
			pkt_in              => noc_in.data,
			queue_item_count    => queue_item_count,
			window_size         => std_logic_vector(config_window_size),
			passthrough         => config_passthrough,
			enable              => config_enable,
			queue_read_request  => queue_read_request,
			queue_write_request => queue_write_request,
			total_write_enable  => total_write_enable,
			config_write_enable => config_write_enable,
			send_output         => send_output
		);

	ip_queue_inst : entity work.ip_queue
		port map(
			aclr  => flush,
			clock => clk,
			data  => noc_value_reg,
			rdreq => queue_read_request,
			wrreq => queue_write_request,
			usedw => queue_item_count,
			q     => queue_out
		);

	average <= division_out(15 downto 0);
	ip_div_inst : entity work.ip_div
		port map(
			denom    => std_logic_vector(config_window_size),
			numer    => std_logic_vector(queue_total),
			quotient => division_out,
			remain   => open
		);

	QUEUE_TOTAL_WRITE : process (clk, flush)
	begin
		if flush = '1' then
			queue_total <= (others => '0');
		elsif rising_edge(clk) then
			if total_write_enable = '1' then
				queue_total <= queue_total + unsigned(noc_value_reg) - unsigned(queue_out);
			end if;
		end if;
	end process;

	NOC_REG_WRITE : process (clk, reset)
	begin
		if reset = '1' then
			noc_value_reg <= (others => '0');
		elsif rising_edge(clk) then
			if noc_in.data(31 downto 28) = "1000" then
				noc_value_reg <= noc_in.data(15 downto 0);
			end if;
		end if;
	end process;

	-- CONFIG PACKET STRUCTURE
	-- +------------+------------+------+------+-------+-------------+--------------+
	-- | [31 .. 28] | [27 .. 24] | [23] | [22] | [21]  | [15 .. 8]   |   [7 .. 0]   |
	-- |  1 1 1 1   |    next    |  pt  |  en  | flush |   RESERVED  |  window_size |
	-- +-------------------------+------+------+-------+-------------+--------------+

	CONFIG_WRITE : process (clk, reset)
	begin
		if reset = '1' then
			config_dest        <= "0000";
			config_enable      <= '1';
			config_passthrough <= '0';
			config_flush       <= '0';
		elsif rising_edge(clk) then
			if config_flush = '1' then
				config_flush <= '0';
			end if;

			if config_write_enable = '1' then
				config_dest <= noc_in.data(27 downto 24);
				if unsigned(noc_in.data(7 downto 0)) /= 0 then
					config_window_size <= unsigned(noc_in.data(7 downto 0));
				end if;
				config_enable      <= noc_in.data(22);
				config_passthrough <= noc_in.data(23);
				config_flush       <= noc_in.data(21);
			end if;
		end if;
	end process;

	SEND_PKT : process (average, config_passthrough, config_enable, config_dest, noc_in, send_output)
		variable out_value : std_logic_vector(15 downto 0);
	begin

		if config_enable /= '1' then
			noc_out.data <= (others => '0');
		elsif config_passthrough = '1' then
			noc_out.data <= noc_in.data;
		elsif send_output = '1' then
			noc_out.data <= "1000" & config_dest & x"00" & std_logic_vector(average);
		else
			noc_out.data <= (others => '0');
		end if;

	end process;

end architecture;