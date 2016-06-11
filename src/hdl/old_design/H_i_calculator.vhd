-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- H_i_calculator.vhd is part of DS_bitcoin_miner.

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
use ieee.std_logic_1164.all; 	-- std_logic

entity H_i_calculator is
  port (
    H_iminus1_A,
    H_iminus1_B,
    H_iminus1_C,
    H_iminus1_D,
    H_iminus1_E,
    H_iminus1_F,
    H_iminus1_G,
    H_iminus1_H  : in  std_ulogic_vector(31 downto 0); -- intermediate hash value H_(i-1)
    A_i,
    B_i,
    C_i,
    D_i,
    E_i,
    F_i,
    G_i,
    H_i          : in  std_ulogic_vector(31 downto 0); -- A-F registers values
    H_i_A,
    H_i_B,
    H_i_C,
    H_i_D,
    H_i_E,
    H_i_F,
    H_i_G,
    H_i_H        : out std_ulogic_vector(31 downto 0)  -- resulting hash value H_(i)
  );
end entity H_i_calculator;

architecture rtl of H_i_calculator is

begin

  Hcalc_claA : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => A_i,
      y    => H_iminus1_A,
      sum  => H_i_A,
      cout => open
    );

  Hcalc_claB : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => B_i,
      y    => H_iminus1_B,
      sum  => H_i_B,
      cout => open
    );

  Hcalc_claC : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => C_i,
      y    => H_iminus1_C,
      sum  => H_i_C,
      cout => open
    );

  Hcalc_claD : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => D_i,
      y    => H_iminus1_D,
      sum  => H_i_D,
      cout => open
    );

  Hcalc_claE : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => E_i,
      y    => H_iminus1_E,
      sum  => H_i_E,
      cout => open
    );

  Hcalc_claF : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => F_i,
      y    => H_iminus1_F,
      sum  => H_i_F,
      cout => open
    );

  Hcalc_claG : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => G_i,
      y    => H_iminus1_G,
      sum  => H_i_G,
      cout => open
    );

  Hcalc_claH : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => H_i,
      y    => H_iminus1_H,
      sum  => H_i_H,
      cout => open
    );

end architecture rtl;