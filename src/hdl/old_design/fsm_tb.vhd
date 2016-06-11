-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- fsm_tb.vhd is part of DS_bitcoin_miner.

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
use ieee.std_logic_1164.all;  -- std_logic
use ieee.std_logic_arith.all; -- signed/unsigned, conv_integer(), conv_std_logic_vector(signal, no. bit)
use ieee.numeric_std.all;     -- to_integer()

entity fsm_tb is
end entity fsm_tb;

architecture behav of fsm_tb is
   
  signal s_clk               : std_ulogic;                   
  signal s_rstn              : std_ulogic;                   
  signal s_start             : std_ulogic;                   
  signal s_exp_sel1          : std_ulogic;                   
  signal s_com_sel1          : std_ulogic;                   
  signal s_M_j_memory_rcs_n  : std_ulogic;                   
  signal s_M_j_memory_r_addr : std_ulogic_vector(3 downto 0);
  signal s_reg_H_minus_1_en  : std_ulogic;                   
  signal s_reg_H_minus_1_sel : std_ulogic;                   
  signal s_K_j_init          : std_ulogic;                   
  signal s_done              : std_ulogic;    

begin

  -- Instantiate the Unit Under Test (UUT)
  UUT : entity work.fsm
  port map (
    clk                => s_clk,              
    rstn               => s_rstn,             
    start              => s_start,            
    exp_sel1           => s_exp_sel1,         
    com_sel1           => s_com_sel1,         
    M_j_memory_rcs_n   => s_M_j_memory_rcs_n, 
    M_j_memory_r_addr  => s_M_j_memory_r_addr,
    reg_H_minus_1_en   => s_reg_H_minus_1_en, 
    reg_H_minus_1_sel  => s_reg_H_minus_1_sel,
    K_j_init           => s_K_j_init,         
    done               => s_done      
  );

  -- s_clk signal generation
  s_clk_proc : process
  begin
    s_clk   <= '1',
               '0' after 10 ns; --50MHz
    wait for 20 ns;
  end process;

  -- s_rstn signal generation
  s_rstn_proc : process
  begin
    s_rstn  <= '0',
               '1' after 25 ns;
    wait;
  end process;

  -- s_start signal generation
  s_start_proc : process
  begin
    s_start  <= '0',
                '1' after 42 ns,
                '0' after 62 ns;
    wait;
  end process;


end architecture behav;
