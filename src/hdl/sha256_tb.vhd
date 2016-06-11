-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- sha256_tb.vhd is part of DS_bitcoin_miner.

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

entity sha256_tb is
end entity sha256_tb;

architecture behav of sha256_tb is

  signal s_clk      : std_ulogic;
  signal s_rstn     : std_ulogic;

  -- M_j_memory
  signal M_j_memory_wcs_n_in,
         M_j_memory_we_n_in   : std_ulogic;
  signal M_j_memory_w_addr_in : std_ulogic_vector(3 downto 0);
  signal M_j_memory_data_in   : std_ulogic_vector(31 downto 0);
  signal M_j_memory_data_out  : std_ulogic_vector(31 downto 0);

  
  -- start_FF
  signal start_FF_start_in  : std_ulogic;
  signal start_FF_start_out : std_ulogic;
 
  -- sha256
  signal M_j_memory_rcs_n_out : std_ulogic;
  signal M_j_memory_r_addr_out : std_ulogic_vector(3 downto 0);
  signal done_out : std_ulogic;
  signal H_i_A_out,
         H_i_B_out,
         H_i_C_out,
         H_i_D_out,
         H_i_E_out,
         H_i_F_out,
         H_i_G_out,
         H_i_H_out : std_ulogic_vector(31 downto 0);

begin

  -- s_clk signal generation
  s_clk_proc : process
  begin
    s_clk   <= '1',
               '0' after 10 ns; --50MHz
    wait for 20 ns;
  end process;

  -- rstn signal generation
  s_rstn_proc : process
  begin
    s_rstn  <= '0',
               '1' after 25 ns;
    wait;
  end process;

  memory_proc : process
  begin
    M_j_memory_wcs_n_in <=  '1',
                            '0' after 26 ns,
                            '1' after 362 ns;
    
    M_j_memory_we_n_in  <=  '1',
                            '0' after 26 ns,
                            '1' after 362 ns;
    
    M_j_memory_w_addr_in <= (others => 'Z'),
                            x"0" after 41 ns,
                            x"1" after 61 ns,
                            x"2" after 81 ns,
                            x"3" after 101 ns,
                            x"4" after 121 ns,
                            x"5" after 141 ns,
                            x"6" after 161 ns,
                            x"7" after 181 ns,
                            x"8" after 201 ns,
                            x"9" after 221 ns,
                            x"a" after 241 ns,
                            x"b" after 261 ns,
                            x"c" after 281 ns,
                            x"d" after 301 ns,
                            x"e" after 321 ns,
                            x"f" after 341 ns;
    
    M_j_memory_data_in  <=  (others => 'Z'),
                            x"666f6f62" after 41 ns,
                            x"61726161" after 61 ns,
                            x"61616161" after 81 ns;
    wait;
  end process;

  -- start_FF signal generation
  start_FF_proc : process
  begin
    start_FF_start_in  <= '0',
                          '1' after 361 ns,
                          '0' after 381 ns,
                          '1' after 1781 ns,
                          '0' after 1801 ns;
    wait;
  end process;

  pl_M_j_memory1 : entity work.M_j_memory
    generic map (
      row_size      => 32,
      address_size  => 4
    )
    port map (
      clk      => s_clk,
      rcs_n    => M_j_memory_rcs_n_out,
      wcs_n    => M_j_memory_wcs_n_in,
      we_n     => M_j_memory_we_n_in,
      r_addr   => M_j_memory_r_addr_out,
      w_addr   => M_j_memory_w_addr_in,
      data_in  => M_j_memory_data_in,
      data_out => M_j_memory_data_out
    );

  pl_start_FF1 : entity work.start_FF
    port map (
      clk   => s_clk,
      d     => start_FF_start_in,
      start => start_FF_start_out
    );

  pl_sha256 : entity work.sha256
    port map (
      clk   => s_clk,
      rstn  => s_rstn,
      start => start_FF_start_out,
      M_i_j => M_j_memory_data_out,
      M_j_memory_rcs_n => M_j_memory_rcs_n_out,
      M_j_memory_r_addr => M_j_memory_r_addr_out,
      H_i_A => H_i_A_out,
      H_i_B => H_i_B_out,
      H_i_C => H_i_C_out,
      H_i_D => H_i_D_out,
      H_i_E => H_i_E_out,
      H_i_F => H_i_F_out,
      H_i_G => H_i_G_out,
      H_i_H => H_i_H_out,
      done  => done_out
    );



end architecture behav;
