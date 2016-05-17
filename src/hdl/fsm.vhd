-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- fsm.vhd is part of DS_bitcoin_miner.

-- DS_bitcoin_miner is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- DS_bitcoin_miner is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;   -- std_logic
use ieee.std_logic_arith.all;  -- signed/unsigned, conv_integer(), conv_std_logic_vector(signal, no. bit)
use ieee.numeric_std.all;      -- to_integer()



entity fsm is
  port (
    clk                : in  std_ulogic;                    -- clock
    rstn               : in  std_ulogic;                    -- asynchronous active low reset
    start              : in  std_ulogic;                    -- start signal
    exp_sel1           : out std_ulogic;                    -- select signal for exp_mux1
    com_sel1           : out std_ulogic;                    -- select signal for com_mux1
    M_j_memory_cs_n    : out std_ulogic;                    -- chip select: when asserted low, memory read and write operations are possible
    M_j_memory_we_n    : out std_ulogic;                    -- write enable: when asserted low, memory can be written
    M_j_memory_address : out std_ulogic_vector(3 downto 0); -- address
    reg_H_minus_1_en   : out std_ulogic;                    -- enable signal for the H(i-1) registers
    reg_H_minus_1_sel  : out std_ulogic;                    -- select signal for the H(i-1) registers
    K_j_init           : out std_ulogic;                    -- init signal for the K_j constants feeder
    done               : out std_ulogic                     -- done signal
  );
end entity fsm;

architecture behav of fsm is

  type fsm_state_t is (idle, active);
  
  type fsm_state_r is
  record
    fsm_state: fsm_state_t;         -- FSM state
    counter: natural range 0 to 67; -- counter
  end record;

  signal present_state, next_state: fsm_state_r;

begin
  
  state_reg : process (clk, rstn)
  begin
    if rstn = '0' then
      present_state.fsm_state <= idle;
      present_state.counter <= 0;

    elsif clk'event and clk = '1' then
      present_state.fsm_state <= next_state.fsm_state;
      present_state.counter <= next_state.counter;
    end if;
  end process;

  next_state_logic : process (present_state, start)
  begin

    case present_state.fsm_state is

      when idle =>
        
        next_state.counter <= 0;

        if start = '1' then -- if the start signal is asserted we start the sequence
          next_state.fsm_state <= active;
        else
          next_state.fsm_state <= idle;
        end if;

      when active =>
        next_state <= present_state;

        if present_state.counter = 67 then -- if we reached the end of the sequence we come back at idle
          next_state.fsm_state <= idle;
          next_state.counter <= 0;

        else
          next_state.counter <= present_state.counter + 1; -- otherwise we increment the counter
        end if;

      when others => -- if there is an unexpected condition we come back at the idle state
        next_state.fsm_state <= idle;
    end case;
  end process;


  output_logic : process (present_state)
  begin

    case present_state.fsm_state is

      when idle =>
        exp_sel1           <= '0';
        com_sel1           <= '1';
        M_j_memory_cs_n    <= '1';
        M_j_memory_we_n    <= '1';
        M_j_memory_address <= (others => 'Z');
        reg_H_minus_1_en   <= '0';
        reg_H_minus_1_sel  <= '0';
        K_j_init           <= '0';
        done <= '0';
        
      when active =>
        if present_state.counter >= 0 and present_state.counter <= 15 then
          
          M_j_memory_address <= std_ulogic_vector(to_unsigned(present_state.counter, 4));

          if present_state.counter = 0 then
            M_j_memory_cs_n    <= '0';
            reg_H_minus_1_en   <= '1';

          elsif present_state.counter = 1 then
            com_sel1           <= '0';
            reg_H_minus_1_en   <= '0';
            K_j_init           <= '1';

          elsif present_state.counter = 2 then
            K_j_init           <= '0';
          end if;

        elsif present_state.counter = 16 then
          M_j_memory_cs_n    <= '1';
          M_j_memory_address <= (others => 'Z');
          exp_sel1           <= '1';

        elsif present_state.counter = 66 then
          reg_H_minus_1_en   <= '1';
          reg_H_minus_1_sel  <= '1';

        elsif present_state.counter = 67 then
          reg_H_minus_1_en   <= '0';
          reg_H_minus_1_sel  <= '0';
          done <= '1';

        end if;

    end case;

  end process;


end architecture behav;