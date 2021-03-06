LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Stack IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  ass?ncrono.  Quando  ativada  (n?vel  l?gico  baixo),  todos  os  bits  dos 
		--registradores dever?o ser zerados. Esta entrada tem prefer?ncia sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada de clock para escrita nos registradores. A escrita acontece na borda de subida do clock, desde que habilitada
		stack_in : IN STD_LOGIC_VECTOR(12 DOWNTO 0); --Entrada de dados para a pilha. 
		stack_push : IN STD_LOGIC; --Entrada de habilita??o para colocar valores na pilha. Quando ativada (n?vel l?gico alto), o 
		--valor  presente  na  entrada  stack_in  deve  ser  escrito  no  primeiro  registrador  da  pilha.  Ao 
		--mesmo tempo, o segundo registrador recebe o  conte?do do primeiro, e assim por diante, 
		--at? o oitavo registrador, que recebe o conte?do do s?timo registrador. 
		stack_pop : IN STD_LOGIC;--Entrada de habilita??o para retirar valores da pilha. Quando ativada (n?vel l?gico alto) o 
		--conte?do  do  segundo  registrador  deve  ser  transferido  para  o  primeiro,  o  do  terceiro 
		--registrador  para  a  segundo,  e  assim  por  diante,  at?  o  s?timo  registrador,  que  recebe  o 
		--conte?do do oitavo. Esse, por sua vez, recebe o valor zero (todos os bits iguais a ?0?).
		stack_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0) --Sa?da  correspondente  ?  primeira  posi??o  da  pilha.  Essa  sa?da  est?  sempre  ativa,  n?o 
		--dependendo de habilita??o 
	);
END ENTITY;


ARCHITECTURE arch1 OF Stack IS --para fazer a troca da pilha
	SIGNAL stack_reg0 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg1 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg2 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg3 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg4 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg5 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg6 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL stack_reg7 : STD_LOGIC_VECTOR(12 DOWNTO 0);
BEGIN
PROCESS(nrst, clk_in, stack_push, stack_pop)
	BEGIN
		IF nrst = '0' THEN --reset
			stack_out <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) AND (stack_pop = '1' OR stack_push = '1') THEN
			IF stack_pop = '1' THEN --pop
				stack_out <= stack_reg0;
				stack_reg0 <= stack_reg1;
				stack_reg1 <= stack_reg2;
				stack_reg2 <= stack_reg3;
				stack_reg3 <= stack_reg4;
				stack_reg4 <= stack_reg5;
				stack_reg5 <= stack_reg6;
				stack_reg6 <= stack_reg7;
				stack_reg7 <= "0000000000000";

			ELSIF stack_push = '1'  THEN --push
				stack_reg7 <= stack_reg6;
				stack_reg6 <= stack_reg5;
				stack_reg5 <= stack_reg4;
				stack_reg4 <= stack_reg3;
				stack_reg3 <= stack_reg2;
				stack_reg2 <= stack_reg1;
				stack_reg1 <= stack_reg0;
				stack_reg0 <= stack_in;
			END IF;
		END IF;
	END PROCESS;
END arch1;
