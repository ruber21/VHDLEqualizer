LIBRARY lpm;
USE lpm.lpm_components.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY EqualizerTransposed IS

	GENERIC (W1 : INTEGER := 9; --BIT DE ENTRADA
			W2 : INTEGER := 18; --BIT DE MULTIPLICACIÓN
			W3 : INTEGER := 19; --BIT DE ADICIÓN
			W4 : INTEGER := 11; --LONGITUD DEL BIT DE SALIDA
			L : INTEGER := 4;   --LONGITU DEL FILTRO
			Mpipe : INTEGER := 3
			);
	PORT (
			clk : IN STD_LOGIC;
			Load_x : IN STD_LOGIC;
			x_in : IN STD_LOGIC_VECTOR (W1-1 DOWNTO 0);
			c_in : IN STD_LOGIC_VECTOR (W1-1 DOWNTO 0);
			y_out : OUT STD_LOGIC_VECTOR (W4-1 DOWNTO 0)
			);

END EqualizerTransposed;

ARCHITECTURE fpga OF EqualizerTransposed IS

		SUBTYPE N1BIT IS STD_LOGIC_VECTOR(W1-1 DOWNTO 0);
		SUBTYPE N2BIT IS STD_LOGIC_VECTOR(W2-1 DOWNTO 9);
		SUBTYPE N3BIT IS STD_LOGIC_VECTOR(W4-1 DOWNTO 0);
		TYPE ARRAY_N1BIT IS ARRAY (0 TO L-1) OF N1BIT;
		TYPE ARRAY_N2BIT IS ARRAY (0 TO L-1) OF N2BIT;
		TYPE ARRAY_N3BIT IS ARRAY (0 TO L-1) OF N3BIT;
		
		SIGNAL x : N1BIT;
		SIGNAL y : N3BIT;
		SIGNAL c : ARRAY_N1BIT; --Arreglo de los coefficientes
		SIGNAL p : ARRAY_N2BIT; --Arreglo de productos
		SIGNAL a : ARRAY_N3BIT;
		
	BEGIN
	
		Load: PROCESS
		BEGIN
			WAIT UNTIL clk = '1';
			IF (Load_x = '0') THEN
				C(L-1) <= c_in; --SE ALMACENAN LOS COEFICIENTES EN EL REGISTRO
				FOR I IN L-2 DOWNTO 0 LOOP
					c(I) <= c(I+1);
				END LOOP;
			ELSE
				  x <= x_in;
			END IF;
		END PROCESS Load;
	
		SOP: PROCESS (clk)
		BEGIN
			IF clk'event and (clk = '1') THEN
			FOR I IN 0 TO L-2 LOOP --SE CALCULAN LAS TRANSPOSICIONES
				a(I) <= (p(I)(W2-1) & P(I)) + a(I+1); --ADICIÓN
			END LOOP;
			a(L-1) <= p(L-1)(W2-1) & p(L-1);
			END IF;
			y <= a(0);
		END PROCESS SOP;
		
		MulGen: FOR I IN 0 TO L-1 GENERATE
		Muls: lpm_mult -- Se multiplica p(i) = c(i) * x;
	
			GENERIC MAP (LPM_WIDtHA => W1, LPM_WIDTHB => W1,
							 LPM_PIPELINE => Mpipe,
							 LPM_REPRESENTATION => "SIGNED",
							 LPM_WIDTHP => W2,
							 LPM_WIDTHS => W2)
			PORT MAP ( clock => clk, dataa => x,
							datab => c(I), result => p(I));
			END GENERATE;
		
		y_out <= y(W3-1 DOWNTO W3-W4);
	
	END fpga;
	
	
	
	
	


