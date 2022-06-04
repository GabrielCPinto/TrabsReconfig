LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSR_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  ass�ncrono.  Quando  ativada  (n�vel  l�gico  baixo),  todos  os  bits  do registrador dever�o ser zerados. 
		--Esta entrada tem prefer�ncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada de clock para escrita no registrador. A escrita acontece na borda de subida do clock, desde que habilitada.
		wr_en : IN STD_LOGIC; --Entrada  de  habilita��o  para  escrita  no  registrador.  Quando  ativada  (n�vel  l�gico  alto),  o registrador ser� escrito, 
		--s�ncrono com clk_in, com o valor de dbus_in, desde que o endere�o correspondente, conforme especificado acima, esteja presente em abus_in. Caso contr�rio, 
		--nenhuma a��o ser� efetuada.
		rd_en : IN STD_LOGIC; --Entrada  de  habilita��o para leitura. Quando  ativada (n�vel l�gico  alto), a  sa�da  dbus_out dever�  corresponder  ao  conte�do  do  registrador,
		--desde  que  o  endere�o  correspondente, conforme especificado acima, esteja presente em abus_in. Quando desativada ou quando o endere�o n�o corresponder 
		--ao especificado acima, a sa�da dever� ficar em alta imped�ncia (�ZZZZZZZZ�).  A  opera��o  de  leitura  deve  ser  completamente  combinacional,  ou  seja, 
		--n�o depende de transi��o de clk_in. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endere�amento. O registrador deve ser escrito ou lido quando abus_in[6..0] = �0000100�.
		-- Dessa forma, apenas os 7 bits menos significativos de abus_in devem ser usados. Os outros dois bits n�o importam.
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  no  registrador,  com  habilita��o  atrav�s  de  wr_en,  e endere�amento por abus_in.
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Sa�da  de  dados  lidos  com  habilita��o  atrav�s  de  rd_en  e  endere�amento  por  abus_in. 
		--Quando n�o usada, dever� ficar em alta imped�ncia (�ZZZZZZZZ�). 
		fsr_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Sa�da  correspondente  ao  registrador.  Essa  sa�da  est�  sempre  ativa,  n�o  dependendo  de habilita��o. 
	);
END ENTITY;

ARCHITECTURE arch1 OF FSR_reg IS
SIGNAL ler : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
PROCESS(nrst, clk_in, abus_in, dbus_in, wr_en, rd_en)
	BEGIN
		IF nrst = '0' THEN -- verificando se deve resetar
		   fsr_out <= (OTHERS => '0');
		-- escrita
		ELSIF RISING_EDGE(clk_in) AND abus_in(6 DOWNTO 0) = "0000100" AND wr_en = '1' THEN
			fsr_out <= dbus_in;
			ler <= dbus_in;
		END IF;		
		--leitura
		IF abus_in(6 DOWNTO 0) = "0000100" AND rd_en = '1' THEN
			dbus_out <= ler;
		ELSE --caso rd_en = 0
			dbus_out <= "ZZZZZZZZ";
		END IF;
	END PROCESS;
END arch1;
