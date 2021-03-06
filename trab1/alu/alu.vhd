LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY alu IS
	PORT (
		a_in, b_in: IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Entradas de dados
		c_in : IN STD_LOGIC;
		op_sel  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		bit_sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		r_out  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		c_out  : OUT STD_LOGIC;
		dc_out : OUT STD_LOGIC;
		z_out  : OUT STD_LOGIC
	);
END ENTITY;
	
	
ARCHITECTURE arch OF alu IS
	SIGNAL aux  : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL aux2 : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL aux3 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	CONSTANT zero : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
	CONSTANT one  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001";	
	signal bitsel  : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001";
	CONSTANT OP_OR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	CONSTANT OP_AND  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";	
	CONSTANT OP_XOR  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010";
	CONSTANT OP_COM  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT OP_ADD  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT OP_SUB  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT OP_INC  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110";
	CONSTANT OP_DEC  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0111";
	CONSTANT OP_CLR  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1000";
	CONSTANT OP_SWAP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1001";
	CONSTANT OP_RL   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1010";
	CONSTANT OP_RR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1011";
	CONSTANT OP_BC   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	CONSTANT OP_BS   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1101";
	CONSTANT PASS_A  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1110";
	CONSTANT PASS_B  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111";
	
BEGIN 
	bitsel <= STD_LOGIC_VECTOR(shift_left(unsigned(one), (to_integer(unsigned(bit_sel)))));  
	aux3 <= a_in + bitsel WHEN ((OP_BS = op_sel) AND (a_in(to_integer(unsigned(bit_sel)))) = '0') ELSE
			a_in - bitsel WHEN ((OP_BC = op_sel) AND (a_in(to_integer(unsigned(bit_sel)))) = '1') ELSE
			a_in;
	
	WITH op_sel SELECT
		aux <= '0' & (a_in OR b_in)  WHEN OP_OR, 	--OR
			   '0' & (a_in AND b_in) WHEN OP_AND,	--AND
			   '0' & (a_in XOR b_in) WHEN OP_XOR,	--XOR
			   '0' & (NOT a_in) 	 WHEN OP_COM,	--COM
			   (('0' & a_in) + ('0' & b_in)) WHEN OP_ADD,	--ADD
			   ((('0' & a_in) + (NOT('0' & b_in))) + one) WHEN OP_SUB,	--SUB
			   '0' & (a_in + one) 	 WHEN OP_INC,	--INC
			   '0' & (a_in - one) 	 WHEN OP_DEC,	--DEC
			   '0' & "00000000" 	 WHEN OP_CLR,	--CLR
			   '0' & (a_in(3 DOWNTO 0) & a_in(7 DOWNTO 4)) WHEN OP_SWAP, --SWAP
			   (a_in(7) & a_in(6 DOWNTO 0) & c_in) 	 WHEN OP_RL,   --RL
			   (a_in(0) & c_in & a_in(7 DOWNTO 1)) 	 WHEN OP_RR,   --RR
			   '0' & aux3 WHEN OP_BC, --BC!!!
			   '0' & aux3 WHEN OP_BS, --BS!!!
			   '0' & (a_in) WHEN PASS_A, --PASS_A
			   '0' & (b_in) WHEN PASS_B; --PASS_A
			   
	WITH op_sel SELECT
		aux2   <= (('0' & a_in(3 DOWNTO 0)) + ('0' & b_in(3 DOWNTO 0))) WHEN OP_ADD,
				  (('0' & a_in(3 DOWNTO 0)) + (NOT('0' & b_in(3 DOWNTO 0))) + one(4 DOWNTO 0)) WHEN OP_SUB,		          
				  "00000" WHEN OTHERS;
				   
	r_out  <= aux(7 DOWNTO 0);
	
	WITH op_sel SELECT
		c_out  <= aux(8) WHEN OP_ADD,
				  NOT aux(8) WHEN OP_SUB,
				  a_in(7) WHEN OP_RL,
				  a_in(0) WHEN OP_RR,
				  '0' WHEN OTHERS;			  
	
	WITH op_sel SELECT
		dc_out <= aux2(4) WHEN OP_ADD,
				  NOT aux2(4) WHEN OP_SUB,
				  '0' WHEN OTHERS;
	
	z_out  <= '1' WHEN aux(7 DOWNTO 0) = "00000000" ELSE
			  '0';
END arch;