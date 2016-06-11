-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- csigma_0.vhd is part of DS_bitcoin_miner.

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

entity csigma_0 is
  port (
    x : in  std_ulogic_vector(31 downto 0); -- first binary input
    o : out std_ulogic_vector(31 downto 0)  -- output
  );
end entity csigma_0;

architecture behav of csigma_0 is
begin
  process (x)            -- the process is woken up whenever the input change
  begin
      o <= to_stdulogicvector((to_bitvector(x) ror 2) xor (to_bitvector(x) ror 13) xor (to_bitvector(x) ror 22));
  end process;
end architecture behav;