LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PC_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  assíncrono.  Quando  ativada  (nível  lógico  baixo),  os  registradores  PC  e 
		--PCLATH deverão ser zerados. Esta entrada tem preferência sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada  de  clock  para  incremento  e  carga  dos  registradores.  O  incremento  ou  a  carga acontece na borda de subida do clock, desde que habilitados.
		addr_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --Entrada de dados para carga no registrador PC, com habilitação através de load_en. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endereçamento para PCL e para o registrador PCLATH. PCL deve ser escrito ou lido quando abus_in[6..0] = “0000010”.
		--O registrador PCLATH deve ser escrito ou lido quando abus_in[6..0] = “0001010”. Dessa forma, nos dois casos, apenas os 7 bits menos significativos de abus_in devem ser usados.
		-- Os outros dois bits não importam. 
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  em  PCL  e  PCLATH, com habilitação  através de  wr_en, e endereçamento por abus_in.
		inc_pc : IN STD_LOGIC; --Entrada de habilitação para incremento. Quando ativada (nível lógico alto), o registrador PC  deverá  ser  incrementado,
		-- síncrono  com  clk_in.  Essa  entrada  tem  preferência  sobre load_pc e wr_en.
		load_pc : IN STD_LOGIC; --Entrada  de  habilitação  para  carga.  Quando  ativada  (nível  lógico  alto),  os  bits  10  a  0  do 
		--registrador PC devem ser carregados com o valor de addr_in e, ao mesmo tempo, os bits 12 a 11 de PC devem ser carregados com o conteúdo de PCLATH[4..3]. Esta entrada tem 
		--preferência sobre wr_ena.
		wr_en : IN STD_LOGIC; --Entrada de habilitação para escrita nos registradores. Quando ativada (nível lógico  alto), 
		--PCL ou o registrador PCLATH será escrito, síncrono com clk_in, com o valor de dbus_in, 
		--desde  que  o  endereço  correspondente,  conforme  especificado  acima,  esteja  presente  em 
		--abus_in. Caso contrário, nenhuma ação será efetuada. Ao mesmo tempo que uma operação 
		--de escrita em PCL, os bits 12 a 8 do registrador PC devem ser escritos com o conteúdo dos 5 bits menos significativos de PCLATH (bits 4 a 0). 
		rd_en : IN STD_LOGIC; --Entrada  de  habilitação para leitura. Quando  ativada (nível lógico  alto), a  saída  dbus_out 
		--deverá corresponder ao conteúdo da parte baixa de PC (bits 7 a 0 – chamados de PCL) ou 
		--PCLATH,  desde  que  o  endereço  correspondente,  conforme  especificado  acima,  esteja 
		--presente em abus_in. Quando desativada ou quando o endereço não corresponder a PCL 
		--ou PCLATH, a saída deverá ficar em alta impedância (“ZZZZZZZZ”). 
		stack_push : IN STD_LOGIC; --Entrada de habilitação para colocar valores na pilha. Quando ativada (nível lógico alto), o 
		--conteúdo atual de PC deve ser transferido para a primeira posição da pilha. O 
		--funcionamento  da  pilha  é  independente  das  entradas inc_pc, load_en  e  wr_en,  podendo, 
		--inclusive, ser ativada ao mesmo tempo que a entrada load_pc. 
		stack_pop : IN STD_LOGIC; --Entrada de habilitação para retirar valores da pilha. Quando ativada (nível lógico alto), o 
		--registrador  PC  deve  ser  carregado  com  o  conteúdo  da  primeira  posição  da  pilha.  Essa 
		--entrada tem preferência sobre inc_pc, load_en e wr_en. 
		nextpc_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0); --Saída  do  valor  a  ser  carregado  no  contador  (entrada  do  registrador  PC).  Essa  saída  está 
		--sempre ativa, não dependendo de habilitação. Quando não for ocorrer mudança no valor 
		--do contador, ou seja, quando nenhuma das entradas stack_pop, inc_pc, load_en ou wr_en 
		--estiver ativada, essa saída deverá corresponder ao valor atual do contador. 
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Saída  de  dados  lidos  com  habilitação  através  de  rd_en  e  endereçamento  por  abus_in. 
		--Quando não usada, deverá ficar em alta impedância (“ZZZZZZZZ”).
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