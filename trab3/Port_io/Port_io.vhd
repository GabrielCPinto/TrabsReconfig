LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Port_io IS
	GENERIC(
	port_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "011000110";--Especifica o endereço de escrita no registrador port_reg (quando wr_en = ‘1’) ou 
--para leitura do latch (quando rd_en = ‘1’).
	tris_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "100111001";--Especifica o endereço de escrita no registrador tris_reg (quando wr_en = ‘1’) ou 
--para leitura do mesmo registrador (quando rd_en = ‘1’).
	alt_port_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "011000110";--Endereço alternativo a port_addr. Quando não em uso, deve ser configurado com 
--o mesmo valor de port_addr
	alt_tris_addr : STD_LOGIC_VECTOR(8 DOWNTO 0) := "100111001"--Endereço alternativo a tris_addr. Quando não em uso, deve ser configurado com o 
--mesmo valor de tris_addr. 
	
	);
	PORT (
		nrst : IN STD_LOGIC; --Entrada de reset assíncrono. Quando ativada (nível lógico baixo),  o registrador port_reg 
--deverá ter todos os seus bits zerados e o registrador tris_reg deverá ter todos os seus bits 
--setados (= ‘1’). Esta entrada tem preferência sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada  de  clock  do sistema. Todos  os registradores devem ser escritos síncronos  com a 
--borda de subida desse clock.
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endereçamento para os registradores internos. Os endereços dos registradores 
--são especificados através de 4 “generic”, conforme especificado no item 2.4.
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Barramento  de  entrada  de  dados,  com  8  bits,  para  a  escrita  nos  registradores,  com 
--habilitação através de wr_en, e endereçamento por abus_in.
		wr_en : IN STD_LOGIC; --Entrada de habilitação para escrita nos registradores. Quando ativada (nível lógico alto), o 
--registrador tris_reg ou port_reg será escrito, síncrono com clk_in, com o valor de dbus_in, 
--desde que o endereço correspondente esteja presente em abus_in. Caso contrário, nenhuma 
--ação será efetuada
		rd_en : IN STD_LOGIC; --Entrada  de  habilitação  para  leitura.  Quando  ativada  (nível  lógico  alto),  o  barramento 
--dbus_out deverá receber o conteúdo do registrador tris_reg ou do latch de entrada, desde 
--que  o  endereço  correspondente  esteja  presente  em  abus_in.  Quando  essa  entrada  estiver 
--desativada ou quando o endereço não corresponder, a saída deverá ficar em alta impedância 
--(“ZZZZZZZZ”).
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Barramento de saída de dados, com 8 bits. Habilitação através de rd_en e endereçamento 
--por abus_in. Durante as operações de leitura, comporta-se como saída. Quando não em uso, 
--fica  em alta  impedância (“ZZZZZZZZ”).  A operação de  leitura  deve  ser completamente 
--combinacional, ou seja, não depende de transição de clk_in.
		port_io : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Porta bidirecional ou seja, modo = INOUT, com 8 bits. A direção será configurada, bit a 
--bit, através do registrador tris_reg
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
