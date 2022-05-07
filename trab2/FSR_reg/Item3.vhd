--ACREDITO ESTAR CERTO, MAS RECOMENDO VERIFICAREM TAMBÉM PARA VER SE VOCÊS DISCORDAM



LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Item3 IS
	PORT (
		nrst, clk_in, wr_en, rd_en : IN STD_LOGIC;
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		fsr_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE fsr_reg OF Item3 IS
BEGIN
PROCESS(nrst, clk_in, abus_in, dbus_in, wr_en, rd_en)
	BEGIN
		IF nrst = '0' THEN
		   fsr_out <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) AND abus_in(6 DOWNTO 0) = "0000100" AND wr_en = '1' THEN
			fsr_out <= dbus_in;
		END IF;		
		IF abus_in(6 DOWNTO 0) = "0000100" AND rd_en = '1' THEN
			dbus_out <= dbus_in;
		ELSE
			dbus_out <= "ZZZZZZZZ";
		END IF;
	END PROCESS;
END fsr_reg;
