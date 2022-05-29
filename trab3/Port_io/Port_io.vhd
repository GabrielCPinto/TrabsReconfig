LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Port_io IS
	GENERIC(
	port_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "011000110";--Especifica o endereÃ§o de escrita no registrador port_reg (quando wr_en = â€˜1â€™) ou 
--para leitura do latch (quando rd_en = â€˜1â€™).
	tris_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "100111001";--Especifica o endereÃ§o de escrita no registrador tris_reg (quando wr_en = â€˜1â€™) ou 
--para leitura do mesmo registrador (quando rd_en = â€˜1â€™).
	alt_port_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "011000110";--EndereÃ§o alternativo a port_addr. Quando nÃ£o em uso, deve ser configurado com 
--o mesmo valor de port_addr
	alt_tris_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "100111001"--EndereÃ§o alternativo a tris_addr. Quando nÃ£o em uso, deve ser configurado com o 
--mesmo valor de tris_addr. 
	
	);
	PORT (
		nrst : IN STD_LOGIC; --Entrada de reset assÃ­ncrono. Quando ativada (nÃ­vel lÃ³gico baixo),  o registrador port_reg 
--deverÃ¡ ter todos os seus bits zerados e o registrador tris_reg deverÃ¡ ter todos os seus bits 
--setados (= â€˜1â€™). Esta entrada tem preferÃªncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada  de  clock  do sistema. Todos  os registradores devem ser escritos sÃ­ncronos  com a 
--borda de subida desse clock.
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endereÃ§amento para os registradores internos. Os endereÃ§os dos registradores 
--sÃ£o especificados atravÃ©s de 4 â€œgenericâ€, conforme especificado no item 2.4.
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Barramento  de  entrada  de  dados,  com  8  bits,  para  a  escrita  nos  registradores,  com 
--habilitaÃ§Ã£o atravÃ©s de wr_en, e endereÃ§amento por abus_in.
		wr_en : IN STD_LOGIC; --Entrada de habilitaÃ§Ã£o para escrita nos registradores. Quando ativada (nÃ­vel lÃ³gico alto), o 
--registrador tris_reg ou port_reg serÃ¡ escrito, sÃ­ncrono com clk_in, com o valor de dbus_in, 
--desde que o endereÃ§o correspondente esteja presente em abus_in. Caso contrÃ¡rio, nenhuma 
--aÃ§Ã£o serÃ¡ efetuada
		rd_en : IN STD_LOGIC; --Entrada  de  habilitaÃ§Ã£o  para  leitura.  Quando  ativada  (nÃ­vel  lÃ³gico  alto),  o  barramento 
--dbus_out deverÃ¡ receber o conteÃºdo do registrador tris_reg ou do latch de entrada, desde 
--que  o  endereÃ§o  correspondente  esteja  presente  em  abus_in.  Quando  essa  entrada  estiver 
--desativada ou quando o endereÃ§o nÃ£o corresponder, a saÃ­da deverÃ¡ ficar em alta impedÃ¢ncia 
--(â€œZZZZZZZZâ€).
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Barramento de saÃ­da de dados, com 8 bits. HabilitaÃ§Ã£o atravÃ©s de rd_en e endereÃ§amento 
--por abus_in. Durante as operaÃ§Ãµes de leitura, comporta-se como saÃ­da. Quando nÃ£o em uso, 
--fica  em alta  impedÃ¢ncia (â€œZZZZZZZZâ€).  A operaÃ§Ã£o de  leitura  deve  ser completamente 
--combinacional, ou seja, nÃ£o depende de transiÃ§Ã£o de clk_in.
		port_io : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Porta bidirecional ou seja, modo = INOUT, com 8 bits. A direÃ§Ã£o serÃ¡ configurada, bit a 
--bit, atravÃ©s do registrador tris_reg
	);
END ENTITY;

ARCHITECTURE arch1 OF Port_io IS	
SIGNAL p_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL t_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

	PROCESS(nrst, clk_in, dbus_in, wr_en, abus_in, p_reg)BEGIN--port_reg & tris_reg
		IF nrst = '0' THEN
		   p_reg <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) AND 
		(wr_en = '1' AND ((abus_in =  port_addr )OR(abus_in = alt_port_addr))) THEN
			p_reg <= dbus_in;
		END IF;	
		
		IF nrst = '0' THEN
			t_reg <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) AND 
		(wr_en = '1' AND ((abus_in = tris_addr)OR(abus_in = alt_tris_addr))) THEN
			t_reg <= dbus_in;
		END IF;
		
		port_io <= p_reg;
	END PROCESS;

	PROCESS(port_io, rd_en)BEGIN--latch
		IF (rd_en = '0' AND ((abus_in = port_addr)OR(abus_in = alt_port_addr))) THEN
			dbus_out <= port_io;
		else
			dbus_out <= "ZZZZZZZZ";
		END IF;		
	END PROCESS;

END arch1;
