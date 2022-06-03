LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Status_reg IS
	PORT (
		nrst : IN STD_LOGIC; --Entrada  de  reset  assíncrono.  Quando  ativada  (nível  lógico  baixo),  todos  os  bits  do registrador deverão ser zerados. 
		--Esta entrada tem preferência sobre todas as outras.
		clk_in : IN STD_LOGIC; --Entrada de clock para escrita no registrador. A escrita em todos os registradores acontece na borda de subida do clock, desde que habilitada. 
		wr_en : IN STD_LOGIC; --Entrada  de  habilitação  para  escrita  no  registrador.  Quando  ativada  (nível  lógico  alto),  o 
		--registrador será escrito, síncrono com clk_in, com o valor de dbus_in, desde que o endereço 
		--correspondente, conforme especificado acima, esteja presente em abus_in. Caso contrário, nenhuma ação será efetuada.
		rd_en : IN STD_LOGIC; --Entrada  de  habilitação para leitura. Quando  ativada (nível lógico  alto), a  saída  dbus_out 
		--deverá  corresponder  ao  conteúdo  do  registrador,  exceto  os  bits  4  e  3,  que  deverão  ser 
		--sempre lidos como ‘1’. Quando desativada ou quando o endereço  não  corresponder  ao 
		--especificado acima, a saída deverá ficar em alta impedância (“ZZZZZZZZ”).
		z_in : IN STD_LOGIC; --Entrada de dado para escrita no bit 2 do registrador, com habilitação através de z_wr_en.
		dc_in : IN STD_LOGIC; --Entrada de dado para escrita no bit 1 do registrador, com habilitação através de dc_wr_en.
		c_in : IN STD_LOGIC; --Entrada de dado para escrita no bit 0 do registrador, com habilitação através de c_wr_en.
		z_wr_en : IN STD_LOGIC; --Entrada  para  habilitação  da escrita  no bit 2 do registrador. Quando ativada (nível lógico alto),
		-- o bit 2 do registrador será escrito, síncrono com clk_in, com o valor de z_in. Essa entrada tem preferência sobre wr_en.
		dc_wr_en : IN STD_LOGIC; --Entrada  para  habilitação  da escrita  no bit 1 do registrador. Quando ativada (nível lógico alto),
		-- o bit 1 do registrador será escrito, síncrono com clk_in, com o valor de dc_in. Essa entrada tem preferência sobre wr_en. 
		c_wr_en : IN STD_LOGIC; --Entrada  para  habilitação  da escrita  no bit 0 do registrador. Quando ativada (nível lógico alto),
		-- o bit 0 do registrador  será escrito, síncrono com clk_in, com o valor de c_in. Essa entrada tem preferência sobre wr_en. 
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0); --Entrada de endereçamento. O registrador deve ser escrito ou lido quando abus_in[6..0] = “0000011”. 
		--Dessa forma, apenas os 7 bits menos significativos de abus_in devem ser usados. Os outros dois bits não importam. 
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entrada  de  dados  para  escrita  no  registrador,  com  habilitação  através  de  wr_en,  e endereçamento por abus_in. 
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Saída  de  dados  lidos  com  habilitação  através  de  rd_en  e  endereçamento  por  abus_in. 
		--Quando não usada, deverá ficar em alta impedância (“ZZZZZZZZ”).
		irp_out : OUT STD_LOGIC; --Saída correspondente ao bit 7 do registrador. Essa saída está sempre ativa, não dependendo de habilitação
		z_out : OUT STD_LOGIC; --Saída correspondente ao bit 2 do registrador. Essa saída está sempre ativa, não dependendo de habilitação.
		dc_out : OUT STD_LOGIC; --Saída correspondente ao bit 1 do registrador. Essa saída está sempre ativa, não dependendo de habilitação.
		c_out : OUT STD_LOGIC; --Saída correspondente ao bit 0 do registrador. Essa saída está sempre ativa, não dependendo de habilitação.
		rp_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) --Saída  correspondente  aos  bits  6  e  5  do  registrador.  Essa  saída  está  sempre  ativa,  não dependendo de habilitação.
	
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
