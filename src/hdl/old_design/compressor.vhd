-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- compressor.vhd is part of DS_bitcoin_miner.

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

entity compressor is
  port (
    clk          : in  std_ulogic;                     -- clock
    rstn         : in  std_ulogic;                     -- asynchronous active low reset
    com_sel1     : in  std_ulogic;                     -- select signal for com_muxA, ..., com_muxH
    W_i_j        : in  std_ulogic_vector(31 downto 0); -- 32-bit W_i_j
    K_j          : in  std_ulogic_vector(31 downto 0); -- NIST-defined constants Kj
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
    H_i          : out std_ulogic_vector(31 downto 0) -- A-F registers values
  );
end entity compressor;

architecture rtl of compressor is

  -- signals
  signal com_muxA_out,
         com_muxB_out,
         com_muxC_out,
         com_muxD_out,
         com_muxE_out,
         com_muxF_out,
         com_muxG_out,
         com_muxH_out      : std_ulogic_vector(31 downto 0); -- multiplexers outputs
  signal com_regA_out,
         com_regB_out,
         com_regC_out,
         com_regD_out,
         com_regE_out,
         com_regF_out,
         com_regG_out,
         com_regH_out      : std_ulogic_vector(31 downto 0); -- nbits_registers outputs
  signal com_csigma_01_out,
         com_csigma_11_out : std_ulogic_vector(31 downto 0); -- capital sigma functions outputs
  signal com_ch1_out       : std_ulogic_vector(31 downto 0); -- Ch function output
  signal com_maj1_out      : std_ulogic_vector(31 downto 0); -- Maj function output
  signal com_csa1_sum_out,
         com_csa1_cout_out,
         com_csa2_sum_out,
         com_csa2_cout_out,
         com_csa3_sum_out,
         com_csa3_cout_out,
         com_csa4_sum_out,
         com_csa4_cout_out,
         com_csa5_sum_out,
         com_csa5_cout_out,
         com_csa6_sum_out,
         com_csa6_cout_out : std_ulogic_vector(31 downto 0); -- carry-save adders outputs
  signal com_cla1_out,
         com_cla2_out      : std_ulogic_vector(31 downto 0); -- carry look-ahead adders outputs

begin

  com_csa1 : entity work.csa
    generic map (
      n => 32
    )
    port map (
      x    => W_i_j,
      y    => com_regH_out,
      z    => K_j,
      sum  => com_csa1_sum_out,
      cout => com_csa1_cout_out
    );

  com_csa2 : entity work.csa
    generic map (
      n => 32
    )
    port map (
      x    => com_csa1_sum_out,
      y    => com_csa1_cout_out,
      z    => com_ch1_out,
      sum  => com_csa2_sum_out,
      cout => com_csa2_cout_out
    );

  com_csa3 : entity work.csa
    generic map (
      n => 32
    )
    port map (
      x    => com_csa2_sum_out,
      y    => com_csa2_cout_out,
      z    => com_csigma_11_out,
      sum  => com_csa3_sum_out,
      cout => com_csa3_cout_out
    );

  com_csa4 : entity work.csa
    generic map (
      n => 32
    )
    port map (
      x    => com_csa3_sum_out,
      y    => com_csa3_cout_out,
      z    => com_maj1_out,
      sum  => com_csa4_sum_out,
      cout => com_csa4_cout_out
    );

  com_csa5 : entity work.csa
    generic map (
      n => 32
    )
    port map (
      x    => com_csa4_sum_out,
      y    => com_csa4_cout_out,
      z    => com_csigma_01_out,
      sum  => com_csa5_sum_out,
      cout => com_csa5_cout_out
    );

  com_csa6 : entity work.csa
    generic map (
      n => 32
    )
    port map (
      x    => com_csa3_sum_out,
      y    => com_csa3_cout_out,
      z    => com_regD_out,
      sum  => com_csa6_sum_out,
      cout => com_csa6_cout_out
    );

  com_cla1 : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => com_csa5_sum_out,
      y    => com_csa5_cout_out,
      sum  => com_cla1_out,
      cout => open
    );

  com_cla2 : entity work.cla
    generic map (
      n => 32
    )
    port map (
      x    => com_csa6_sum_out,
      y    => com_csa6_cout_out,
      sum  => com_cla2_out,
      cout => open
    );

  com_maj1 : entity work.maj
    port map (
      x => com_regA_out,
      y => com_regB_out,
      z => com_regC_out,
      o => com_maj1_out
    );

  com_ch1 : entity work.ch
    port map (
      x => com_regE_out,
      y => com_regF_out,
      z => com_regG_out,
      o => com_ch1_out
    );

  com_csigma_01 : entity work.csigma_0
    port map (
      x => com_regA_out,
      o => com_csigma_01_out
    );

  com_csigma_11 : entity work.csigma_1
    port map (
      x => com_regE_out,
      o => com_csigma_11_out
    );

  com_muxA : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_cla1_out,
      y => H_iminus1_A,
      s => com_sel1,
      o => com_muxA_out
    );

  com_muxB : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_regA_out,
      y => H_iminus1_B,
      s => com_sel1,
      o => com_muxB_out
    );

  com_muxC : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_regB_out,
      y => H_iminus1_C,
      s => com_sel1,
      o => com_muxC_out
    );

  com_muxD : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_regC_out,
      y => H_iminus1_D,
      s => com_sel1,
      o => com_muxD_out
    );

  com_muxE : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_cla2_out,
      y => H_iminus1_E,
      s => com_sel1,
      o => com_muxE_out
    );

  com_muxF : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_regE_out,
      y => H_iminus1_F,
      s => com_sel1,
      o => com_muxF_out
    );

  com_muxG : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_regF_out,
      y => H_iminus1_G,
      s => com_sel1,
      o => com_muxG_out
    );

  com_muxH : entity work.mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => com_regG_out,
      y => H_iminus1_H,
      s => com_sel1,
      o => com_muxH_out
    );

  com_regA : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxA_out,
      q => com_regA_out
    );

  com_regB : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxB_out,
      q => com_regB_out
    );

  com_regC : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxC_out,
      q => com_regC_out
    );

  com_regD : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxD_out,
      q => com_regD_out
    );

  com_regE : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxE_out,
      q => com_regE_out
    );

  com_regF : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxF_out,
      q => com_regF_out
    );

  com_regG : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxG_out,
      q => com_regG_out
    );

  com_regH : entity work.nbits_register
    generic map (
      n => 32
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => com_muxH_out,
      q => com_regH_out
    );

  A_i <= com_regA_out;
  B_i <= com_regB_out;
  C_i <= com_regC_out;
  D_i <= com_regD_out;
  E_i <= com_regE_out;
  F_i <= com_regF_out;
  G_i <= com_regG_out;
  H_i <= com_regH_out;

end architecture rtl;
