LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY addr_mux IS
	PORT (
		irp_in : IN STD_LOGIC;
		rp_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		dir_addr_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		ind_addr_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		abus_out : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch of addr_mux IS

BEGIN
	WITH dir_addr_in SELECT
		abus_out <= irp_in & ind_addr_in(7 DOWNTO 0) WHEN "0000000",
					rp_in & dir_addr_in(6 DOWNTO 0) WHEN OTHERS;
END arch;