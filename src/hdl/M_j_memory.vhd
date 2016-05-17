-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- M_j_memory.vhd is part of DS_bitcoin_miner.

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
use ieee.numeric_std.all; -- to_integer()

entity M_j_memory is
  generic (
    row_size      : natural := 32;
    address_size  :	natural := 4
  );
  port (
    clk           : in  std_ulogic; -- clock
    rstn          : in  std_ulogic; -- asynchronous active low reset
    cs_n          : in  std_ulogic; -- chip select: when asserted low, memory read and write operations are possible
    we_n          : in  std_ulogic; -- write enable: when asserted low, memory can be written
    address       : in  std_ulogic_vector(address_size-1 downto 0);
    data_in       : in  std_ulogic_vector(row_size-1 downto 0);
    data_out      : out std_ulogic_vector(row_size-1 downto 0)
  );

end entity M_j_memory;

architecture behav of M_j_memory is

  type M_j_memory_type is array (0 to 2**address_size-1) of std_ulogic_vector(row_size-1 downto 0);
  signal mem : M_j_memory_type;

begin

  process (clk, rstn) -- asynchronous reset
  begin
    
    if rstn = '0' then
      data_out <= (others => '0');

    elsif clk'event and clk = '1' then
      if cs_n = '0' then

        -- writing
        if we_n = '0' then
          mem(to_integer(unsigned(address))) <= data_in;

        -- reading
        else
          data_out <= mem(to_integer(unsigned(address)));
        end if;

      end if;
    end if;
  end process;
end architecture behav;