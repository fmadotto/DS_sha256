-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- coline.doebelin (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- cla.vhd is part of DS_bitcoin_miner.

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

entity cla is
  generic (
    n : natural := 32                             -- input size (default is 32 bits)
  );
  port (
    x     : in  std_ulogic_vector(n-1 downto 0);  -- first binary number to sum
    y     : in  std_ulogic_vector(n-1 downto 0);  -- second binary number to sum
    sum   : out std_ulogic_vector(n-1 downto 0);  -- result of the sum
    cout  : out std_ulogic                        -- carry out
  );
end entity cla;

architecture rtl of cla is

  component full_adder is
    port (
      x    : in	 std_ulogic;
      y    : in	 std_ulogic;
      cin  : in	 std_ulogic; -- carry in
      sum  : out std_ulogic;
      cout : out std_ulogic  -- carry out
    );
  end component full_adder;

	signal G : std_ulogic_vector(n-1 downto 0); -- generate signal:  G_i = x_i * y_i
	signal P : std_ulogic_vector(n-1 downto 0); -- propagate signal: P_i = x_i + y_i
  signal S : std_ulogic_vector(n-1 downto 0); -- sum signal
	signal C : std_ulogic_vector(n   downto 0); -- carry signal

begin

  FA_gen : for i in 0 to n-1 generate
    FA_instance : full_adder
      port map (
        x    => x(i),
        y    => y(i),
        cin  => C(i),
        sum  => S(i),
        cout => open
      );
  end generate FA_gen;

  C(0) <= '0'; -- there is no initial carry

  PGC_gen : for j in 0 to n-1 generate
    G(j)   <= x(j) and y(j);
    P(j)   <= x(j) or  y(j);
    C(j+1) <= G(j) or (P(j) and C(j));
  end generate PGC_gen;

  sum  <= S;
  cout <= C(n);

end architecture rtl;
