-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- cla_tb.vhd is part of DS_bitcoin_miner.

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
use ieee.std_logic_1164.all;
 
entity cla_tb is
end cla_tb;
 
architecture behav of cla_tb is
 
  constant c_n : natural := 3;
   
  signal r_x    : std_ulogic_vector(c_n-1 downto 0) := (others => '0');
  signal r_y    : std_ulogic_vector(c_n-1 downto 0) := (others => '0');
  signal w_sum  : std_ulogic_vector(c_n-1 downto 0);
  signal w_cout : std_ulogic;
 
  component cla is
    generic (
      n : natural := 3                              -- input size (default is 32 bits)
    );
    port (
      x     : in  std_ulogic_vector(n-1 downto 0);  -- first binary number to sum
      y     : in  std_ulogic_vector(n-1 downto 0);  -- second binary number to sum
      sum   : out std_ulogic_vector(n-1 downto 0);  -- result of the sum
      cout  : out std_ulogic                        -- carry out
    );
  end component cla;
   
begin
 
  -- Instantiate the Unit Under Test (UUT)
  UUT : cla
    generic map (
        n => c_n
      )
    port map (
      x   => r_x,
      y   => r_y,
      sum => w_sum,
      cout => w_cout
    );
 
  -- Test bench is non-synthesizable
  process is
  begin
    r_x <= "000";
    r_y <= "001";
    wait for 10 ns;
    r_x <= "100";
    r_y <= "010";
    wait for 10 ns;
    r_x <= "010";
    r_y <= "110";
    wait for 10 ns;
    r_x <= "111";
    r_y <= "111";
    wait for 10 ns;
  end process;
   
end behav;