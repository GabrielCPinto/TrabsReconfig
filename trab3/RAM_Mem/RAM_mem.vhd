LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RAM_mem IS
PORT (
	nrst : IN STD_LOGIC; --Entrada de reset ass�ncrono. Quando ativada (n�vel l�gico baixo), todos os bits da mem�ria
--RAM dever�o ser zerados. Esta entrada tem prefer�ncia sobre todas as outras.
	clk_in : IN STD_LOGIC; --Entrada de clock do sistema. A escrita na mem�ria acontece na borda de subida do clock,
--desde que habilitada.
	wr_en : IN STD_LOGIC; --Entrada de habilita��o para escrita na mem�ria. Quando ativada (n�vel l�gico alto), a
--mem�ria ser� escrita, s�ncrona com clk_in, com o valor de dbus_in, desde que o endere�o correspondente esteja 
--presente em abus_in, conforme especificado no item 3.3. Caso contr�rio, nenhuma a��o ser� efetuada. 
	rd_en : IN STD_LOGIC; --Entrada de habilita��o para leitura. Quando ativada (n�vel l�gico alto), a sa�da dbus_out
--dever� corresponder ao conte�do da mem�ria endere�ada. Quando desativada ou quando o endere�o n�o corresponder 
--ao especificado no item 3.3, a sa�da dever� ficar em alta imped�ncia (�ZZZZZZZZ�). 
	abus_in :  IN STD_LOGIC_VECTOR (8 DOWNTO 0); --Entrada de endere�amento. Aponta a c�lula de mem�ria a ser 
--escrita ou lida, desde que habilitada. As faixas de endere�o para cada �rea de mem�ria est�o definidas no item 3.3.
	dbus_in :  IN STD_LOGIC_VECTOR (7 DOWNTO 0); --Entrada de dados para escrita na mem�ria, com habilita��o 
--atrav�s de wr_en, e endere�amento por abus_in.
	dbus_out :  OUT STD_LOGIC_VECTOR (7 DOWNTO 0) --Barramento de sa�da de dados, com 8 bits. Habilita��o a
--trav�s de rd_en e endere�amento por abus_in. Durante as opera��es de leitura, comporta-se como sa�da. 
--Quando n�o em uso, fica em alta imped�ncia (�ZZZZZZZZ�). A opera��o de leitura deve ser completamente
--combinacional, ou seja, n�o depende de transi��o de clk_in.
);
END ENTITY;

ARCHITECTURE arch1 OF RAM_mem IS
	TYPE memory_type IS ARRAY (0 to 79) OF STD_LOGIC_VECTOR (7 DOWNTO 0); --Array de 80 bytes
	TYPE small_memory_type IS ARRAY (0 DOWNTO 15) OF STD_LOGIC_VECTOR (7 DOWNTO 0);	 --Array 16 bytes
	
	SIGNAL mem0 : memory_type; --Primeira �rea de mem�ria
	SIGNAL mem1 : memory_type; --Segunda �rea de mem�ria
	SIGNAL mem2 : memory_type; --Terceira �rea de mem�ria
	SIGNAL mem_com : small_memory_type; --Quarta �rea de mem�ria
BEGIN
	PROCESS(nrst, clk_in) 
		BEGIN
		
		IF(nrst = '0') THEN  --Limpa toda �rea da RAM
			FOR i IN 0 TO 79 LOOP
				mem0(i) <= (OTHERS <= '0'); 
				mem1(i) <= (OTHERS <= '0');
				mem2(i) <= (OTHERS <= '0');
			END LOOP;
			
			FOR i IN 0 TO 15 LOOP 
				mem_com(i) <= (OTHERS <= '0');
			END LOOP:
		ELSIF RISING_EDGE(clk_in) THEN
			
		END IF;
	END PROCESS;
END arch1;