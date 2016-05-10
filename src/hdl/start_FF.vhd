-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- start_FF.vhd is part of DS_bitcoin_miner.

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

entity start_FF is
  port (
    clk   : in  std_ulogic; -- clock
    d     : in  std_ulogic; -- data in  
    start : out std_ulogic  -- data out
  );
end entity start_FF;

architecture behav of start_FF is

begin

  process (clk)
  begin
    
    if clk'event and clk = '1' then
      start <= '0'; -- this makes the output lasts for only one clock cycle

      if d = '1' then
        start <= d;
      end if;

    end if;

  end process;

end architecture behav;
