LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-------------------------------------------------------
ENTITY w_reg IS
PORT (
nclr : IN STD_LOGIC;
clk : IN STD_LOGIC;
nce : IN STD_LOGIC;
r_nw : IN STD_LOGIC;
addr : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
dio : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE arch1 OF w_reg IS
TYPE mem_type IS ARRAY(0 TO 31) OF
STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL mem_reg : mem_type;
SIGNAL addr_int : INTEGER RANGE 0 TO 31;
BEGIN
----------- Conversão:
addr_int <= TO_INTEGER(UNSIGNED(addr));


----------- Escrita:
PROCESS(nclr, clk)
BEGIN
IF nclr = '0' THEN
mem_reg <= (OTHERS => (OTHERS => '0'));
ELSIF RISING_EDGE(clk) THEN
IF nce = '0' AND r_nw = '0' THEN
mem_reg(addr_int) <= dio;
END IF;
END IF;
END PROCESS;

----------- Leitura:
dio <= mem_reg(addr_int)
WHEN nce = '0' AND r_nw = '1' ELSE
(OTHERS => 'Z');
END arch1;
