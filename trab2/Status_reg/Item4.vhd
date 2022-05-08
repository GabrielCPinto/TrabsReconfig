LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Item4 IS
	PORT (
		nrst, clk_in, wr_en, rd_en : IN STD_LOGIC;
		z_in, dc_in, c_in, z_wr_en : IN STD_LOGIC;
		dc_wr_en, c_wr_en : IN STD_LOGIC;
		abus_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		dbus_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rp_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		irp_out, z_out, dc_out, c_out : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE status_reg OF Item4 IS
BEGIN
PROCESS(nrst, clk_in, abus_in, dbus_in, wr_en, rd_en)
	BEGIN
		IF nrst = '0' THEN
			dbus_out <= (OTHERS => '0');
			irp_out <= '0';
			rp_out <= (OTHERS => '0');
			z_out <= '0';
			dc_out <= '0';
			c_out <= '0';			
		ELSIF RISING_EDGE(clk_in) AND abus_in(6 DOWNTO 0) = "0000011" AND wr_en = '1' THEN
			irp_out <= dbus_in(7);
			rp_out <= dbus_in (6 DOWNTO 5);
			dbus_out(7 DOWNTO 5) <= dbus_in(7 DOWNTO 5);
			dbus_out(4 DOWNTO 3) <= "11";			
			IF z_wr_en = '1' THEN
				dbus_out(2) <= z_in;
				z_out <= z_in;
			ELSE
				dbus_out(2) <= dbus_in(2);
				z_out <= dbus_in(2);
			END IF;
			IF dc_wr_en = '1' THEN
				dbus_out(1) <= dc_in;
				dc_out <= dc_in;
			ELSE
				dbus_out(1) <= dbus_in(1);
				dc_out <= dbus_in(1);
			END IF;
			IF c_wr_en = '1' THEN
				dbus_out(0) <= c_in;
				c_out <= c_in;
			ELSE
				dbus_out(0) <= dbus_in(0);
				c_out <= dbus_in(0);
			END IF;
		END IF;
		IF abus_in(6 DOWNTO 0) = "0000011" AND rd_en = '1' THEN
			dbus_out(7 DOWNTO 5) <= dbus_in(7 DOWNTO 5);
			dbus_out(4 DOWNTO 3) <= "11";
			dbus_out(2 DOWNTO 0) <= dbus_in(2 DOWNTO 0);
		ELSE
			dbus_out <= "ZZZZZZZZ";
		END IF;		
	END PROCESS;
END status_reg;
