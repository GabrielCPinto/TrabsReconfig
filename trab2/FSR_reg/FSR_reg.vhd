LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSR_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  assíncrono.  Quando  ativada  (nível  lógico  baixo),  todos  os  bits  do registrador deverão ser zerados. 
		--Esta entrada tem preferência sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada de clock para escrita no registrador. A escrita acontece na borda de subida do clock, desde que habilitada.
		wr_en : IN STD_LOGIC; --Entrada  de  habilitação  para  escrita  no  registrador.  Quando  ativada  (nível  lógico  alto),  o registrador será escrito, 
		--síncrono com clk_in, com o valor de dbus_in, desde que o endereço correspondente, conforme especificado acima, esteja presente em abus_in. Caso contrário, 
		--nenhuma ação será efetuada.
		rd_en : IN STD_LOGIC; --Entrada  de  habilitação para leitura. Quando  ativada (nível lógico  alto), a  saída  dbus_out deverá  corresponder  ao  conteúdo  do  registrador,
		--desde  que  o  endereço  correspondente, conforme especificado acima, esteja presente em abus_in. Quando desativada ou quando o endereço não corresponder 
		--ao especificado acima, a saída deverá ficar em alta impedância (“ZZZZZZZZ”).  A  operação  de  leitura  deve  ser  completamente  combinacional,  ou  seja, 
		--não depende de transição de clk_in. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endereçamento. O registrador deve ser escrito ou lido quando abus_in[6..0] = “0000100”.
		-- Dessa forma, apenas os 7 bits menos significativos de abus_in devem ser usados. Os outros dois bits não importam.
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  no  registrador,  com  habilitação  através  de  wr_en,  e endereçamento por abus_in.
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Saída  de  dados  lidos  com  habilitação  através  de  rd_en  e  endereçamento  por  abus_in. 
		--Quando não usada, deverá ficar em alta impedância (“ZZZZZZZZ”). 
		fsr_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Saída  correspondente  ao  registrador.  Essa  saída  está  sempre  ativa,  não  dependendo  de habilitação. 
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
