LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Pilha IS
	PORT (
		nrst, clk_in : IN STD_LOGIC;
		stack_in : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		stack_push, stack_pop : IN STD_LOGIC;
		stack_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END ENTITY;


ARCHITECTURE stack OF Pilha IS
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
		IF nrst = '0' THEN
			stack_out <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) AND (stack_pop = '1' OR stack_push = '1') THEN
			IF stack_pop = '1' AND stack_push = '1'  THEN
				stack_out <= stack_reg0;
				stack_reg0 <= stack_reg1;
				stack_reg1 <= stack_reg2;
				stack_reg2 <= stack_reg3;
				stack_reg3 <= stack_reg4;
				stack_reg4 <= stack_reg5;
				stack_reg5 <= stack_reg6;
				stack_reg6 <= stack_reg7;
				stack_reg7 <= "0000000000000";

			ELSIF stack_push = '1'  THEN
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
END stack;
