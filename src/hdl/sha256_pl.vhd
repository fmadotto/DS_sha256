-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- sha256_pl.vhd is part of DS_bitcoin_miner.

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
use ieee.numeric_std.all; 		-- to_integer()
use work.axi_pkg.all;

entity sha256_pl is
	port (
    clk  : in  std_ulogic; -- clock
    rstn : in  std_ulogic; -- asynchronous active low reset

    done : out std_ulogic; -- done signal
    

    --------------------------------
    -- AXI lite slave port s0_axi --
    --------------------------------
    -- Inputs (master to slave) --
    ------------------------------
    -- Read address channel
    s0_axi_araddr:  in  std_logic_vector(29 downto 0);
    s0_axi_arprot:  in  std_logic_vector(2 downto 0);
    s0_axi_arvalid: in  std_logic;
    -- Read data channel
    s0_axi_rready:  in  std_logic;
    -- Write address channel
    s0_axi_awaddr:  in  std_logic_vector(29 downto 0);
    s0_axi_awprot:  in  std_logic_vector(2 downto 0);
    s0_axi_awvalid: in  std_logic;
    -- Write data channel
    s0_axi_wdata:   in  std_logic_vector(31 downto 0);
    s0_axi_wstrb:   in  std_logic_vector(3 downto 0);
    s0_axi_wvalid:  in  std_logic;
    -- Write response channel
    s0_axi_bready:  in  std_logic;
    -------------------------------
    -- Outputs (slave to master) --
    -------------------------------
    -- Read address channel
    s0_axi_arready: out std_logic;
    -- Read data channel
    s0_axi_rdata:   out std_logic_vector(31 downto 0);
    s0_axi_rresp:   out std_logic_vector(1 downto 0);
    s0_axi_rvalid:  out std_logic;
    -- Write address channel
    s0_axi_awready: out std_logic;
    -- Write data channel
    s0_axi_wready:  out std_logic;
    -- Write response channel
    s0_axi_bresp:   out std_logic_vector(1 downto 0);
    s0_axi_bvalid:  out std_logic
	);
end entity sha256_pl;

