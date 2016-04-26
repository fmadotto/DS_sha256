library ieee;
use ieee.std_logic_1164.all; 	-- std_logic

entity full_adder is
	port (
		x:		in	std_ulogic;
		y:		in	std_ulogic;
		cin:	in	std_ulogic; -- carry in
		sum:	out std_ulogic;
		cout:	out std_ulogic  -- carry out
	);
end entity full_adder;

architecture behav of full_adder is
begin
	
	sum	<= x xor y xor cin;
	cout <= (x and y) or (cin and (x xor y));

end architecture behav;
