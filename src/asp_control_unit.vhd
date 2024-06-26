library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity avg_asp_control_unit is
	port (
		clk                 : in  std_logic;
		reset               : in  std_logic;

		-- Inputs
		pkt_in              : in  std_logic_vector(31 downto 0);
		window_size         : in  std_logic_vector(7 downto 0);
		queue_item_count    : in  std_logic_vector(7 downto 0);
		passthrough         : in  std_logic;
		enable              : in  std_logic;

		-- Outputs
		queue_read_request  : out std_logic;
		queue_write_request : out std_logic;
		total_write_enable  : out std_logic;
		config_write_enable : out std_logic;
		send_output         : out std_logic
	);
end entity avg_asp_control_unit;

architecture rtl of avg_asp_control_unit is
	type avg_asp_state_t is (
		WAITING_FOR_PKT,
		UPDATE_TOTAL
	);

	signal state      : avg_asp_state_t := WAITING_FOR_PKT;
	signal next_state : avg_asp_state_t;
begin

	LOGIC : process (state, pkt_in, window_size, queue_item_count) is
	begin
		-- Control unit is implemented through a Mealy machine
		queue_read_request  <= '0';
		queue_write_request <= '0';
		total_write_enable  <= '0';
		send_output         <= '0';
		config_write_enable <= '0';
		next_state          <= WAITING_FOR_PKT;

		case state is
			when WAITING_FOR_PKT =>

				if unsigned(queue_item_count) > unsigned(window_size) then
					queue_read_request <= '1';
				elsif pkt_in(31 downto 28) = "1000" then
					if unsigned(queue_item_count) < unsigned(window_size) then
						queue_read_request <= '0';
					else
						queue_read_request <= '1';
					end if;
					next_state <= UPDATE_TOTAL;
				elsif pkt_in(31 downto 28) = "1111" then
					config_write_enable <= '1';
				end if;

			when UPDATE_TOTAL =>
				next_state          <= WAITING_FOR_PKT;
				queue_write_request <= '1';
				total_write_enable  <= '1';
				if unsigned(queue_item_count) + 1 = unsigned(window_size) then
					send_output <= '1';
				end if;

		end case;
	end process;

	CHANGE_STATE : process (clk, reset)
	begin
		if reset = '1' then
			state <= WAITING_FOR_PKT;
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;

end architecture;