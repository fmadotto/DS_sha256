library ieee;
use ieee.std_logic_1164.all;
 
entity cla_tb is
end cla_tb;
 
architecture behav of cla_tb is
 
  constant c_WIDTH : natural := 4;
   
  signal r_x    : std_ulogic_vector(c_WIDTH-1 downto 0) := (others => '0');
  signal r_y    : std_ulogic_vector(c_WIDTH-1 downto 0) := (others => '0');
  signal w_sum  : std_ulogic_vector(c_WIDTH-1 downto 0);
  signal w_cout : std_ulogic;
 
  component cla is
    generic (
      n : natural := 3                              -- number of bits
    );
    port (
      x     : in  std_ulogic_vector(n-1 downto 0);  -- first binary number to sum
      y     : in  std_ulogic_vector(n-1 downto 0);  -- second binary number to sum
      sum   : out std_ulogic_vector(n-1 downto 0);  -- result of the sum
      cout  : out std_ulogic                        -- carry out
    );
  end component cla;
   
begin
 
  -- Instantiate the Unit Under Test (UUT)
  UUT : cla
    generic map (
      n     => c_WIDTH
      )
    port map (
      x   => r_x,
      y   => r_y,
      sum => w_sum,
      cout => w_cout
    );
 
  -- Test bench is non-synthesizable
  process is
  begin
    r_x <= "000";
    r_y <= "001";
    wait for 10 ns;
    r_x <= "100";
    r_y <= "010";
    wait for 10 ns;
    r_x <= "010";
    r_y <= "110";
    wait for 10 ns;
    r_x <= "111";
    r_y <= "111";
    wait for 10 ns;
  end process;
   
end behav;