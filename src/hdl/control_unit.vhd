-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- control_unit.vhd is part of DS_bitcoin_miner.

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

entity control_unit is
  port (
    clk                 : in  std_ulogic; -- clock
    rstn                : in  std_ulogic; -- asynchronous active low reset
    start               : in  std_ulogic; -- start signal
    done                : out std_ulogic; -- done signal
    
    -- data path ports
    exp_sel1_delayed    : out std_ulogic; -- select signal for exp_mux1
    com_sel1_delayed    : out std_ulogic; -- select signal for exp_mux1

    -- M_j_memory_dual ports
    M_j_memory_rcs_n    : out std_ulogic; -- read chip select: when asserted low, memory can be read
    M_j_memory_r_addr   : out std_ulogic_vector(3 downto 0);

    -- reg_H_minus_1 ports
    reg_H_minus_1_en    : out std_ulogic; -- enable signal for the H(i-1) registers
    reg_H_minus_1_sel   : out std_ulogic; -- select signal for the H(i-1) registers
    
    -- K_j_constants ports
    K_j_init            : out std_ulogic -- start signal for K_j
  );
end entity control_unit;

architecture rtl of control_unit is
  
  -- components
  component fsm is
    port (
      clk                : in  std_ulogic;                    -- clock
      rstn               : in  std_ulogic;                    -- asynchronous active low reset
      start              : in  std_ulogic;                    -- start signal
      exp_sel1           : out std_ulogic;                    -- select signal for exp_mux1
      com_sel1           : out std_ulogic;                    -- select signal for com_mux1
      M_j_memory_rcs_n   : out std_ulogic;                    -- read chip select: when asserted low, memory can be read
      M_j_memory_r_addr  : out std_ulogic_vector(3 downto 0); -- address
      reg_H_minus_1_en   : out std_ulogic;                    -- enable signal for the H(i-1) registers
      reg_H_minus_1_sel  : out std_ulogic;                    -- select signal for the H(i-1) registers
      K_j_init           : out std_ulogic;                    -- init signal for the K_j constants feeder
      done               : out std_ulogic                     -- done signal
    );
  end component fsm;

  component nbits_register is
    generic (
      n : natural := 32                           -- input size (default is 32 bits)
    );
    port (
      clk  : in  std_ulogic;                      -- clock
      rstn : in  std_ulogic;                      -- asynchronous active low reset
      en   : in  std_ulogic;                      -- enable
      d    : in  std_ulogic_vector(n-1 downto 0); -- data in  
      q    : out std_ulogic_vector(n-1 downto 0)  -- data out
    );
  end component nbits_register;

  -- signals
  signal cu_fsm_exp_sel1_out,            
         cu_fsm_com_sel1_out,
         cu_delay_ff_exp_sel1_out,
         cu_delay_ff_com_sel1_out : std_ulogic_vector(0 downto 0);

begin

    cu_delay_ff_exp_sel1 : nbits_register
    generic map (
      n => 1
    )
    port map (
      clk => clk,
      rstn => rstn,
      en => '1',
      d => cu_fsm_exp_sel1_out,
      q => cu_delay_ff_exp_sel1_out
    );

    exp_sel1_delayed <= cu_delay_ff_exp_sel1_out(0);


    cu_delay_ff_com_sel1 : nbits_register
    generic map (
      n => 1
    )
    port map (
      clk  => clk,
      rstn => rstn,
      en   => '1',
      d    => cu_fsm_com_sel1_out,
      q    => cu_delay_ff_com_sel1_out 
    );

    com_sel1_delayed <= cu_delay_ff_com_sel1_out(0);

    cu_fsm1 : fsm
    port map (
      clk                => clk,
      rstn               => rstn,
      start              => start,
      exp_sel1           => cu_fsm_exp_sel1_out(0),
      com_sel1           => cu_fsm_com_sel1_out(0),
      M_j_memory_rcs_n   => M_j_memory_rcs_n,   
      M_j_memory_r_addr  => M_j_memory_r_addr,
      reg_H_minus_1_en   => reg_H_minus_1_en,
      reg_H_minus_1_sel  => reg_H_minus_1_sel,
      K_j_init           => K_j_init,
      done               => done
    );

end architecture rtl;
