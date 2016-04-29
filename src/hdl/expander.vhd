-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- expander.vhd is part of DS_bitcoin_miner.

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
use ieee.std_logic_arith.all;	-- signed/unsigned, conv_integer(), conv_std_logic_vector(signal, no. bit)
use ieee.numeric_std.all; 		-- to_integer()

entity expander is
  port (
    clk       : in  std_ulogic;                     -- clock
    rstn      : in  std_ulogic;                     -- asynchronous active low reset
    exp_sel1  : in  std_ulogic;                     -- select signal for exp_mux1
    M_i_j     : in  std_ulogic_vector(31 downto 0); -- 32-bit word of the i-th message block
    W_i_j     : out std_ulogic_vector(31 downto 0)  -- 32-bit W_i_j
  );
end entity expander;

architecture rtl of expander is
  
  -- components
  component mux_2_to_1 is
    generic (
      n : natural := 32                        -- input size (default is 32 bits)
    );
    port (
      x : in  std_ulogic_vector(n-1 downto 0); -- first binary input
      y : in  std_ulogic_vector(n-1 downto 0); -- second binary input
      s : in  std_ulogic;                      -- select line
      o : out std_ulogic_vector(n-1 downto 0)  -- output
    );
  end component mux_2_to_1;

  component register is
    generic(
      n : natural := 32                           -- input size (default is 32 bits)
    );
    port(
      clk  : in  std_ulogic;                      -- clock
      rstn : in  std_ulogic;                      -- asynchronous active low reset
      en   : in  std_ulogic;                      -- enable
      d    : in  std_ulogic_vector(n-1 downto 0); -- data in  
      q    : out std_ulogic_vector(n-1 downto 0)  -- data out
    );
  end component register;

  component sigma_0 is
    port (
      x : in  std_ulogic_vector(31 downto 0); -- first binary input
      o : out std_ulogic_vector(31 downto 0)  -- output
    );
  end component sigma_0;

  component sigma_1 is
    port (
      x : in  std_ulogic_vector(31 downto 0); -- first binary input
      o : out std_ulogic_vector(31 downto 0)  -- output
    );
  end component sigma_1;

  component csa is
    generic (
      n : natural := 32                             -- input size (default is 32 bits)
    );
    port (
      x     : in  std_ulogic_vector(n-1 downto 0);  -- first binary number to sum
      y     : in  std_ulogic_vector(n-1 downto 0);  -- second binary number to sum
      z     : in  std_ulogic_vector(n-1 downto 0);  -- third binary number to sum
      sum   : out std_ulogic_vector(n-1 downto 0);  -- result of the sum
      cout  : out std_ulogic_vector(n-1 downto 0)   -- carry out
    );
  end component csa;

  component cla is
    generic (
      n : natural := 32                             -- input size (default is 32 bits)
    );
    port (
      x     : in  std_ulogic_vector(n-1 downto 0);  -- first binary number to sum
      y     : in  std_ulogic_vector(n-1 downto 0);  -- second binary number to sum
      sum   : out std_ulogic_vector(n-1 downto 0);  -- result of the sum
      cout  : out std_ulogic                        -- carry out
    );
  end component cla;

  -- signals
  signal exp_mux1_out : std_logic_uvector(31 downto 0); -- multiplexer output
  signal exp_reg1_out,
          exp_reg2_out,
          exp_reg3_out,
          exp_reg4_out,
          exp_reg5_out,
          exp_reg6_out,
          exp_reg7_out,
          exp_reg8_out,
          exp_reg9_out,
          exp_reg10_out,
          exp_reg11_out,
          exp_reg12_out,
          exp_reg13_out,
          exp_reg14_out,
          exp_reg15_out,
          exp_reg16_out : std_logic_uvector(31 downto 0); -- registers outputs
  signal exp_sigma_01_out,
          exp_sigma_11_out : std_logic_uvector(31 downto 0); -- sigma functions outputs
  signal exp_csa1_sum_out,
          exp_csa1_cout_out,
          exp_csa2_sum_out, 
          exp_csa2_cout_out : std_logic_uvector(31 downto 0); -- carry-save adders outputs
  signal exp_cla1_out : std_logic_uvector(31 downto 0); -- carry look-ahead adders outputs

begin

  exp_mux1: mux_2_to_1
    generic map (
      n => 32
    )
    port map (
      x => M_i_j;
      y => exp_cla1_out;
      s => exp_sel1;
      o => exp_mux1_out
    );

  exp_reg1 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_mux1_out exp_mux1_out;
      q => exp_reg1_out 
    );

  exp_reg2 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg1_out exp_reg1_out;
      q => exp_reg2_out 
    );

  exp_reg3 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg2_out ;
      q => exp_reg3_out 
    );

  exp_reg4 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg3_out ;
      q => exp_reg4_out 
    );

  exp_reg5 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg4_out ;
      q => exp_reg5_out 
    );

  exp_reg6 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg5_out ;
      q => exp_reg6_out 
    );

  exp_reg7 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg6_out ;
      q => exp_reg7_out 
    );

  exp_reg8 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg7_out ;
      q => exp_reg8_out 
    );

  exp_reg9 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg8_out ;
      q => exp_reg9_out 
    );

  exp_reg10 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg9_out;
      q => exp_reg10_out 
    );

  exp_reg11 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg10_out;
      q => exp_reg11_out 
    );

  exp_reg12 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg11_out;
      q => exp_reg12_out 
    );

  exp_reg13 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg12_out;
      q => exp_reg13_out 
    );

  exp_reg14 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg13_out;
      q => exp_reg14_out 
    );

  exp_reg15 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg14_out;
      q => exp_reg15_out 
    );

  exp_reg16 : register
    generic map (
      n => 32
    )
    port map (
      clk => clk;
      rstn => rstn;
      en => '1';
      d => exp_reg15_out;
      q => exp_reg16_out 
    );

  exp_sigma_01 : sigma_0
    port map (
      x => exp_reg15_out;
      o => exp_sigma_01_out
    );

  exp_sigma_11 : sigma_1
    port map (
      x => exp_reg2_out;
      o => exp_sigma_11_out
    );

  exp_csa1 : csa
    generic map (
      n => 32
    )
    port map (
      x    => exp_reg1_out;
      y    => exp_sigma_01_out;
      z    => exp_reg7_out;
      sum  => exp_csa1_sum_out;
      cout => exp_csa1_cout_out
    );

  exp_csa2 : csa
    generic map (
      n => 32
    )
    port map (
      x    => exp_csa1_sum_out;
      y    => exp_csa1_cout_out;
      z    => exp_sigma_11_out;
      sum  => exp_csa2_sum_out;
      cout => exp_csa2_cout_out
    );

  exp_cla1 : cla
    generic map (
      n => 32
    )
    port map (
      x    => exp_csa2_sum_out;
      y    => exp_csa2_cout_out;
      sum  => exp_cla1_out;
      cout => open
    );

  W_i_j <= exp_reg1_out;

end architecture rtl;
