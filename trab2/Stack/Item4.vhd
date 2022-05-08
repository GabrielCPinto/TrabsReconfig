LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Item5 IS
	PORT (
		nrst, clk_in : IN STD_LOGIC;
		stack_in : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		stack_push, stack_pop : IN STD_LOGIC;
		stack_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END ENTITY;


ARCHITECTURE stack OF Item5 IS
BEGIN
PROCESS(nrst, clk_in, stack_push, stack_pop)
	BEGIN
		IF nrst = '0' THEN
			stack_out <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk_in) AND (stack_pop = '1' OR stack_push = '1') THEN
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
		END IF;
	END PROCESS;
END stack;
