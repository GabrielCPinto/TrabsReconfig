LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-------------------------------------------------------
ENTITY w_reg IS
PORT (
nrst : IN STD_LOGIC;
clk_in : IN STD_LOGIC;
wr_en : IN STD_LOGIC;
d_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
w_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE arch1 OF w_reg IS
BEGIN
PROCESS(nrst, clk_in, wr_en, d_in)
BEGIN
IF nrst = '0' THEN
w_out <= (OTHERS => '0');
ELSIF RISING_EDGE(clk_in) AND wr_en = '1' THEN
w_out <= d_in;
END IF;
END PROCESS;
END arch1;