architecture rtl of sha256_pl is

  -- Or reduction of std_ulogic_vector
  function or_reduce(v: std_ulogic_vector) return std_ulogic is
    variable tmp: std_ulogic_vector(v'length - 1 downto 0) := v;
  begin
    if tmp'length = 0 then
      return '0';
    elsif tmp'length = 1 then
      return tmp(0);
    else
      return or_reduce(tmp(tmp'length - 1 downto tmp'length / 2)) or
             or_reduce(tmp(tmp'length / 2 - 1 downto 0));
    end if;
  end function or_reduce;

  -- components
  component M_j_memory is
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
  end component M_j_memory;

  component start_FF is
    port (
      clk   : in  std_ulogic; -- clock
      d     : in  std_ulogic; -- data in  
      start : out std_ulogic  -- data out
    );
  end component start_FF;

  component control_unit is
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
  end component control_unit;

  component K_j_constants is
    port (
      clk      : in  std_ulogic; -- clock
      rstn     : in  std_ulogic; -- asynchronous active low reset
      K_j_init : in  std_ulogic; -- start signal for K_j
      K_j      : out std_ulogic_vector(31 downto 0) -- NIST-defined constants Kj
    );
  end component K_j_constants;

  component reg_H_minus_1 is
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
  end component reg_H_minus_1;

  component data_path is
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
  end component data_path;

  -- signals

  -- Record versions of AXI signals
  signal s0_axi_m2s : axilite_gp_m2s;
  signal s0_axi_s2m : axilite_gp_s2m;

  -- STATUS register
  signal status : std_ulogic_vector(31 downto 0);

  -- M_j_memory
  signal M_j_memory_wcs_n_in,
         M_j_memory_we_n_in   : std_ulogic;
  signal M_j_memory_w_addr_in : std_ulogic_vector(3 downto 0);
  signal M_j_memory_data_in   : std_ulogic_vector(31 downto 0);
  signal M_j_memory_data_out  : std_ulogic_vector(31 downto 0);

  
  -- start_FF
  signal start_FF_start_in  : std_ulogic;
  signal start_FF_start_out : std_ulogic;

  -- control_unit
  signal cu_exp_sel1_delayed_out    : std_ulogic; 
  signal cu_com_sel1_delayed_out    : std_ulogic; 
  signal cu_M_j_memory_rcs_n_out    : std_ulogic; 
  signal cu_M_j_memory_r_addr_out   : std_ulogic_vector(3 downto 0);
  signal cu_reg_H_minus_1_en_out    : std_ulogic; 
  signal cu_reg_H_minus_1_sel_out   : std_ulogic; 
  signal cu_K_j_init_out            : std_ulogic;

  -- K_j_constants
  signal K_j_constants_out : std_ulogic_vector(31 downto 0);
  
  -- data_path
  signal dp_H_i_A_out,
         dp_H_i_B_out,
         dp_H_i_C_out,
         dp_H_i_D_out,
         dp_H_i_E_out,
         dp_H_i_F_out,
         dp_H_i_G_out,
         dp_H_i_H_out : std_ulogic_vector(31 downto 0);

  -- reg_H_minus_1
  signal reg_H_iminus1_A_out,
         reg_H_iminus1_B_out,
         reg_H_iminus1_C_out,
         reg_H_iminus1_D_out,
         reg_H_iminus1_E_out,
         reg_H_iminus1_F_out,
         reg_H_iminus1_G_out,
         reg_H_iminus1_H_out : std_ulogic_vector(31 downto 0);

begin

  pl_M_j_memory1 : M_j_memory
    generic map (
      row_size      => 32,
      address_size  => 4
    )
    port map (
      clk      => clk,
      rcs_n    => cu_M_j_memory_rcs_n_out,
      wcs_n    => M_j_memory_wcs_n_in,
      we_n     => M_j_memory_we_n_in,
      r_addr   => cu_M_j_memory_r_addr_out,
      w_addr   => M_j_memory_w_addr_in,
      data_in  => M_j_memory_data_in,
      data_out => M_j_memory_data_out
    );

  pl_start_FF1 : start_FF
    port map (
      clk   => clk,
      d     => start_FF_start_in,
      start => start_FF_start_out
    );

  pl_control_unit1 : control_unit
    port map (
      clk                 => clk,
      rstn                => rstn,
      start               => start_FF_start_out,
      done                => done,
      
      -- data path ports
      exp_sel1_delayed    => cu_exp_sel1_delayed_out,
      com_sel1_delayed    => cu_com_sel1_delayed_out,

      -- M_j_memory ports
      M_j_memory_rcs_n    => cu_M_j_memory_rcs_n_out,
      M_j_memory_r_addr   => cu_M_j_memory_r_addr_out,

      -- reg_H_minus_1 ports
      reg_H_minus_1_en    => cu_reg_H_minus_1_en_out,
      reg_H_minus_1_sel   => cu_reg_H_minus_1_sel_out,
      
      -- K_j_constants ports
      K_j_init            => cu_K_j_init_out
    );

  pl_K_j_constants1 : K_j_constants
    port map (
      clk      => clk,
      rstn     => rstn,
      K_j_init => cu_K_j_init_out,
      K_j      => K_j_constants_out
    );

  pl_reg_H_minus_11 : reg_H_minus_1
    port map (
      clk               => clk,
      rstn              => rstn,
      reg_H_minus_1_en  => cu_reg_H_minus_1_en_out,
      reg_H_minus_1_sel => cu_reg_H_minus_1_sel_out,
      H_i_A             => dp_H_i_A_out,
      H_i_B             => dp_H_i_B_out,
      H_i_C             => dp_H_i_C_out,
      H_i_D             => dp_H_i_D_out,
      H_i_E             => dp_H_i_E_out,
      H_i_F             => dp_H_i_F_out,
      H_i_G             => dp_H_i_G_out,
      H_i_H             => dp_H_i_H_out,
      H_iminus1_A       => reg_H_iminus1_A_out,
      H_iminus1_B       => reg_H_iminus1_B_out,
      H_iminus1_C       => reg_H_iminus1_C_out,
      H_iminus1_D       => reg_H_iminus1_D_out,
      H_iminus1_E       => reg_H_iminus1_E_out,
      H_iminus1_F       => reg_H_iminus1_F_out,
      H_iminus1_G       => reg_H_iminus1_G_out,
      H_iminus1_H       => reg_H_iminus1_H_out
    );

  pl_data_path1 : data_path
    port map (
      -- common ports
      clk          => clk,
      rstn         => rstn,

      -- expander input ports
      exp_sel1     => cu_exp_sel1_delayed_out,
      M_i_j        => M_j_memory_data_out,

      -- compressor input ports
      com_sel1     => cu_com_sel1_delayed_out,
      K_j          => K_j_constants_out,
      H_iminus1_A  => reg_H_iminus1_A_out,
      H_iminus1_B  => reg_H_iminus1_B_out,
      H_iminus1_C  => reg_H_iminus1_C_out,
      H_iminus1_D  => reg_H_iminus1_D_out,
      H_iminus1_E  => reg_H_iminus1_E_out,
      H_iminus1_F  => reg_H_iminus1_F_out,
      H_iminus1_G  => reg_H_iminus1_G_out,
      H_iminus1_H  => reg_H_iminus1_H_out,

      -- output ports
      H_i_A        => dp_H_i_A_out,
      H_i_B        => dp_H_i_B_out,
      H_i_C        => dp_H_i_C_out,
      H_i_D        => dp_H_i_D_out,
      H_i_E        => dp_H_i_E_out,
      H_i_F        => dp_H_i_F_out,
      H_i_G        => dp_H_i_G_out,
      H_i_H        => dp_H_i_H_out
    );

  -- S0_AXI read-write requests
  s0_axi_pr: process(clk, rstn)
    -- idle: waiting for AXI master requests: when receiving write address and data valid (higher priority than read), perform the write, assert write address
    --       ready, write data ready and bvalid, go to w1, else, when receiving address read valid, perform the read, assert read address ready, read data valid
    --       and go to r1
    -- w1:   deassert write address ready and write data ready, wait for write response ready: when receiving it, deassert write response valid, go to idle
    -- r1:   deassert read address ready, wait for read response ready: when receiving it, deassert read data valid, go to idle
    type state_type is (idle, w1, r1);
    variable state: state_type;
  begin
    if rstn = '0' then
      s0_axi_s2m <= (rdata => (others => '0'), rresp => axi_resp_okay, bresp => axi_resp_okay, others => '0');
      M_j_memory_wcs_n_in <= '1';
      M_j_memory_we_n_in <= '1';
      start_FF_start_in <= '0';
      state := idle;
    elsif clk'event and clk = '1' then
      -- s0_axi write and read
      case state is
        when idle =>
          if s0_axi_m2s.awvalid = '1' and s0_axi_m2s.wvalid = '1' then -- Write address and data
            if or_reduce(s0_axi_m2s.awaddr(31 downto 7)) /= '0' then -- If unmapped address
              s0_axi_s2m.bresp <= axi_resp_decerr;
            elsif s0_axi_m2s.awaddr(7 downto 0) = x"00" then -- If read-only status register
              s0_axi_s2m.bresp <= axi_resp_slverr;
            else
              s0_axi_s2m.bresp <= axi_resp_okay;

              if s0_axi_m2s.awaddr(7 downto 0) >= x"04" and s0_axi_m2s.awaddr(7 downto 0) < x"44" then -- If M_j memory

                for i in 0 to 3 loop
                  if s0_axi_m2s.wstrb(i) = '1' then
                    M_j_memory_data_in(8 * i + 7 downto 8 * i) <= s0_axi_m2s.wdata(8 * i + 7 downto 8 * i);
                  end if;
                end loop;

                -- every row in the memory can contain 32 bits, while the input address refers to byte:
                -- it is first divided by 4 (i.e. 2-bit right shift), then 1 is subtracted (the first address is the status register)
                -- then it is converted back to a ulogic_vector
                M_j_memory_w_addr_in <= std_ulogic_vector(to_unsigned((to_integer(unsigned("00" & s0_axi_m2s.awaddr(7 downto 2))) - 1), 4));
                M_j_memory_wcs_n_in <= '0';
                M_j_memory_we_n_in <= '0';

              elsif s0_axi_m2s.awaddr(7 downto 0) = x"44" then -- start command
                start_FF_start_in <= '1';
              end if;

            end if;
            s0_axi_s2m.awready <= '1';
            s0_axi_s2m.wready <= '1';
            s0_axi_s2m.bvalid <= '1';
            state := w1;

          elsif s0_axi_m2s.arvalid = '1' then
            if or_reduce(s0_axi_m2s.araddr(31 downto 0)) /= '0' then -- If not status register
              s0_axi_s2m.rdata <= (others => '0');
              s0_axi_s2m.rresp <= axi_resp_decerr;
            else
              s0_axi_s2m.rresp <= axi_resp_okay;
              s0_axi_s2m.rdata <= status;
            end if;
            s0_axi_s2m.arready <= '1';
            s0_axi_s2m.rvalid <= '1';
            state := r1;
          end if;

        when w1 =>
          s0_axi_s2m.awready <= '0';
          s0_axi_s2m.wready <= '0';
          M_j_memory_wcs_n_in <= '1';
          M_j_memory_we_n_in <= '1';
          start_FF_start_in <= '0';
          if s0_axi_m2s.bready = '1' then
            s0_axi_s2m.bvalid <= '0';
            state := idle;
          end if;

        when r1 =>
          s0_axi_s2m.arready <= '0';
          if s0_axi_m2s.rready = '1' then
            s0_axi_s2m.rvalid <= '0';
            state := idle;
          end if;
      end case;
    end if;
  end process s0_axi_pr;

end architecture rtl;
