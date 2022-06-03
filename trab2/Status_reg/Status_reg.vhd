LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Status_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  ass�ncrono.  Quando  ativada  (n�vel  l�gico  baixo),  todos  os  bits  do registrador dever�o ser zerados. 
		--Esta entrada tem prefer�ncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada de clock para escrita no registrador. A escrita em todos os registradores acontece na borda de subida do clock, desde que habilitada. 
		wr_en : IN STD_LOGIC; --Entrada  de  habilita��o  para  escrita  no  registrador.  Quando  ativada  (n�vel  l�gico  alto),  o 
		--registrador ser� escrito, s�ncrono com clk_in, com o valor de dbus_in, desde que o endere�o 
		--correspondente, conforme especificado acima, esteja presente em abus_in. Caso contr�rio, nenhuma a��o ser� efetuada.
		rd_en : IN STD_LOGIC; --Entrada  de  habilita��o para leitura. Quando  ativada (n�vel l�gico  alto), a  sa�da  dbus_out 
		--dever�  corresponder  ao  conte�do  do  registrador,  exceto  os  bits  4  e  3,  que  dever�o  ser 
		--sempre lidos como �1�. Quando desativada ou quando o endere�o  n�o  corresponder  ao 
		--especificado acima, a sa�da dever� ficar em alta imped�ncia (�ZZZZZZZZ�).
		z_in : IN STD_LOGIC; --Entrada de dado para escrita no bit 2 do registrador, com habilita��o atrav�s de z_wr_en.
		dc_in : IN STD_LOGIC; --Entrada de dado para escrita no bit 1 do registrador, com habilita��o atrav�s de dc_wr_en.
		c_in : IN STD_LOGIC; --Entrada de dado para escrita no bit 0 do registrador, com habilita��o atrav�s de c_wr_en.
		z_wr_en : IN STD_LOGIC; --Entrada  para  habilita��o  da escrita  no bit 2 do registrador. Quando ativada (n�vel l�gico alto),
		-- o bit 2 do registrador ser� escrito, s�ncrono com clk_in, com o valor de z_in. Essa entrada tem prefer�ncia sobre wr_en.
		dc_wr_en : IN STD_LOGIC; --Entrada  para  habilita��o  da escrita  no bit 1 do registrador. Quando ativada (n�vel l�gico alto),
		-- o bit 1 do registrador ser� escrito, s�ncrono com clk_in, com o valor de dc_in. Essa entrada tem prefer�ncia sobre wr_en. 
		c_wr_en : IN STD_LOGIC; --Entrada  para  habilita��o  da escrita  no bit 0 do registrador. Quando ativada (n�vel l�gico alto),
		-- o bit 0 do registrador  ser� escrito, s�ncrono com clk_in, com o valor de c_in. Essa entrada tem prefer�ncia sobre wr_en. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endere�amento. O registrador deve ser escrito ou lido quando abus_in[6..0] = �0000011�. 
		--Dessa forma, apenas os 7 bits menos significativos de abus_in devem ser usados. Os outros dois bits n�o importam. 
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  no  registrador,  com  habilita��o  atrav�s  de  wr_en,  e endere�amento por abus_in. 
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Sa�da  de  dados  lidos  com  habilita��o  atrav�s  de  rd_en  e  endere�amento  por  abus_in. 
		--Quando n�o usada, dever� ficar em alta imped�ncia (�ZZZZZZZZ�).
		irp_out : OUT STD_LOGIC; --Sa�da correspondente ao bit 7 do registrador. Essa sa�da est� sempre ativa, n�o dependendo de habilita��o
		z_out : OUT STD_LOGIC; --Sa�da correspondente ao bit 2 do registrador. Essa sa�da est� sempre ativa, n�o dependendo de habilita��o.
		dc_out : OUT STD_LOGIC; --Sa�da correspondente ao bit 1 do registrador. Essa sa�da est� sempre ativa, n�o dependendo de habilita��o.
		c_out : OUT STD_LOGIC; --Sa�da correspondente ao bit 0 do registrador. Essa sa�da est� sempre ativa, n�o dependendo de habilita��o.
		rp_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) --Sa�da  correspondente  aos  bits  6  e  5  do  registrador.  Essa  sa�da  est�  sempre  ativa,  n�o dependendo de habilita��o.
	
	);
END ENTITY;

ARCHITECTURE arch1 OF Status_reg IS
BEGIN
PROCESS(nrst, clk_in, abus_in, dbus_in, wr_en, rd_en)
	BEGIN
		IF nrst = '0' THEN --reset
			dbus_out <= (OTHERS => '0');
			irp_out <= '0';
			rp_out <= (OTHERS => '0');
			z_out <= '0';
			dc_out <= '0';
			c_out <= '0';	
		ELSIF RISING_EDGE(clk_in) AND abus_in(6 DOWNTO 0) = "0000011" THEN
		
			IF z_wr_en = '1' THEN--prioridade do z_wr_en
				dbus_out(2) <= z_in;
			END IF;
			
			IF dc_wr_en = '1' THEN--prioridade do dc_wr_en
				dbus_out(1) <= dc_in;
			END IF;
				
			IF c_wr_en = '1' THEN--prioridade do c_wr_en
				dbus_out(0) <= c_in;
			END IF;
			
			IF wr_en = '1' THEN --leitura
				irp_out <= dbus_in(7);
				rp_out <= dbus_in (6 DOWNTO 5);
				z_out <= dbus_in(2);
				dc_out <= dbus_in(1);
				c_out <= dbus_in(0);
				dbus_out <= dbus_in;
			END IF;
		END IF;
		
		 --escrita
		IF abus_in(6 DOWNTO 0) = "0000011" AND rd_en = '1' THEN
				dbus_out(7 DOWNTO 5) <= dbus_in(7 DOWNTO 5);
				dbus_out(4 DOWNTO 3) <= "11";
				dbus_out(2 DOWNTO 0) <= dbus_in(2 DOWNTO 0);
		ELSE
				dbus_out <= "ZZZZZZZZ";
		END IF;	
	END PROCESS;
END arch1;
