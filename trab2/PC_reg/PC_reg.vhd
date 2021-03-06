LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY PC_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  ass?ncrono.  Quando  ativada  (n?vel  l?gico  baixo),  os  registradores  PC  e 
		--PCLATH dever?o ser zerados. Esta entrada tem prefer?ncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada  de  clock  para  incremento  e  carga  dos  registradores.  O  incremento  ou  a  carga acontece na borda de subida do clock, desde que habilitados.
		addr_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0); --Entrada de dados para carga no registrador PC, com habilita??o atrav?s de load_en. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endere?amento para PCL e para o registrador PCLATH. PCL deve ser escrito ou lido quando abus_in[6..0] = ?0000010?.
		--O registrador PCLATH deve ser escrito ou lido quando abus_in[6..0] = ?0001010?. Dessa forma, nos dois casos, apenas os 7 bits menos significativos de abus_in devem ser usados.
		-- Os outros dois bits n?o importam. 
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  em  PCL  e  PCLATH, com habilita??o  atrav?s de  wr_en, e endere?amento por abus_in.
		inc_pc : IN STD_LOGIC; --Entrada de habilita??o para incremento. Quando ativada (n?vel l?gico alto), o registrador PC  dever?  ser  incrementado,
		-- s?ncrono  com  clk_in.  Essa  entrada  tem  prefer?ncia  sobre load_pc e wr_en.
		load_pc : IN STD_LOGIC; --Entrada  de  habilita??o  para  carga.  Quando  ativada  (n?vel  l?gico  alto),  os  bits  10  a  0  do 
		--registrador PC devem ser carregados com o valor de addr_in e, ao mesmo tempo, os bits 12 a 11 de PC devem ser carregados com o conte?do de PCLATH[4..3]. Esta entrada tem 
		--prefer?ncia sobre wr_ena.
		wr_en : IN STD_LOGIC; --Entrada de habilita??o para escrita nos registradores. Quando ativada (n?vel l?gico  alto), 
		--PCL ou o registrador PCLATH ser? escrito, s?ncrono com clk_in, com o valor de dbus_in, 
		--desde  que  o  endere?o  correspondente,  conforme  especificado  acima,  esteja  presente  em 
		--abus_in. Caso contr?rio, nenhuma a??o ser? efetuada. Ao mesmo tempo que uma opera??o 
		--de escrita em PCL, os bits 12 a 8 do registrador PC devem ser escritos com o conte?do dos 5 bits menos significativos de PCLATH (bits 4 a 0). 
		rd_en : IN STD_LOGIC; --Entrada  de  habilita??o para leitura. Quando  ativada (n?vel l?gico  alto), a  sa?da  dbus_out 
		--dever? corresponder ao conte?do da parte baixa de PC (bits 7 a 0 ? chamados de PCL) ou 
		--PCLATH,  desde  que  o  endere?o  correspondente,  conforme  especificado  acima,  esteja 
		--presente em abus_in. Quando desativada ou quando o endere?o n?o corresponder a PCL 
		--ou PCLATH, a sa?da dever? ficar em alta imped?ncia (?ZZZZZZZZ?). 
		stack_push : IN STD_LOGIC; --Entrada de habilita??o para colocar valores na pilha. Quando ativada (n?vel l?gico alto), o 
		--conte?do atual de PC deve ser transferido para a primeira posi??o da pilha. O 
		--funcionamento  da  pilha  ?  independente  das  entradas inc_pc, load_en  e  wr_en,  podendo, 
		--inclusive, ser ativada ao mesmo tempo que a entrada load_pc. 
		stack_pop : IN STD_LOGIC; --Entrada de habilita??o para retirar valores da pilha. Quando ativada (n?vel l?gico alto), o 
		--registrador  PC  deve  ser  carregado  com  o  conte?do  da  primeira  posi??o  da  pilha.  Essa 
		--entrada tem prefer?ncia sobre inc_pc, load_en e wr_en. 
		nextpc_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0); --Sa?da  do  valor  a  ser  carregado  no  contador  (entrada  do  registrador  PC).  Essa  sa?da  est? 
		--sempre ativa, n?o dependendo de habilita??o. Quando n?o for ocorrer mudan?a no valor 
		--do contador, ou seja, quando nenhuma das entradas stack_pop, inc_pc, load_en ou wr_en 
		--estiver ativada, essa sa?da dever? corresponder ao valor atual do contador.
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Sa?da  de  dados  lidos  com  habilita??o  atrav?s  de  rd_en  e  endere?amento  por  abus_in. 
		--Quando n?o usada, dever? ficar em alta imped?ncia (?ZZZZZZZZ?).
	);
