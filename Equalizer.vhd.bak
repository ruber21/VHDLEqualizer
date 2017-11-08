PACKAGE eight_bit_int IS
	SUBTYPE BYTE IS INTEGER RANGE -128 TO 127;
	TYPE ARRAY_BYTE IS ARRAY (0 TO 3) OF BYTE;
END eight_bit_int;

LIBRARY work;
USE work.eight_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Equalizer IS
	PORT (clk : IN STD_LOGIC;
	x : IN BYTE;
	y : OUT BYTE);
END Equalizer;
	
ARCHITECTURE flex OF Equalizer IS

   SIGNAL tap : ARRAY_BYTE := (0,0,0,0);
	
BEGIN

	p1 : PROCESS
	BEGIN
		WAIT UNTIL clk = '1';
		y <= 2 * tap(1) + tap(1) + tap(1) / 2 + tap(1) / 4 
		   + 2 * tap(2) + tap(2) + tap(2) / 2 + tap(2) / 4
			- tap(3) - tap(0);
		FOR I IN 3 DOWNTO 1 LOOP
		  tap(I) <= tap(I -1);
		 END LOOP;
		 tap(0) <= x;
	END PROCESS;

END flex;

