LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PC_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  ass�ncrono.  Quando  ativada  (n�vel  l�gico  baixo),  os  registradores  PC  e 
		--PCLATH dever�o ser zerados. Esta entrada tem prefer�ncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada  de  clock  para  incremento  e  carga  dos  registradores.  O  incremento  ou  a  carga acontece na borda de subida do clock, desde que habilitados.
		addr_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --Entrada de dados para carga no registrador PC, com habilita��o atrav�s de load_en. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endere�amento para PCL e para o registrador PCLATH. PCL deve ser escrito ou lido quando abus_in[6..0] = �0000010�.
		--O registrador PCLATH deve ser escrito ou lido quando abus_in[6..0] = �0001010�. Dessa forma, nos dois casos, apenas os 7 bits menos significativos de abus_in devem ser usados.
		-- Os outros dois bits n�o importam. 
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  em  PCL  e  PCLATH, com habilita��o  atrav�s de  wr_en, e endere�amento por abus_in.
		inc_pc : IN STD_LOGIC; --Entrada de habilita��o para incremento. Quando ativada (n�vel l�gico alto), o registrador PC  dever�  ser  incrementado,
		-- s�ncrono  com  clk_in.  Essa  entrada  tem  prefer�ncia  sobre load_pc e wr_en.
		load_pc : IN STD_LOGIC; --Entrada  de  habilita��o  para  carga.  Quando  ativada  (n�vel  l�gico  alto),  os  bits  10  a  0  do 
		--registrador PC devem ser carregados com o valor de addr_in e, ao mesmo tempo, os bits 12 a 11 de PC devem ser carregados com o conte�do de PCLATH[4..3]. Esta entrada tem 
		--prefer�ncia sobre wr_ena.
		wr_en : IN STD_LOGIC; --Entrada de habilita��o para escrita nos registradores. Quando ativada (n�vel l�gico  alto), 
		--PCL ou o registrador PCLATH ser� escrito, s�ncrono com clk_in, com o valor de dbus_in, 
		--desde  que  o  endere�o  correspondente,  conforme  especificado  acima,  esteja  presente  em 
		--abus_in. Caso contr�rio, nenhuma a��o ser� efetuada. Ao mesmo tempo que uma opera��o 
		--de escrita em PCL, os bits 12 a 8 do registrador PC devem ser escritos com o conte�do dos 5 bits menos significativos de PCLATH (bits 4 a 0). 
		rd_en : IN STD_LOGIC; --Entrada  de  habilita��o para leitura. Quando  ativada (n�vel l�gico  alto), a  sa�da  dbus_out 
		--dever� corresponder ao conte�do da parte baixa de PC (bits 7 a 0 � chamados de PCL) ou 
		--PCLATH,  desde  que  o  endere�o  correspondente,  conforme  especificado  acima,  esteja 
		--presente em abus_in. Quando desativada ou quando o endere�o n�o corresponder a PCL 
		--ou PCLATH, a sa�da dever� ficar em alta imped�ncia (�ZZZZZZZZ�). 
		stack_push : IN STD_LOGIC; --Entrada de habilita��o para colocar valores na pilha. Quando ativada (n�vel l�gico alto), o 
		--conte�do atual de PC deve ser transferido para a primeira posi��o da pilha. O 
		--funcionamento  da  pilha  �  independente  das  entradas inc_pc, load_en  e  wr_en,  podendo, 
		--inclusive, ser ativada ao mesmo tempo que a entrada load_pc. 
		stack_pop : IN STD_LOGIC; --Entrada de habilita��o para retirar valores da pilha. Quando ativada (n�vel l�gico alto), o 
		--registrador  PC  deve  ser  carregado  com  o  conte�do  da  primeira  posi��o  da  pilha.  Essa 
		--entrada tem prefer�ncia sobre inc_pc, load_en e wr_en. 
		nextpc_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0); --Sa�da  do  valor  a  ser  carregado  no  contador  (entrada  do  registrador  PC).  Essa  sa�da  est� 
		--sempre ativa, n�o dependendo de habilita��o. Quando n�o for ocorrer mudan�a no valor 
		--do contador, ou seja, quando nenhuma das entradas stack_pop, inc_pc, load_en ou wr_en 
		--estiver ativada, essa sa�da dever� corresponder ao valor atual do contador. 
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Sa�da  de  dados  lidos  com  habilita��o  atrav�s  de  rd_en  e  endere�amento  por  abus_in. 
		--Quando n�o usada, dever� ficar em alta imped�ncia (�ZZZZZZZZ�).
	);
END ENTITY;

ARCHITECTURE arch1 OF PC_reg IS
BEGIN
PROCESS(nrst, clk_in) --
	BEGIN
		IF nrst = '0' THEN --reset
		   dbus_out <= (OTHERS => '0');
		   nextpc_out <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) THEN
			IF stack_push = '1' THEN 
				stack_out(0) <= stack_in(0);
				stack_out(1) <= stack_in(0);
				stack_out(2) <= stack_in(1);
				stack_out(3) <= stack_in(2);
				stack_out(4) <= stack_in(3);
				stack_out(5) <= stack_in(4);
				stack_out(6) <= stack_in(5);
				stack_out(7) <= stack_in(6);
				stack_out(12 DOWNTO 7) <= "000000";
			END IF;
			IF stack_pop = '1' THEN
				stack_out(0) <= stack_in(1);
				stack_out(1) <= stack_in(2);
				stack_out(2) <= stack_in(3);
				stack_out(3) <= stack_in(4);
				stack_out(4) <= stack_in(5);
				stack_out(5) <= stack_in(6);
				stack_out(6) <= stack_in(7);
				stack_out(12 DOWNTO 7) <= "000000";
			END IF;
			IF inc_pc = '1' THEN
				nextpc_out <= (stack_in + "0000000000001");
			END IF;
			IF load_pc = '1' THEN
				nextpc_out(10 DOWNTO 0) <= addr_in;
				nextpc_out(12 DOWNTO 11) <= dbus_in(4 DOWNTO 3);
			END IF;
			IF abus_in(6 DOWNTO 0) = "0000010" AND wr_en = '1' THEN --Escrita em PCL
				nextpc_out(7 DOWNTO 0) <= dbus_in;
				nextpc_out(12 DOWNTO 8) <= dbus_in(4 DOWNTO 0);
			ELSIF abus_in(6 DOWNTO 0) = "0001010" AND wr_en = '1' THEN --Escrita em PCLath
				dbus_out <= dbus_in;
			END IF;
			IF abus_in(6 DOWNTO 0) = "0000010" AND rd_en = '1' THEN --Leitura em PCL
				dbus_out <= dbus_in;
			ELSIF abus_in(6 DOWNTO 0) = "0001010" AND rd_en = '1' THEN --Leitura em PCLath
				dbus_out <= dbus_in;
			ELSE
				dbus_out <= "ZZZZZZZZ";
			END IF;
		END IF;
	END PROCESS;
END arch1;