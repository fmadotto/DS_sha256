-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- data_path.vhd is part of DS_bitcoin_miner.

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

entity data_path is
  port (
    -- common ports
    clk          : in  std_ulogic;                     -- clock
    rstn         : in  std_ulogic;                     -- asynchronous active low reset

    -- expander input ports
    exp_sel1     : in  std_ulogic;                     -- select signal for exp_mux1
    M_i_j        : in  std_ulogic_vector(31 downto 0); -- 32-bit word of the i-th message block

    -- compressor input ports
    com_sel1     : in  std_ulogic;                     -- select signal for com_muxA, ..., com_muxH
    K_j          : in  std_ulogic_vector(31 downto 0); -- NIST-defined constants Kj
    H_iminus1_A,
    H_iminus1_B,
    H_iminus1_C,
    H_iminus1_D,
    H_iminus1_E,
    H_iminus1_F,
    H_iminus1_G,
    H_iminus1_H  : in  std_ulogic_vector(31 downto 0); -- intermediate hash value H_(i-1)

    -- output ports
    H_i_A,
    H_i_B,
    H_i_C,
    H_i_D,
    H_i_E,
    H_i_F,
    H_i_G,
    H_i_H        : out std_ulogic_vector(31 downto 0)  -- resulting hash value H_(i)
  );
end entity data_path;

architecture rtl of data_path is

  -- signals
  signal dp_exp_W_i_j_out : std_ulogic_vector(31 downto 0); -- 32-bit W_i_j
  signal dp_com_A_i_out,
         dp_com_B_i_out,
         dp_com_C_i_out,
         dp_com_D_i_out,
         dp_com_E_i_out,
         dp_com_F_i_out,
         dp_com_G_i_out,
         dp_com_H_i_out   : std_ulogic_vector(31 downto 0); -- A-F registers values

begin
  
  dp_expander1 : entity work.expander
    port map (
      clk      => clk,
      rstn     => rstn,
      exp_sel1 => exp_sel1,
      M_i_j    => M_i_j,
      W_i_j    => dp_exp_W_i_j_out
    );

  dp_compressor1 : entity work.compressor
    port map (
      clk         => clk,
      rstn        => rstn,
      com_sel1    => com_sel1,
      W_i_j       => dp_exp_W_i_j_out,
      K_j         => K_j,
      H_iminus1_A => H_iminus1_A,
      H_iminus1_B => H_iminus1_B,
      H_iminus1_C => H_iminus1_C,
      H_iminus1_D => H_iminus1_D,
      H_iminus1_E => H_iminus1_E,
      H_iminus1_F => H_iminus1_F,
      H_iminus1_G => H_iminus1_G,
      H_iminus1_H => H_iminus1_H,
      A_i         => dp_com_A_i_out,
      B_i         => dp_com_B_i_out,
      C_i         => dp_com_C_i_out,
      D_i         => dp_com_D_i_out,
      E_i         => dp_com_E_i_out,
      F_i         => dp_com_F_i_out,
      G_i         => dp_com_G_i_out,
      H_i         => dp_com_H_i_out 
    );

  dp_H_i_calculator1 : entity work.H_i_calculator
    port map (
      H_iminus1_A => H_iminus1_A,
      H_iminus1_B => H_iminus1_B,
      H_iminus1_C => H_iminus1_C,
      H_iminus1_D => H_iminus1_D,
      H_iminus1_E => H_iminus1_E,
      H_iminus1_F => H_iminus1_F,
      H_iminus1_G => H_iminus1_G,
      H_iminus1_H => H_iminus1_H,
      A_i         => dp_com_A_i_out,
      B_i         => dp_com_B_i_out,
      C_i         => dp_com_C_i_out,
      D_i         => dp_com_D_i_out,
      E_i         => dp_com_E_i_out,
      F_i         => dp_com_F_i_out,
      G_i         => dp_com_G_i_out,
      H_i         => dp_com_H_i_out,
      H_i_A       => H_i_A,
      H_i_B       => H_i_B,
      H_i_C       => H_i_C,
      H_i_D       => H_i_D,
      H_i_E       => H_i_E,
      H_i_F       => H_i_F,
      H_i_G       => H_i_G,
      H_i_H       => H_i_H
    );

end architecture rtl;
