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

ARCHITECTURE arch OF port_io IS
	SIGNAL port_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL tris_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL latch : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL i : INTEGER;--iterador do for
BEGIN
PROCESS(nrst, clk_in, abus_in, dbus_in, wr_en, rd_en, latch, tris_reg, port_reg)
	BEGIN
		--reset assincrono. port_reg = 0, tris_reg = 1
		IF nrst = '0' THEN 
			port_reg <= (OTHERS => '0');
			tris_reg <= (OTHERS => '1');
		ELSIF RISING_EDGE(clk_in) THEN
			--Operacao de escrita nos registradores tris_reg ou port_reg
			IF wr_en = '1' AND (abus_in = port_addr OR abus_in = alt_port_addr) THEN 
				port_reg <= dbus_in; --escrita em port_reg
			ELSIF wr_en = '1' AND (abus_in = tris_addr OR abus_in = alt_tris_addr) THEN
				tris_reg <= dbus_in; --escrita em tris_reg
			END IF;			
		END IF;
		--Operacao de Leitura, dbus_out <= tris_reg ou latch
		IF rd_en = '1' AND (abus_in = port_addr OR abus_in = alt_port_addr) THEN
			dbus_out <= latch; --leitura de latch
		ELSIF rd_en = '1' AND (abus_in = tris_addr OR abus_in = alt_tris_addr) THEN
			dbus_out <= tris_reg; --leitura de tris_reg
		ELSE
			dbus_out <= "ZZZZZZZZ";
		END IF;
		
		FOR i IN 0 TO 7 LOOP
			IF tris_reg(i) = '0' THEN
				port_io(i) <= port_reg(i);
			ELSE
				port_io(i) <= 'Z';
			END IF;
		END LOOP;
			
	END PROCESS;
	
	PROCESS(rd_en, port_io, abus_in)
	BEGIN
		IF NOT(rd_en = '1' AND (abus_in = port_addr OR abus_in = alt_port_addr)) THEN
			latch <= port_io;
		END IF;
	END PROCESS;		
		
END arch;