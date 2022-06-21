LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY port_io IS
	GENERIC (
		port_addr : STD_LOGIC_VECTOR (8 DOWNTO 0) := "000000001" ;
		alt_port_addr : STD_LOGIC_VECTOR (8 DOWNTO 0) :="000000010" ;
		tris_addr : STD_LOGIC_VECTOR (8 DOWNTO 0) := "000000011";
		alt_tris_addr : STD_LOGIC_VECTOR (8 DOWNTO 0) := "000000100"
	);
	PORT(
		nrst, clk_in, wr_en, rd_en: IN STD_LOGIC;
		abus_in: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		dbus_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		
		port_io: INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		dbus_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE port_io_arch OF port_io IS
	SIGNAL port_reg: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL tris_reg: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL latch: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	PROCESS(clk_in, nrst, wr_en, abus_in, rd_en,tris_reg,port_reg,latch,port_io)
	BEGIN
		IF nrst = '0' THEN
			port_reg <= (OTHERS => '0');
			tris_reg <= (OTHERS => '1');
		ELSIF RISING_EDGE(clk_in) THEN
			IF wr_en = '1' AND (abus_in = port_addr OR abus_in = alt_port_addr) THEN
				port_reg <= dbus_in;
			END IF;
			IF wr_en = '1' AND (abus_in = tris_addr OR abus_in = alt_tris_addr) THEN
				tris_reg <= dbus_in;
			END IF;
		END IF;
		CASE tris_reg(0) IS WHEN '0' => port_io(0) <= port_reg(0); WHEN others => port_io(0) <= 'Z'; END CASE;
		CASE tris_reg(1) IS WHEN '0' => port_io(1) <= port_reg(1); WHEN others => port_io(1) <= 'Z'; END CASE;
		CASE tris_reg(2) IS WHEN '0' => port_io(2) <= port_reg(2); WHEN others => port_io(2) <= 'Z'; END CASE;
		CASE tris_reg(3) IS WHEN '0' => port_io(3) <= port_reg(3); WHEN others => port_io(3) <= 'Z'; END CASE;
		CASE tris_reg(4) IS WHEN '0' => port_io(4) <= port_reg(4); WHEN others=> port_io(4) <= 'Z'; END CASE;
		CASE tris_reg(5) IS WHEN '0' => port_io(5) <= port_reg(5); WHEN others=> port_io(5) <= 'Z'; END CASE;
		CASE tris_reg(6) IS WHEN '0' => port_io(6) <= port_reg(6); WHEN others=> port_io(6) <= 'Z'; END CASE;
		CASE tris_reg(7) IS WHEN '0' => port_io(7) <= port_reg(7); WHEN others=> port_io(7) <= 'Z'; END CASE;
		
		IF rd_en = '0' OR (abus_in /= port_addr OR abus_in /= alt_port_addr) THEN
			latch <= port_io;
		ELSE
			latch <= "ZZZZZZZZ";
		END IF;
			
		IF rd_en = '1' AND (abus_in = tris_addr OR abus_in = alt_tris_addr) THEN
			dbus_out <= tris_reg;
		ELSIF rd_en = '1' AND (abus_in = port_addr OR abus_in = alt_port_addr) THEN
			dbus_out <= latch;
		ELSE
			dbus_out <= "ZZZZZZZZ";
		END IF;
		
	END PROCESS;
END ARCHITECTURE; 