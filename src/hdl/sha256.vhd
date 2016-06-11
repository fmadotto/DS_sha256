-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- sha256.vhd is part of DS_bitcoin_miner.

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
use ieee.numeric_std.all;     -- to_integer()

entity sha256 is
  port (
    clk          : in  std_ulogic;                     -- clock
    rstn         : in  std_ulogic;                     -- asynchronous active low reset
    start        : in  std_ulogic;
    M_i_j        : in  std_ulogic_vector(31 downto 0); -- 32-bit word of the i-th message block

    M_j_memory_rcs_n    : out std_ulogic; -- read chip select: when asserted low, memory can be read
    M_j_memory_r_addr   : out std_ulogic_vector(3 downto 0);

    H_i_A,
    H_i_B,
    H_i_C,
    H_i_D,
    H_i_E,
    H_i_F,
    H_i_G,
    H_i_H        : out std_ulogic_vector(31 downto 0);  -- resulting hash value H_(i)
   
    done         : out std_ulogic
  );
end entity sha256;


architecture behav of sha256 is
  
  -- datapath functions
  function sigma0(
    x: std_ulogic_vector
  )
  return std_ulogic_vector is
  begin
    return to_stdulogicvector((to_bitvector(x) ror 7) xor (to_bitvector(x) ror 18) xor (to_bitvector(x) srl 3));
  end function sigma0;

  function sigma1(
    x: std_ulogic_vector
  )
  return std_ulogic_vector is
  begin
    return to_stdulogicvector((to_bitvector(x) ror 17) xor (to_bitvector(x) ror 19) xor (to_bitvector(x) srl 10));
  end function sigma1;

  function csigma0(
    x: std_ulogic_vector
  )
  return std_ulogic_vector is
  begin
    return to_stdulogicvector((to_bitvector(x) ror 2) xor (to_bitvector(x) ror 13) xor (to_bitvector(x) ror 22));
  end function csigma0;

  function csigma1(
    x: std_ulogic_vector
  )
  return std_ulogic_vector is
  begin
    return to_stdulogicvector((to_bitvector(x) ror 6) xor (to_bitvector(x) ror 11) xor (to_bitvector(x) ror 25));
  end function csigma1;

  function Maj(
    x: std_ulogic_vector;
    y: std_ulogic_vector;
    z: std_ulogic_vector
  )
  return std_ulogic_vector is
  begin
    return (x and y) xor (x and z) xor (y and z);
  end function Maj;

  function Ch(
    x: std_ulogic_vector;
    y: std_ulogic_vector;
    z: std_ulogic_vector
  )
  return std_ulogic_vector is
  begin
    return (x and y) xor ((not (x)) and z);
  end function Ch;

  function moduloAddition(
    x: std_ulogic_vector;
    y: std_ulogic_vector
  )
  return std_ulogic_vector is
    variable tmp: std_ulogic_vector(x'length-1 downto 0) := std_ulogic_vector(unsigned(x) + unsigned(y));
  begin
    return tmp(31 downto 0);
  end function moduloAddition;

  
  -- NIST-defined Kj constant
  type K_W_array_type is array(0 to 63) of std_ulogic_vector(31 downto 0);
  constant K : K_W_array_type := (
    x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
    x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
    x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
    x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
    x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
    x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
    x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
    x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
  );

  -- initial hash value
  type H_array_type is array(0 to 7) of std_ulogic_vector(31 downto 0);

  constant H0 : H_array_type := (
    x"6a09e667", x"bb67ae85", x"3c6ef372", x"a54ff53a",
    x"510e527f", x"9b05688c", x"1f83d9ab", x"5be0cd19"
  );

  signal W : K_W_array_type;

  signal counter : natural range 0 to 67;
  signal j_expander, j_compressor, j_T : integer range -4 to 66;
  
  signal T1, T2, A, B, C, D, E, F, G, H : std_ulogic_vector(31 downto 0);

begin

  -- counter (control unit) process
  process (clk, rstn)
  begin
    if rstn = '0' then
      counter <= 0;
      done <= '0';

    elsif clk'event and clk = '1' then
      done <= '0';
      
      if ((start = '1' and counter = 0) or (counter > 0 and counter < 67)) then
        counter <= counter + 1;
      elsif (counter = 67) then
        counter <= 0;
        done <= '1';
      end if;

    end if;

  end process;

  -- expander process
  process (clk, rstn)
    variable j: integer range -2 to 65 := -2;
  begin

    j := counter - 2;
    j_expander <= j;

    if rstn = '0' then
      W <= ((others => (others => '0')));
      j := -2;

    elsif clk'event and clk = '1' then

      if (j >= 0 and j <= 15) then
        W(j) <= M_i_j;

      elsif (j > 15 and j < 64) then
        W(j) <= moduloAddition(sigma1(W(j - 2)),
                  moduloAddition(W(j - 7),
                    moduloAddition(sigma0(W(j - 15)),  W(j - 16)
                    )
                  )
                );
      end if; 

    end if;

  end process;


  -- compressor process
  process (clk, rstn)
    variable j: integer range -3 to 64 := -3;
  begin

    j := counter - 3;
    j_compressor <= j;

    if rstn = '0' or (start = '1' and counter = 0) then
      A     <= H0(0);
      B     <= H0(1);
      C     <= H0(2);
      D     <= H0(3);
      E     <= H0(4);
      F     <= H0(5);
      G     <= H0(6);
      H     <= H0(7);
      j := -3;

    elsif clk'event and clk = '1' then

      if (j >= 0 and j < 64) then

        -- compressor        
        H <= G;
        G <= F;
        F <= E;
        E <= moduloAddition(D, T1);
        D <= C;
        C <= B;
        B <= A;
        A <= moduloAddition(T1, T2);

      end if;
    end if;

  end process;

  -- T1 and T2 computation for expander
  process (clk, rstn)
    variable j: integer range -3 to 64 := -3;
  begin

    j := counter - 3;
    j_T <= j;

    if rstn = '0' then
      T1    <= (others => '0');
      T2    <= (others => '0');
      j := -3;

    elsif clk'event and clk = '0' then
      if (j >= 0 and j < 64) then
        T1 <= moduloAddition(H,
                moduloAddition(csigma1(E),
                  moduloAddition(Ch(E, F, G),
                    moduloAddition(K(j),  W(j))
                  )
                )
              );

        T2 <= moduloAddition(csigma0(A), Maj(A, B, C));

      end if;
    end if;
  end process;

  --output process
  process (clk, rstn)
  begin
    if rstn = '0' then
      H_i_A <= (others => '0');
      H_i_B <= (others => '0');
      H_i_C <= (others => '0');
      H_i_D <= (others => '0');
      H_i_E <= (others => '0');
      H_i_F <= (others => '0');
      H_i_G <= (others => '0');
      H_i_H <= (others => '0');

    elsif clk'event and clk = '0' then
      if counter = 67 then
        H_i_A <= moduloAddition(A, H0(0));
        H_i_B <= moduloAddition(B, H0(1));
        H_i_C <= moduloAddition(C, H0(2));
        H_i_D <= moduloAddition(D, H0(3));
        H_i_E <= moduloAddition(E, H0(4));
        H_i_F <= moduloAddition(F, H0(5));
        H_i_G <= moduloAddition(G, H0(6));
        H_i_H <= moduloAddition(H, H0(7));
      end if;
    end if;

  end process;


  -- memory process
  process (clk, rstn)
  begin
    if rstn = '0' then

      M_j_memory_rcs_n  <= '1';
      M_j_memory_r_addr <= (others => 'Z');

    elsif clk'event and clk = '1' then
      if (start = '1' and counter = 0) or (counter > 0 and counter < 16) then
        M_j_memory_rcs_n <= '0';
        M_j_memory_r_addr <= std_ulogic_vector(to_unsigned(counter, 4));
      else
        M_j_memory_rcs_n  <= '1';
        M_j_memory_r_addr <= (others => 'Z');
      end if;
    end if;

  end process;




end architecture behav;