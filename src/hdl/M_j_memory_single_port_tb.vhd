-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- M_j_memory_tb.vhd is part of DS_bitcoin_miner.

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
 
entity M_j_memory_tb is
end M_j_memory_tb;
 
architecture behav of M_j_memory_tb is
 
  constant rs : natural := 32;
  constant as : natural := 4;
   
  signal s_clk           : std_ulogic;
  signal s_rstn          : std_ulogic;
  signal s_chip_selectn  : std_ulogic;
  signal s_write_enablen : std_ulogic;
  signal s_address       : std_ulogic_vector(as-1 downto 0);
  signal s_data_in       : std_ulogic_vector(rs-1 downto 0);
  signal s_data_out      : std_ulogic_vector(rs-1 downto 0);
 
  component M_j_memory is
    generic (
      row_size      : natural := 32;
      address_size  : natural := 4
    );
    port (
      clk           : in  std_ulogic; -- clock
      rstn          : in  std_ulogic; -- asynchronous active low reset
      chip_selectn  : in  std_ulogic; -- when asserted low, memory read and write operations are possible
      write_enablen : in  std_ulogic; -- when asserted low, memory can be written
      address       : in  std_ulogic_vector(address_size-1 downto 0);
      data_in       : in  std_ulogic_vector(row_size-1 downto 0);
      data_out      : out std_ulogic_vector(row_size-1 downto 0)
    );

  end component M_j_memory;
   
begin
 
  -- Instantiate the Unit Under Test (UUT)
  UUT : M_j_memory
    generic map (
      row_size     => rs, 
      address_size => as
    )
    port map (
      clk           => s_clk,
      rstn          => s_rstn, 
      chip_selectn  => s_chip_selectn,
      write_enablen => s_write_enablen,
      address       => s_address,
      data_in       => s_data_in,
      data_out      => s_data_out
    );

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

  -- s_chip_selectn signal generation
  s_chip_selectn_proc : process
  begin
    s_chip_selectn  <= '1',
                       '0' after 25 ns;
    wait;
  end process;

  -- s_write_enablen signal generation
  s_write_enablen_proc : process
  begin
    s_write_enablen  <= '1',
                        '0' after 25 ns,
                        '1' after 42 ns;
    wait;
  end process;

  -- s_address signal generation
  s_address_proc : process
  begin
    s_address  <= (others => 'Z'),
                  "0000" after 25 ns;
    wait;
  end process;

  -- s_data_in signal generation
  s_data_in_proc : process
  begin
    s_data_in  <= (others => 'Z'),
                  x"6a09e667" after 25 ns,
                  (others => 'Z') after 42 ns;
    wait;
  end process;


  
   
end behav;