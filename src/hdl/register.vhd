-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- nbits_register.vhd is part of DS_bitcoin_miner.

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

entity nbits_register is
  generic (
    n : natural := 32                           -- input size (default is 32 bits)
  );
  port (
    clk  : in  std_ulogic;                      -- clock
    rstn : in  std_ulogic;                      -- asynchronous active low reset
    en   : in  std_ulogic;                      -- enable
    d    : in  std_ulogic_vector(n-1 downto 0); -- data in	
    q    : out std_ulogic_vector(n-1 downto 0)  -- data out
  );
end entity nbits_register;

architecture behav of nbits_register is
begin
  process (clk, rstn)            -- asynchronous reset
  begin
    
    if rstn = '0' then
      q <= (others => '0');     -- clear output on reset

    elsif clk'event and clk = '1' then
      if en = '1' then          -- data in is sampled on positive edge of clk if enabled
        q <= d;
      end if;
    end if;
  end process;
end architecture behav;
