-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- reg_H_minus_1.vhd is part of DS_bitcoin_miner.

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

entity reg_H_minus_1 is
  port (
    clk               : in  std_ulogic; -- clock
    rstn              : in  std_ulogic; -- asynchronous active low reset
    reg_H_minus_1_en  : in  std_ulogic; -- enable signal for the H(i-1) registers
    reg_H_minus_1_sel : in  std_ulogic; -- select signal for the H(i-1) registers
    H_i_A,
    H_i_B,
    H_i_C,
    H_i_D,
    H_i_E,
    H_i_F,
    H_i_G,
    H_i_H             : in  std_ulogic_vector(31 downto 0); -- resulting hash value H_(i) from datapath (to be stored)
    H_iminus1_A,
    H_iminus1_B,
    H_iminus1_C,
    H_iminus1_D,
    H_iminus1_E,
    H_iminus1_F,
    H_iminus1_G,
    H_iminus1_H       : out std_ulogic_vector(31 downto 0) -- intermediate hash value H_(i-1)
  );
end entity reg_H_minus_1;

architecture behav of reg_H_minus_1 is

  type H_array_type is array(0 to 7) of std_ulogic_vector(31 downto 0);

  constant H0 : H_array_type := (
    x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a",
    x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19"
  );

  signal H_iminus1 : H_array_type;

begin

  process (clk, rstn) -- asynchronous reset
  begin
    
    if rstn = '0' then
      H_iminus1 <= (others => x"00000000");

    elsif clk'event and clk = '1' then
      
      if reg_H_minus_1_en = '1' then
        if reg_H_minus_1_sel = '0' then
          H_iminus1(0) <= H0(0);
          H_iminus1(1) <= H0(1);
          H_iminus1(2) <= H0(2);
          H_iminus1(3) <= H0(3);
          H_iminus1(4) <= H0(4);
          H_iminus1(5) <= H0(5);
          H_iminus1(6) <= H0(6);
          H_iminus1(7) <= H0(7);

        elsif reg_H_minus_1_sel = '1' then
          H_iminus1(0) <= H_i_A;
          H_iminus1(1) <= H_i_B;
          H_iminus1(2) <= H_i_C;
          H_iminus1(3) <= H_i_D;
          H_iminus1(4) <= H_i_E;
          H_iminus1(5) <= H_i_F;
          H_iminus1(6) <= H_i_G;
          H_iminus1(7) <= H_i_H;

        end if;
      end if;
    end if;
  end process;

  H_iminus1_A <= H_iminus1(0);
  H_iminus1_B <= H_iminus1(1);
  H_iminus1_C <= H_iminus1(2);
  H_iminus1_D <= H_iminus1(3);
  H_iminus1_E <= H_iminus1(4);
  H_iminus1_F <= H_iminus1(5);
  H_iminus1_G <= H_iminus1(6);
  H_iminus1_H <= H_iminus1(7);


end architecture behav;
