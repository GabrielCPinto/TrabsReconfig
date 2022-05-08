--É mais ou menos isso aqui. O caminho é esse

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Item6 IS
	PORT (
		--Entradas e saidas do PC_reg (Item6)
		nrst, clk_in : IN STD_LOGIC;
		addr_in : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		abus_in : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		dbus_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		inc_pc, load_pc : IN STD_LOGIC;
		wr_en, rd_en : IN STD_LOGIC;
		stack_push, stack_pop : IN STD_LOGIC;
		nextpc_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		dbus_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		--Entradas e saidas da Pilha (Item5)
		stack_in : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		stack_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE pc_reg OF Item6 IS
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
			IF abus_in(6 DOWNTO 0) = "0000010" AND wr_en = '1' THEN
				nextpc_out <= (OTHERS => '0');
			END IF;
			IF abus_in(6 DOWNTO 0) = "0001010" AND wr_en = '1' THEN
				dbus_out <= dbus_in;
			END IF;			
		ELSIF inc_pc = '1' THEN
			nextpc_out <= (OTHERS => '0');
		END IF;
	END PROCESS;
	
--Lógica combinacional para dbus_out


END pc_reg;
