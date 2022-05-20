LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Port_io IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada de reset ass�ncrono. Quando ativada (n�vel l�gico baixo),  o registrador port_reg 
--dever� ter todos os seus bits zerados e o registrador tris_reg dever� ter todos os seus bits 
--setados (= �1�). Esta entrada tem prefer�ncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada  de  clock  do sistema. Todos  os registradores devem ser escritos s�ncronos  com a 
--borda de subida desse clock.
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endere�amento para os registradores internos. Os endere�os dos registradores 
--s�o especificados atrav�s de 4 �generic�, conforme especificado no item 2.4.
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Barramento  de  entrada  de  dados,  com  8  bits,  para  a  escrita  nos  registradores,  com 
--habilita��o atrav�s de wr_en, e endere�amento por abus_in.
		wr_en : IN STD_LOGIC; --Entrada de habilita��o para escrita nos registradores. Quando ativada (n�vel l�gico alto), o 
--registrador tris_reg ou port_reg ser� escrito, s�ncrono com clk_in, com o valor de dbus_in, 
--desde que o endere�o correspondente esteja presente em abus_in. Caso contr�rio, nenhuma 
--a��o ser� efetuada
		rd_en : IN STD_LOGIC; --Entrada  de  habilita��o  para  leitura.  Quando  ativada  (n�vel  l�gico  alto),  o  barramento 
--dbus_out dever� receber o conte�do do registrador tris_reg ou do latch de entrada, desde 
--que  o  endere�o  correspondente  esteja  presente  em  abus_in.  Quando  essa  entrada  estiver 
--desativada ou quando o endere�o n�o corresponder, a sa�da dever� ficar em alta imped�ncia 
--(�ZZZZZZZZ�).
		dbus_out : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Barramento de sa�da de dados, com 8 bits. Habilita��o atrav�s de rd_en e endere�amento 
--por abus_in. Durante as opera��es de leitura, comporta-se como sa�da. Quando n�o em uso, 
--fica  em alta  imped�ncia (�ZZZZZZZZ�).  A opera��o de  leitura  deve  ser completamente 
--combinacional, ou seja, n�o depende de transi��o de clk_in.
		port_io : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Porta bidirecional ou seja, modo = INOUT, com 8 bits. A dire��o ser� configurada, bit a 
--bit, atrav�s do registrador tris_reg
		port_addr : IN generic STD_LOGIC; --Especifica o endere�o de escrita no registrador port_reg (quando wr_en = �1�) ou 
--para leitura do latch (quando rd_en = �1�).
		tris_addr : IN generic; --Especifica o endere�o de escrita no registrador tris_reg (quando wr_en = �1�) ou 
--para leitura do mesmo registrador (quando rd_en = �1�).
		alt_port_addr : IN generic; --Endere�o alternativo a port_addr. Quando n�o em uso, deve ser configurado com 
--o mesmo valor de port_addr
		alt_tris_addr : IN generic --Endere�o alternativo a tris_addr. Quando n�o em uso, deve ser configurado com o 
--mesmo valor de tris_addr. 
	);
END ENTITY;

ARCHITECTURE arch1 OF Port_io IS	
BEGIN

	-- Parte sequencial da m�quina de estados:
	PROCESS(nrst, clk)
	BEGIN
	IF nrst = '0' THEN
	port_reg <= (OTHERS => '0');
	tris_reg <= (OTHERS => '1');
	ELSIF RISING_EDGE(clk) THEN
	pres_state <= next_state;
	END IF;
	END PROCESS;

END arch1