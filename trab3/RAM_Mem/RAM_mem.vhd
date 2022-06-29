LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

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

ARCHITECTURE arch OF RAM_mem IS
	TYPE mem80_type IS ARRAY(0 TO 79) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE mem16_type IS ARRAY(0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL mem0, mem1, mem2 : mem80_type;
	SIGNAL mem_com : mem16_type;
	SIGNAL mem80_addr : INTEGER;
	SIGNAL mem16_addr : INTEGER;
BEGIN
PROCESS(nrst, clk_in, abus_in, dbus_in, wr_en, rd_en,
		mem0, mem1, mem2, mem_com, mem80_addr, mem16_addr)
	BEGIN
		--converte os enderecos binarios para intereiros
		--usados na indexacao das memorias
		mem80_addr <= to_integer(unsigned(abus_in));
		mem16_addr <= to_integer(unsigned(abus_in(6 DOWNTO 0)));
		--reset assincrono; bits da memorias zerados
		IF nrst = '0' THEN 
			mem0 <= (OTHERS => (OTHERS => '0'));
			mem1 <= (OTHERS => (OTHERS => '0'));
			mem2 <= (OTHERS => (OTHERS => '0'));
			mem_com <= (OTHERS => (OTHERS => '0'));	
		ELSIF RISING_EDGE(clk_in) AND wr_en = '1' THEN
			--Operacao de escrita nas �reas de mem�ria
			IF (mem80_addr >= 32 AND mem80_addr <= 111) THEN 
				--escrita na memoria0
				mem0(mem80_addr - 32) <= dbus_in;
			ELSIF (mem80_addr >= 160 AND mem80_addr <= 239) THEN 
				--escrita na memoria1
				mem1(mem80_addr - 160) <= dbus_in;
			ELSIF (mem80_addr >= 288 AND mem80_addr <= 367) THEN
				--escrita na memoria2
				mem2(mem80_addr - 288) <= dbus_in; 
			ELSIF (mem16_addr >= 112 AND mem16_addr <= 127) THEN
				--escrita na memoria_com
				mem_com(mem16_addr - 112) <= dbus_in; 
			END IF;			
		END IF;
		--Operacao de Leitura nas �reas de mem�ria
		IF rd_en = '1' AND (mem80_addr >= 32 AND mem80_addr <= 111) THEN
			--leitura na memoria0
			dbus_out <= mem0(mem80_addr - 32);
		ELSIF rd_en = '1' AND (mem80_addr >= 160 AND mem80_addr <= 239) THEN 
			--leitura na memoria1
			dbus_out <= mem1(mem80_addr - 160);
		ELSIF rd_en = '1' AND (mem80_addr >= 288 AND mem80_addr <= 367) THEN
			--leitura na memoria2
			dbus_out <= mem2(mem80_addr - 288); 
		ELSIF rd_en = '1' AND (mem16_addr >= 112 AND mem16_addr <= 127) THEN
			--leitura na memoria_com
			dbus_out <= mem_com(mem16_addr - 112); 
		ELSE --dbus_out em alta imped�ncia
			dbus_out <= ("ZZZZZZZZ");
		END IF;
			
	END PROCESS;
END arch;
