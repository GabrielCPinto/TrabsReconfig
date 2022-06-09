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
	CONSTANT ULA_PASS_A   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1110";
	CONSTANT ULA_PASS_B   : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1111";

	--------------MAQUINA DE ESTADOS------------------------------
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
		lit_sel 	<= '0';		--entrada a da ula, 0 => ula, 1 => ROM (MUX) LITERAL
		next_state <= fet_dec_ex; --Proximo estado
		

		CASE pres_state IS
			WHEN rst =>
				next_state <= fetch_only;
			WHEN fetch_only =>
				next_state <= fet_dec_ex;
				inc_pc <= '1';
				wr_en <= '1'; --Habilitar escrita do registrador de instruções;
			WHEN fet_dec_ex =>

	-----------------------------------------------------
	--        //* 1- ADDWF => Add W and f
	-----------------------------------------------------
			IF instr(13 DOWNTO 8) = ADDWF THEN
				rd_en <= '1';
				op_sel <= ULA_ADD;

				wr_dc_en <= '1';
				wr_z_en <= '1';
				wr_c_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;

	-----------------------------------------------------
	--        //* 2- ANDWF => AND W with f
	-----------------------------------------------------	
			ELSIF instr(13 DOWNTO 8) = ANDWF THEN
				rd_en <= '1';
				op_sel <= ULA_AND;

				wr_z_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;

	-----------------------------------------------------
	--        //* 3- CLRF => Clear f
	-----------------------------------------------------
			ELSIF instr(13 DOWNTO 7) = CLRF THEN
				op_sel <= ULA_CLR;
				wr_en <= '1';
				wr_z_en <= '1';

	-----------------------------------------------------
	--        //* 4- CLRW => Clear W
	-----------------------------------------------------
			ELSIF instr(13 DOWNTO 7) = CLRW THEN
				op_sel <= ULA_CLR;
				wr_z_en <= '1';

	-----------------------------------------------------
	--        //* 5- COMF => Complement f
	-----------------------------------------------------
			ELSIF instr(13 DOWNTO 8) = COMF THEN
				rd_en <= '1';
				op_sel <= ULA_COM;
				wr_z_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;


	-----------------------------------------------------
	--        //* 6- DECF => Decrement f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = DECF THEN
				rd_en <= '1';
				op_sel <= ULA_DEC;
				wr_z_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 7- DECFSZ => Decrement f, Skip if 0
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = DECFSZ THEN
				rd_en <= '1';
				op_sel <= ULA_DEC;
				wr_z_en <= '1';
			
				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
			
				IF alu_z = '1' THEN
					next_state <= fetch_only;
					load_pc <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 8- INCF => Increment f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = INCF THEN
				rd_en <= '1';
				op_sel <= ULA_INC;
				wr_z_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 9- INCFSZ => Increment f, Skip if 0
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = INCFSZ THEN
				rd_en <= '1';
				op_sel <= ULA_INC;
				wr_z_en <= '1';
				
				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;

				IF alu_z = '1' THEN
					next_state <= fetch_only;
					load_pc <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 10- IORLW => Inclusive OR Literal with W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = IORWF THEN
				rd_en <= '1';
				op_sel <= ULA_OR;
				wr_z_en <= '1';
	-----------------------------------------------------
	--        //* 11- MOVF => Move f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = MOVF THEN
				op_sel <= ULA_PASS_A;
				wr_z_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 12- MOVWF => Move W to f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 7) = MOVWF THEN
				lit_sel <= '1';
				op_sel <= ULA_PASS_B;
				wr_en <= '1';
	-----------------------------------------------------
	--        //* 13- NOP => No Operation
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 0) = NOP THEN
				--Consumo de ciclo de clock
	-----------------------------------------------------
	--        //* 14- RLF => Rotate Left f through Carry
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = RLF THEN
				rd_en <= '1';
				op_sel <= ULA_RL;
				wr_c_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 15- RRF => Rotate Right f through Carry
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = RRF THEN
				rd_en <= '1';
				op_sel <= ULA_RR;
				wr_c_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 16- SUBWF => Subtract W from f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = SUBWF THEN
				rd_en <= '1';
				op_sel <= ULA_SUB;
				wr_c_en <= '1';
				wr_dc_en <= '1';
				wr_z_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 17- SWAPF => Swap Nibbles in f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = SWAPF THEN
				rd_en <= '1';
				op_sel <= ULA_SWAP;
				wr_c_en <= '1';

				IF instr(7) = '0' THEN wr_w_reg_en <= '1';
				ELSE wr_en <= '1';
				END IF;
	-----------------------------------------------------
	--        //* 18- XORWF => Exclusive OR Literal with W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = XORWF THEN
				rd_en <= '1';
				lit_sel <= '1';
				op_sel <= ULA_XOR;
				wr_z_en <= '1';
				
	-----------------------------------------------------
	--        //* 19- BCF => Bit Clear f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 9) = BCF THEN
				rd_en <= '1';
				bit_sel <=  instr(9 DOWNTO 7);
				op_sel <= ULA_BC;
				wr_en <= '1';
	-----------------------------------------------------
	--        //* 20- BSF => Bit Set f
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 9) = BSF THEN
				rd_en <= '1';
				op_sel <= ULA_RR;
				bit_sel <= instr(9 DOWNTO 7);
				wr_en <= '1';
	-----------------------------------------------------
	--        //* 21- BTFSC =>  Bit Test f, Skip if Clear
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 9) = BTFSC THEN
				rd_en <= '1';
				bit_sel <=  instr(9 DOWNTO 7);
				op_sel <= ULA_BS;

				IF alu_z = '0' THEN
					next_state <= fetch_only;
				END IF;
	-----------------------------------------------------
	--        //* 22- BTFSS => Bit Test f, Skip if Set
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 9) = BTFSS THEN
				rd_en <= '1';
				bit_sel <=  instr(9 DOWNTO 7);
				op_sel <= ULA_BS;

				IF alu_z = '1' THEN
					next_state <= fetch_only;
				END IF;
	-----------------------------------------------------
	--        //* 23- ADDLW => Add Literal and W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = ADDLW THEN
				lit_sel <= '1';
				op_sel <= ULA_ADD;
				wr_w_reg_en <= '1';
	-----------------------------------------------------
	--        //* 24- ANDLW => AND Literal with W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = ANDLW THEN
				lit_sel <= '1';
				op_sel <= ULA_AND;
				wr_w_reg_en <= '1';
	-----------------------------------------------------
	--        //* 25- CALL => Call Subroutine
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = CALL THEN
				stack_push <= '1';
				lit_sel <= '1';
				op_sel <= ULA_PASS_A;
				load_pc <= '1';
				inc_pc <= '0';
				next_state <= fetch_only;
	-----------------------------------------------------
	--        //* 26- CLRWDT => No Operation
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = CLRWDT THEN
				--NOP
	-----------------------------------------------------
	--        //* 27- GOTO => Unconditional Branch
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = GOTO THEN
				lit_sel <= '1';
				op_sel <= ULA_PASS_A;
				load_pc <= '1';
				inc_pc <= '0';
				next_state <= fetch_only;
	-----------------------------------------------------
	--        //* 28- IORLW =>  Inclusive OR Literal with W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = IORLW THEN
				lit_sel <= '1';
				op_sel <= ULA_OR;
				wr_w_reg_en <= '1';
	-----------------------------------------------------
	--        //* 29- MOVLW => Move Literal to W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = MOVLW THEN
				lit_sel <= '1';
				op_sel <= ULA_PASS_A;
				wr_w_reg_en <= '1';
	-----------------------------------------------------
	--        //* 30- RETFIE => No Operation
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = RETFIE THEN
				--NOP
	-----------------------------------------------------
	--        //* 31- RETLW => Return from Interrupt
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = RETLW THEN
				lit_sel <= '1';
				op_sel <= ULA_PASS_A;
				wr_w_reg_en <= '1';
				stack_pop <= '1';
				load_pc <= '1';
				inc_pc <= '0';
				next_state <= fetch_only;
	-----------------------------------------------------
	--        //* 32- RETURN => Return from Subroutine
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = RET_URN THEN
				stack_pop <= '1';
				load_pc <= '1';
				next_state <= fetch_only;
	-----------------------------------------------------
	--        //* 33- SLEEP => No Operation
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = SLEEP THEN
				--NOP
	-----------------------------------------------------
	--        //* 34- SUBLW => Subtract W from Literal
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = SUBLW THEN
				lit_sel <= '1';
				op_sel <= ULA_SUB;
				wr_w_reg_en <= '1';
				wr_c_en <= '1';
				wr_dc_en <= '1';
				wr_z_en <= '1';
	-----------------------------------------------------
	--        //* 35- XORLW => Exclusive OR Literal with W
	-----------------------------------------------------
				ELSIF instr(13 DOWNTO 8) = XORLW THEN
				lit_sel <= '1';
				op_sel <= ULA_XOR;
				wr_w_reg_en <= '1';
				wr_z_en <= '1';
			END IF;
		END CASE;
	END PROCESS;

END arch1;


