library ieee;
use ieee.std_logic_1164.all;

entity test is 
end entity;

architecture arcTest of test is
        component control_unity
            port(
                --nrst			: IN STD_LOGIC;		
                clk				: IN STD_LOGIC;		
                instr			: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
                --alu_z			: IN STD_LOGIC;

                op_sel 			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
                --bit_sel			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
                -- wr_z_en			: OUT STD_LOGIC;
                -- wr_dc_en		: OUT STD_LOGIC;
                -- wr_c_en			: OUT STD_LOGIC;
                wr_w_reg_en		: OUT STD_LOGIC;
                wr_en			: OUT STD_LOGIC;
                -- rd_en			: OUT STD_LOGIC;
                -- load_pc			: OUT STD_LOGIC;
                -- inc_pc			: OUT STD_LOGIC;
                -- stack_push		: OUT STD_LOGIC;
                -- stack_pop		: OUT STD_LOGIC;
                lit_sel			: OUT STD_LOGIC
            );
            end component;

            signal clk, lit_sel, wr_w_reg_en, wr_en: std_ulogic;
            signal instr : STD_LOGIC_VECTOR(13 DOWNTO 0);
            signal op_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);

            begin 
                qlqrcoisa: control_unity port map(  clk => clk, instr => instr, lit_sel => lit_sel, wr_en => wr_en, wr_w_reg_en => wr_w_reg_en, op_sel => op_sel  );
            
            process begin
                clk <= '0';
                instr <= "--------------";
                wait for 1 ns;
                clk <= '1';
                wait for 1 ns;
                clk <= '0';
                wait for 1 ns;
                clk <= '1';
                wait for 1 ns;
                clk <= '0';
                wait for 1 ns;
                clk <= '1';
                wait for 1 ns;
                clk <= '0';
                wait for 1 ns;


                instr <= "00000000000000";
                wait for 1 ns;

                clk <= '1';
                instr <= "00011100000000";
                wait for 1 ns;

                clk <= '0';
                instr <= "00011100000000";
                wait for 1 ns;

                assert false report "fim do teste";
                wait;
 
            end process;
end arcTest;