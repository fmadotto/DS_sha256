-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- mux_2_to_1.vhd is part of DS_bitcoin_miner.

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

entity mux_2_to_1 is
  generic (
    n : natural := 32                        -- input size (default is 32 bits)
  );
  port (
    x : in  std_ulogic_vector(n-1 downto 0); -- first binary input
    y : in 	std_ulogic_vector(n-1 downto 0); -- second binary input
    s : in 	std_ulogic;                      -- select line
    o : out std_ulogic_vector(n-1 downto 0)  -- output
  );
end entity mux_2_to_1;

architecture behav of mux_2_to_1 is
begin
  process(x, y, s)            -- the process is woken up whenever the inputs or the select signal change
  begin
    case s is
      when '0' =>
        o <= x;               -- 0: x is sent to output
      when '1' =>
        o <= y;               -- 1: y is sent to output
      when others =>
        o <= (others => 'X'); -- should not happen if everything goes smoothly!
    end case;
  end process;
end architecture behav;
