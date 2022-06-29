library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY control_unit IS
	PORT(
		nrst			: IN STD_LOGIC;		--reset	
		clk				: IN STD_LOGIC;		--clock
		instr			: IN STD_LOGIC_VECTOR(13 DOWNTO 0); --numero da instrução
		alu_z			: IN STD_LOGIC;  --flag se a operação deu zero, alu-z = 1

		op_sel 			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --selação de operação da ula
		bit_sel			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	--seleção do bit da operação da ula
		wr_z_en			: OUT STD_LOGIC;
		wr_dc_en		: OUT STD_LOGIC;
		wr_c_en			: OUT STD_LOGIC;
		wr_w_reg_en		: OUT STD_LOGIC;
		wr_en			: OUT STD_LOGIC;
		rd_en			: OUT STD_LOGIC;
		load_pc			: OUT STD_LOGIC;
		inc_pc			: OUT STD_LOGIC;
		stack_push		: OUT STD_LOGIC;
		stack_pop		: OUT STD_LOGIC;
		lit_sel			: OUT STD_LOGIC
	);
END ENTITY;
ARCHITECTURE arch OF control_unit IS
	TYPE STATE_TYPE IS (rst, fetch_only, fetch_dec_ex);
	SIGNAL pres_state : state_type;
	SIGNAL next_state : state_type;
	
	---------------------OP_COD DA ULA----------------------------
	CONSTANT ULA_OP_OR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	CONSTANT ULA_OP_AND  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";	
	CONSTANT ULA_OP_XOR  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010";
	CONSTANT ULA_OP_COM  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ULA_OP_ADD  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ULA_OP_SUB  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ULA_OP_INC  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110";
	CONSTANT ULA_OP_DEC  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0111";
	CONSTANT ULA_OP_CLR  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1000";
	CONSTANT ULA_OP_SWAP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1001";
	CONSTANT ULA_OP_RL   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1010";
	CONSTANT ULA_OP_RR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1011";
	CONSTANT ULA_OP_BC   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	CONSTANT ULA_OP_BS   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1101";
	CONSTANT ULA_OP_PASS_A : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1110";
	CONSTANT ULA_OP_PASS_B : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111";
	
	---------OP_COD BYTE-ORIENTED FILE REGISTER OPERATIONS---------
	CONSTANT ADDWF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0111";
	CONSTANT ANDWF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";	
	CONSTANT CLRR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001"; --CLRF CLRW
	CONSTANT COMF   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1001";
	CONSTANT DECF   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT DECFSZ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1011";
	CONSTANT INCF   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1010";
	CONSTANT INCFSZ : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111";
	CONSTANT IORWF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT MOVF   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1000";
	CONSTANT MOVWF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"; --MOVWF E NOP
	CONSTANT RLF    : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1101";
	CONSTANT RRF    : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	CONSTANT SUBWF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010";
	CONSTANT SWAPF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1110";
	CONSTANT XORWF  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110";
	
	---------OP_COD BIT-ORIENTED FILE REGISTER OPERATIONS---------
	CONSTANT BCF	: STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	CONSTANT BSF    : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
	CONSTANT BTFSC  : STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
	CONSTANT BTFSS  : STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";	
	
