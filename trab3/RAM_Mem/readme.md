LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RAM_mem IS
PORT (
	nrst : IN STD_LOGIC; --Entrada de reset assíncrono. Quando ativada (nível lógico baixo), todos os bits da memória
--RAM deverão ser zerados. Esta entrada tem preferência sobre todas as outras.
	clk_in : IN STD_LOGIC; --Entrada de clock do sistema. A escrita na memória acontece na borda de subida do clock,
--desde que habilitada.
	wr_en : IN STD_LOGIC; --Entrada de habilitação para escrita na memória. Quando ativada (nível lógico alto), a
--memória será escrita, síncrona com clk_in, com o valor de dbus_in, desde que o endereço correspondente esteja 
--presente em abus_in, conforme especificado no item 3.3. Caso contrário, nenhuma ação será efetuada. 
	rd_en : IN STD_LOGIC; --Entrada de habilitação para leitura. Quando ativada (nível lógico alto), a saída dbus_out
--deverá corresponder ao conteúdo da memória endereçada. Quando desativada ou quando o endereço não corresponder 
--ao especificado no item 3.3, a saída deverá ficar em alta impedância (“ZZZZZZZZ”). 
	abus_in :  IN STD_LOGIC_VECTOR (8 DOWNTO 0); --Entrada de endereçamento. Aponta a célula de memória a ser 
--escrita ou lida, desde que habilitada. As faixas de endereço para cada área de memória estão definidas no item 3.3.
	dbus_in :  IN STD_LOGIC_VECTOR (7 DOWNTO 0); --Entrada de dados para escrita na memória, com habilitação 
--através de wr_en, e endereçamento por abus_in.
	dbus_out :  OUT STD_LOGIC_VECTOR (7 DOWNTO 0) --Barramento de saída de dados, com 8 bits. Habilitação a
--través de rd_en e endereçamento por abus_in. Durante as operações de leitura, comporta-se como saída. 
--Quando não em uso, fica em alta impedância (“ZZZZZZZZ”). A operação de leitura deve ser completamente
--combinacional, ou seja, não depende de transição de clk_in.
);
END ENTITY;

ARCHITECTURE arch1 OF RAM_mem IS
	TYPE memory_type IS ARRAY (0 to 79) OF STD_LOGIC_VECTOR (7 DOWNTO 0); --Array de 80 bytes
	TYPE small_memory_type IS ARRAY (0 DOWNTO 15) OF STD_LOGIC_VECTOR (7 DOWNTO 0);	 --Array 16 bytes
	
	SIGNAL mem0 : memory_type; --Primeira área de memória
	SIGNAL mem1 : memory_type; --Segunda área de memória
	SIGNAL mem2 : memory_type; --Terceira área de memória
	SIGNAL mem_com : small_memory_type; --Quarta área de memória
BEGIN
	PROCESS(nrst, clk_in) 
		BEGIN
		
		IF(nrst = '0') THEN  --Limpa toda área da RAM
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
