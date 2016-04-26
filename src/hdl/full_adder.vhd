-- Copyright (c) 2016 Federico Madotto and Coline Doebelin
-- federico.madotto (at) gmail.com
-- https://github.com/fmadotto/DS_bitcoin_miner

-- full_adder.vhd is part of DS_bitcoin_miner.

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