BEGIN
	
	PROCESS(nrst, clk)
	BEGIN
		IF nrst = '0' THEN --reset dos registradores
			pres_state <= rst;
		ELSIF RISING_EDGE(clk) THEN
			pres_state <= next_state;
		END IF;
	END PROCESS;
	
	PROCESS(instr, alu_z, pres_state)
	BEGIN
	
		op_sel <= "----";
		bit_sel <= instr(9 DOWNTO 7);
		wr_z_en <= '0'; 
		wr_dc_en <= '0'; 
		wr_c_en <= '0';
		wr_w_reg_en <= '0';
		wr_en <= '0';
		rd_en <= '0';
		load_pc <= '0';
		inc_pc <= '0';
		stack_push  <= '0';
		stack_pop <= '0';
		lit_sel <= '0';	
		
		IF pres_state = rst THEN
			next_state <= fetch_only;
		ELSIF pres_state = fetch_only THEN
			next_state <= fetch_dec_ex;
			inc_pc <= '1';
		ELSE --pres_state = fetch_dec_ex
			next_state <= fetch_dec_ex;
		
			CASE instr(13 DOWNTO 12) IS
				--Byte-Oriented File Register Operations
				WHEN "00" =>
					CASE instr(11 DOWNTO 8) IS
						WHEN ADDWF => --ADDWF
							rd_en <= '1';
							wr_c_en <= '1';
							wr_dc_en <= '1';
							wr_z_en <= '1';						
							op_sel <= ULA_OP_ADD;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
							
						WHEN ANDWF => --ANDWF
							rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_AND;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
								
						WHEN CLRR => --CLRF OR CLRW
							--rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_CLR;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
							
						WHEN COMF => --COMF
							rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_COM;
							IF instr(7) = '0' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
								
						WHEN DECF => --DECF
							rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_DEC;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN DECFSZ => --DECFSZ
							rd_en <= '1';
							inc_pc <= '1';
							op_sel <= ULA_OP_DEC;							
							IF alu_z = '1' THEN
								next_state <= fetch_only;
							END IF;
							IF instr(7) = '1' THEN
								wr_en <= '1';
							ELSE
								wr_w_reg_en <= '1';
							END IF;
						
						WHEN INCF => --INCF
							rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_INC;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN INCFSZ => --INCFSZ
							rd_en <= '1';
							inc_pc <= '1';
							op_sel <= ULA_OP_INC;							
							IF alu_z = '1' THEN
								next_state <= fetch_only;
							END IF;
							IF instr(7) = '1' THEN
								wr_en <= '1';
							ELSE
								wr_w_reg_en <= '1';
							END IF;
						
						WHEN IORWF => --IORWF
							rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_OR;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN MOVF => --MOVF
							rd_en <= '1';
							op_sel <= ULA_OP_PASS_A;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN MOVWF => --MOVWF OR NOP
							rd_en <= '1';
							op_sel <= ULA_OP_PASS_B;
							IF instr(7) = '1' THEN --MOVWF
								wr_en <= '1';
								inc_pc <= '1';							
							ELSE --NOP
								inc_pc <= '1';
							END IF; 
					
						WHEN RLF => --RLF
							rd_en <= '1';
							wr_c_en <= '1';
							op_sel <= ULA_OP_RL;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN RRF => --RRF
							rd_en <= '1';
							wr_c_en <= '1';
							op_sel <= ULA_OP_RR;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN SUBWF => --SUBWF
							rd_en <= '1';
							wr_c_en <= '1';
							wr_dc_en <= '1';
							wr_z_en <= '1';						
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN SWAPF => --SWAPF
							rd_en <= '1';
							op_sel <= ULA_OP_SWAP;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
						
						WHEN XORWF => --XORWF
							rd_en <= '1';
							wr_z_en <= '1';
							op_sel <= ULA_OP_SWAP;
							IF instr(7) = '1' THEN
								wr_en <= '1';
								inc_pc <= '1';
							ELSE
								wr_w_reg_en <= '1';
								inc_pc <= '1';
							END IF;
							
					END CASE;
					
					IF instr(13 DOWNTO 0) = "00000000001000" THEN
						stack_pop <= '1';
						next_state <= fetch_only;
					END IF;					
						
				--BIT-Oriented File Register Operations
				WHEN "01" =>
					CASE instr(11 DOWNTO 10) IS
						WHEN BCF => --BCF
							rd_en <= '1';
							wr_en <= '1';
							op_sel  <= ULA_OP_BC;
							bit_sel <= instr(9 DOWNTO 7);
							inc_pc <= '1';
							
						WHEN BSF => --BSF
							rd_en <= '1';
							wr_en <= '1';
							op_sel <= ULA_OP_BS;
							bit_sel <= instr(9 DOWNTO 7);
							inc_pc <= '1';
							
						WHEN BTFSC => --BTFSC
							rd_en <= '1';
							op_sel <= ULA_OP_BC;
							bit_sel <= instr(9 DOWNTO 7);
							inc_pc <= '1';
							IF alu_z = '0' THEN
								next_state <= fetch_only;
							END IF;		
								
						WHEN BTFSS => --BTFSS
							rd_en <= '1';
							op_sel <= ULA_OP_BS;
							bit_sel <= instr(9 DOWNTO 7);						
							inc_pc <= '1';
							IF alu_z = '1' THEN
								next_state <= fetch_only;
							END IF;
					END CASE;
					
				--Literal and Control Operations
				WHEN "10" =>--Control Operations
					IF instr(11) = '0' THEN --CALL
						load_pc <= '1';
						stack_push <= '1';
						next_state <= fetch_only;
					ELSE --GOTO
						load_pc <= '1';
						next_state <= fetch_only;
					END IF;
					
				WHEN "11" =>--Literal Operations
					IF instr(11 DOWNTO 8) = "1110" OR instr(11 DOWNTO 8) = "1111" THEN
						--ADDLW
						lit_sel <= '1';
						wr_c_en <= '1';					
						wr_dc_en <= '1';
						wr_z_en <= '1';					
						wr_w_reg_en <= '1';
						op_sel <= ULA_OP_ADD;
						inc_pc <= '1';
					ELSIF instr(11 DOWNTO 8) = "1001" THEN
						--ANDLW
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_w_reg_en <= '1';
						op_sel <= ULA_OP_AND;
						inc_pc <= '1';
					ELSIF instr(11 DOWNTO 8) = "1000" THEN
						--IORLW
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_w_reg_en <= '1';
						op_sel <= ULA_OP_OR;
						inc_pc <= '1';
					ELSIF instr(11 DOWNTO 10) = "00" THEN
						--MOVLW
						lit_sel <= '1';
						wr_w_reg_en <= '1';
						op_sel <= ULA_OP_PASS_A;
						inc_pc <= '1';
					ELSIF instr(11 DOWNTO 10) = "00" THEN
						--RETLW
						lit_sel <= '1';
						wr_w_reg_en <= '1';
						stack_pop <= '1';
						op_sel <= ULA_OP_PASS_A;
						next_state <= fetch_only;	
					ELSIF instr(11 DOWNTO 8) = "1100" OR instr(11 DOWNTO 8) = "1101" THEN
						--SUBLW
						lit_sel <= '1';
						wr_c_en <= '1';
						wr_dc_en <= '1';
						wr_z_en <= '1';				
						wr_w_reg_en <= '1';
						op_sel <= ULA_OP_SUB;
						inc_pc <= '1';
					ELSIF instr(11 DOWNTO 8) = "1010" THEN
						--XORLW
						rd_en <= '1';
						lit_sel <= '1';
						wr_z_en <= '1';
						wr_w_reg_en <= '1';
						op_sel <= ULA_OP_XOR;
						inc_pc <= '1';
					END IF;									
			END CASE;
		END IF;
	END PROCESS;
END arch;