library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY control_unity IS
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

ARCHITECTURE arch1 OF control_unity IS

	------------------ULA CONSTANTES---------------------------
	CONSTANT ULA_OR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	CONSTANT ULA_AND  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0001";	
	CONSTANT ULA_XOR  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0010";
	CONSTANT ULA_COM  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	CONSTANT ULA_ADD  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0100";
	CONSTANT ULA_SUB  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0101";
	CONSTANT ULA_INC  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0110";
	CONSTANT ULA_DEC  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0111";
	CONSTANT ULA_CLR  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1000";
	CONSTANT ULA_SWAP : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1001";
	CONSTANT ULA_RL   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1010";
	CONSTANT ULA_RR   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1011";
	CONSTANT ULA_BC   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	CONSTANT ULA_BS   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1101";

	--------------Maquina de estados------------------------------
	TYPE state_type IS (rst, fetch_only, fet_dec_ex);
	SIGNAL pres_state 	: state_type;	
	SIGNAL next_state 	: state_type;

	---------BYTE-ORIENTED FILE REGISTER OPERATIONS-----------------------
	CONSTANT ADDWF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000111";
	CONSTANT ANDWF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000101";
	CONSTANT CLRF		: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
	CONSTANT CLRW		: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000010";
	CONSTANT COMF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001";
	CONSTANT DECF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000011";
	CONSTANT DECFSZ		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001011";
	CONSTANT INCF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001010";
	CONSTANT INCFSZ		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001111";
	CONSTANT IORWF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
	CONSTANT MOVF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";
	CONSTANT MOVWF		: STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000001";
	CONSTANT NOP		: STD_LOGIC_VECTOR(13 DOWNTO 0):= "00000000000000";
	CONSTANT RLF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001101";
	CONSTANT RRF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100";
	CONSTANT SUBWF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	CONSTANT SWAPF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "001110";
	CONSTANT XORWF		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "000110";

	------BIT-ORIENTED FILE REGISTER OPERATIONS-------------------------
	CONSTANT BCF		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
	CONSTANT BSF		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
	CONSTANT BTFSC		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
	CONSTANT BTFSS		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";

	-------LITERAL AND CONTROL OPERATIONS----------------------------
	CONSTANT ADDLW		: STD_LOGIC_VECTOR(4 DOWNTO 0) := "11111";
	CONSTANT ANDLW		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "111001";
	CONSTANT CALL		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
	CONSTANT CLRWDT		: STD_LOGIC_VECTOR(13 DOWNTO 0):= "00000001100100"; --clear watchdog => nop
	CONSTANT GOTO		: STD_LOGIC_VECTOR(2 DOWNTO 0) := "101";
	CONSTANT IORLW		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "111000";
	CONSTANT MOVLW		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
	CONSTANT RETFIE		: STD_LOGIC_VECTOR(13 DOWNTO 0):= "00000000001001"; --interrupt => nop
	CONSTANT RETLW		: STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
	CONSTANT RET_URN	: STD_LOGIC_VECTOR(13 DOWNTO 0):= "00000000001000";
	CONSTANT SLEEP		: STD_LOGIC_VECTOR(13 DOWNTO 0):= "00000001100011"; --standby => nop
	CONSTANT SUBLW		: STD_LOGIC_VECTOR(4 DOWNTO 0) := "11110";
	CONSTANT XORLW		: STD_LOGIC_VECTOR(5 DOWNTO 0) := "111010";

BEGIN

	------Maquina de estados---------

	PROCESS(nrst,clk)
	BEGIN
		IF nrst = '0' THEN
			pres_state <= rst;
		ELSIF RISING_EDGE(clk) THEN
			pres_state <= next_state;
		END IF;
	END PROCESS;

	PROCESS(nrst, pres_state, instr)
	BEGIN
		op_sel		<= "----";  --Codigo da operação (ULA)
		bit_sel		<= "---";	--bit selecionado para operação (ULA)
		wr_z_en 	<= '0';		-- (Status_reg)
		wr_dc_en 	<= '0';		-- (Status_reg)
		wr_c_en 	<= '0';		-- (Status_reg)
		wr_w_reg_en <= '0';		--escrever registrador w (W_reg)
		wr_en 		<= '0';		--escrever (RAM)
		rd_en 		<= '0';		--ler (RAM)
		load_pc 	<= '0';		--carregar (pc_reg)
		inc_pc 		<= '1';		--incremetar (pc_reg)
		stack_push 	<= '0';		--empilhar (Stack)
		stack_pop 	<= '0';		--desempilhar (Stack)
		lit_sel 	<= '0';		--entrada a da ula, 0 => ula, 1 => ROM (MUX)

		CASE pres_state IS
			WHEN rst =>
				next_state <= fetch_only;
			WHEN fetch_only =>
				next_state <= fet_dec_ex;
				inc_pc <= '1';
				wr_en <= '1'; --Habilitar escrita do registrador de instruções;
			WHEN fet_dec_ex =>


				IF INSTR(13 DOWNTO 8) = ADDWF THEN  --Add W and f
					op_sel <= ULA_ADD;
					IF instr(7) = '0' THEN wr_w_reg_en <= '1';
					ELSE wr_en <= '1';
					END IF;

				-- ELSIF INSTR(13 DOWNTO 8) = ANDWF THEN
				ELSIF INSTR(13 DOWNTO 8) = CLRF THEN --Clear f
					wr_z_en <= '1';
					wr_en <= '1';
					op_sel <= ULA_CLR;

				-- ELSIF INSTR(13 DOWNTO 8) = CLRW THEN
				
				-- ELSIF INSTR(13 DOWNTO 8) = COMF THEN
				-- 	rd_en <= '1';
				-- 	bit_sel <= "0011";
				-- 	IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				-- 	ELSE wr_en <= '1';
				-- 	END IF;
				
				-- -- ELSIF INSTR(13 DOWNTO 8) = DECF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = DECFSZ THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = INCF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = INCFSZ THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = IORWF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = MOVF THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = MOVWF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = NOP THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = RLF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = RRF THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = SUBWF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = SWAPF THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = XORWF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = BCF THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = BSF THEN
				-- ELSIF INSTR(13 DOWNTO 8) = BTFSC THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = BTFSS THEN
				-- ELSIF INSTR(13 DOWNTO 8) = ADDLW THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = ANDLW THEN
				-- ELSIF INSTR(13 DOWNTO 8) = CALL THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = CLRWDT THEN
				-- ELSIF INSTR(13 DOWNTO 8) = GOTO THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = IORLW THEN
				-- ELSIF INSTR(13 DOWNTO 8) = MOVLW THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = RETFIE THEN
				-- ELSIF INSTR(13 DOWNTO 8) = RETLW THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = RET_URN THEN
				-- ELSIF INSTR(13 DOWNTO 8) = SLEEP THEN
				-- -- ELSIF INSTR(13 DOWNTO 8) = SUBLW THEN
				-- ELSIF INSTR(13 DOWNTO 8) = XORLW THEN
				
						
				END IF;
		END CASE;
	END PROCESS;

END arch1;
