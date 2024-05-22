library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;

entity avg_asp_control_unit is
	port (
		clk                      : in  std_logic;
		reset                    : in  std_logic;

		-- Inputs
		pkt_in                   : in  std_logic_vector(31 downto 0);
		left_queue_full          : in  std_logic;
		right_queue_full         : in  std_logic;

		-- Outputs
		left_queue_write_enable  : out std_logic;
		right_queue_write_enable : out std_logic;
		output_channel_select    : out std_logic;
		send_output              : out std_logic
	);
end entity avg_asp_control_unit;

architecture rtl of avg_asp_control_unit is
	type avg_asp_state_t is (
		WAITING_FOR_PKT,
		SHIFTING_LEFT_QUEUE,
		SHIFTING_RIGHT_QUEUE
	);

	signal state      : avg_asp_state_t := WAITING_FOR_PKT;
	signal next_state : avg_asp_state_t;
begin

	-- Control unit is implemented through a Mealy machine

	LOGIC : process (state, pkt_in, left_queue_full, right_queue_full) is
	begin
		left_queue_write_enable  <= '0';
		right_queue_write_enable <= '0';
		output_channel_select    <= '0';
		send_output              <= '0';

		case state is
			when WAITING_FOR_PKT =>
				next_state <= WAITING_FOR_PKT;

				if pkt_in(31 downto 28) = "1000" then
					if pkt_in(16) = '1' then
						next_state              <= SHIFTING_RIGHT_QUEUE;
						left_queue_write_enable <= '1';
					else
						next_state               <= SHIFTING_LEFT_QUEUE;
						right_queue_write_enable <= '1';
					end if;
				end if;

			when SHIFTING_LEFT_QUEUE =>
				next_state <= WAITING_FOR_PKT;
				if left_queue_full = '1' then
					output_channel_select <= '0';
					send_output           <= '1';
				end if;

				if pkt_in(31 downto 28) = "1000" then
					if pkt_in(16) = '1' then
						next_state              <= SHIFTING_RIGHT_QUEUE;
						left_queue_write_enable <= '1';
					else
						next_state               <= SHIFTING_LEFT_QUEUE;
						right_queue_write_enable <= '1';
					end if;
				end if;

			when SHIFTING_RIGHT_QUEUE =>
				next_state <= WAITING_FOR_PKT;
				if right_queue_full = '1' then
					output_channel_select <= '1';
					send_output           <= '1';
				end if;

				if pkt_in(31 downto 28) = "1000" then
					if pkt_in(16) = '1' then
						next_state              <= SHIFTING_RIGHT_QUEUE;
						left_queue_write_enable <= '1';
					else
						next_state               <= SHIFTING_LEFT_QUEUE;
						right_queue_write_enable <= '1';
					end if;
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