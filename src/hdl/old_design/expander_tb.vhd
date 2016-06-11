-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- expander_tb.vhd is part of DS_bitcoin_miner.

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
use ieee.numeric_std.all;     -- to_integer()

entity expander_tb is
end entity expander_tb;

architecture behav of expander_tb is
   
  signal s_clk      : std_ulogic;
  signal s_rstn     : std_ulogic;
  signal s_exp_sel1 : std_ulogic;
  signal s_M_i_j    : std_ulogic_vector(31 downto 0);
  signal s_W_i_j    : std_ulogic_vector(31 downto 0);
 
  component expander is
    port (
      clk       : in  std_ulogic;                     -- clock
      rstn      : in  std_ulogic;                     -- asynchronous active low reset
      exp_sel1  : in  std_ulogic;                     -- select signal for exp_mux1
      M_i_j     : in  std_ulogic_vector(31 downto 0); -- 32-bit word of the i-th message block
      W_i_j     : out std_ulogic_vector(31 downto 0)  -- 32-bit W_i_j
    );
  end component expander;
   
begin
 
  -- Instantiate the Unit Under Test (UUT)
  UUT : expander
    port map (
      clk      => s_clk,     
      rstn     => s_rstn,    
      exp_sel1 => s_exp_sel1,
      M_i_j    => s_M_i_j,   
      W_i_j    => s_W_i_j   
    );

  -- s_clk signal generation
  s_clk_proc : process
  begin
    s_clk   <= '1',
               '0' after 10 ns; --50MHz
    wait for 20 ns;
  end process;

  -- rstn signal generation
  s_rstn_proc : process
  begin
    s_rstn  <= '0',
               '1' after 25 ns;
    wait;
  end process;

  s_exp_sel1_proc : process
  begin
    s_exp_sel1 <= '0',
                  '1' after 361 ns;
    wait;
  end process;

  s_M_i_j_proc : process
  begin
    s_M_i_j <=  (others => 'Z'),
                x"666f6f62" after 41 ns,
                x"61726161" after 61 ns,
                x"61616161" after 81 ns;
    wait;
  end process;

end architecture behav;
