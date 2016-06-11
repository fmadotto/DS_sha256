-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_sha256

-- M_j_memory.vhd is part of DS_sha256.

-- DS_sha256 is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- DS_sha256 is distributed in the hope that it will be useful,
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
    address_size  : natural := 4
  );
  port (
    clk      : in  std_ulogic; -- clock
    rcs_n    : in  std_ulogic; -- read chip select: when asserted low, memory can be read
    wcs_n    : in  std_ulogic; -- write chip select: when asserted low, memory can be written if also we_n is low
    we_n     : in  std_ulogic; -- write enable: when asserted low, memory can be written
    r_addr   : in  std_ulogic_vector(address_size-1 downto 0);
    w_addr   : in  std_ulogic_vector(address_size-1 downto 0);
    data_in  : in  std_ulogic_vector(row_size-1 downto 0);
    data_out : out std_ulogic_vector(row_size-1 downto 0)
  );

end entity M_j_memory;

architecture behav of M_j_memory is

  type ram_type is array (0 to 2**address_size-1) of std_ulogic_vector(row_size-1 downto 0);
  signal RAM : ram_type;

begin
  process(clk)
  begin
    if clk'event and clk = '1' then
      if wcs_n = '0' then
        if we_n = '0' then
          RAM(to_integer(unsigned(w_addr))) <= data_in;
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if clk'event and clk = '1' then
      if rcs_n = '0' then
        data_out <= RAM(to_integer(unsigned(r_addr)));
      end if;
    end if;
  end process;

end behav;