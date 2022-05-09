--É mais ou menos isso aqui. FALTA SEPARAR OS PROCESSES E AS LOGICA COMBINACIONAIS

ARCHITECTURE pc_reg OF Item6 IS
	CONSTANT one : STD_LOGIC_VECTOR(12 DOWNTO 0) := "0000000000001";
BEGIN

--Lógica combinacional para nextpc

--PROCESS(nrst, clk_in) --PROCESS PC_reg
--	BEGIN
--		IF nrst = '0' THEN
--		   nextpc_out <= (OTHERS => '0');
--		   --PC_reg <= (OTHERS => '0');
--		ELSIF RISING_EDGE(clk_in) THEN
--			IF wr_en = '1' THEN
--		       w_out <= d_in;
--			END IF;
--		END IF;
--	END PROCESS;
	
PROCESS(nrst, clk_in) --PROCESS PCLATH
	BEGIN
		IF nrst = '0' THEN
		   stack_out <= (OTHERS => '0');
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
				nextpc_out <= (stack_in + one);
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
	
--Lógica combinacional para dbus_out


END pc_reg