END ENTITY;

ARCHITECTURE arch1 OF PC_reg IS
	SIGNAL pc : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL pc_lath : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL nextpc : STD_LOGIC_VECTOR(12 downto 0);
	SIGNAL stack_reg0 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg1 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg2 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg3 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg4 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg5 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg6 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg7 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	CONSTANT one  : STD_LOGIC_VECTOR(12 DOWNTO 0) := "0000000000001";
	CONSTANT zero : STD_LOGIC_VECTOR(12 DOWNTO 0) := "0000000000000";
BEGIN
	
PROCESS(nrst, clk_in, nextpc)
	BEGIN
		IF nrst = '0' THEN --reset de pc_reg
			pc <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) THEN
			pc <= nextpc;
		END IF;
	END PROCESS;
	
PROCESS(nrst, clk_in, wr_en, abus_in)
	BEGIN
		IF nrst = '0' THEN --reset de pc_reg
			pc_lath <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) THEN
			IF wr_en = '1' AND abus_in(6 DOWNTO 0) = "0001010" THEN
				pc_lath <= dbus_in;
			END IF;			
		END IF;
	END PROCESS;
	
PROCESS(stack_pop, abus_in, addr_in, dbus_in, inc_pc, load_pc, pc, wr_en, stack_reg0, nextpc, pc_lath)
	BEGIN
		IF stack_pop = '1' THEN
			nextpc <= stack_reg0;
		--Operacao de incremento
		ELSIF inc_pc = '1' THEN
			nextpc <= (pc + one);
		--Operacoes de carga
		ELSIF load_pc = '1' THEN
			nextpc(10 DOWNTO 0)  <= addr_in;
			nextpc(12 DOWNTO 11) <= pc_lath(4 DOWNTO 3);
		ELSIF abus_in(6 DOWNTO 0) = "0000010" AND wr_en = '1' THEN --Escrita em PCL
			nextpc(7 DOWNTO 0)  <= dbus_in;
			nextpc(12 DOWNTO 8) <= pc_lath(4 DOWNTO 0);
		ELSE --Escrita em PCLath
			nextpc <= pc;
		END IF;
		
		nextpc_out <= nextpc;
		
	END PROCESS;
	
PROCESS(abus_in, rd_en, pc, pc_lath)
	BEGIN
		--Operacoes de leitura em PCL ou PCLath
		IF abus_in(6 DOWNTO 0) = "0000010" AND rd_en = '1' THEN --Leitura em PCL
			dbus_out <= pc(7 DOWNTO 0);
		ELSIF abus_in(6 DOWNTO 0) = "0001010" AND rd_en = '1' THEN --Leitura em PCLath
			dbus_out <= pc_lath;
		ELSE --Endere?o n?o corresponde e rd_en = '0'
			dbus_out <= "ZZZZZZZZ";  --saida em alta imped??ncia
		END IF;
	END PROCESS;
	
PROCESS(nrst, clk_in, stack_push, stack_pop, abus_in, inc_pc, load_pc, wr_en, rd_en)
	BEGIN
		IF nrst = '0' THEN --reset dos registradores
			stack_reg0 <= (OTHERS => '0');
			stack_reg1 <= (OTHERS => '0');
			stack_reg2 <= (OTHERS => '0');
			stack_reg3 <= (OTHERS => '0');
			stack_reg4 <= (OTHERS => '0');
			stack_reg5 <= (OTHERS => '0');
			stack_reg6 <= (OTHERS => '0');
			stack_reg7 <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) THEN
			--Opera????o de desempilhar
			IF stack_push = '1' THEN
				stack_reg7 <= stack_reg6;
				stack_reg6 <= stack_reg5;
				stack_reg5 <= stack_reg4;
				stack_reg4 <= stack_reg3;
				stack_reg3 <= stack_reg2;
				stack_reg2 <= stack_reg1;
				stack_reg1 <= stack_reg0;
				stack_reg0 <= pc;
			--Opera????o de empilhar
			ELSIF stack_pop = '1' THEN
				stack_reg0 <= stack_reg1;
				stack_reg1 <= stack_reg2;
				stack_reg2 <= stack_reg3;
				stack_reg3 <= stack_reg4;
				stack_reg4 <= stack_reg5;
				stack_reg5 <= stack_reg6;
				stack_reg6 <= stack_reg7;
				stack_reg7 <= zero;
			END IF;
		END IF;
	END PROCESS;

END arch1;