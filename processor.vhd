----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:09:23 09/20/2013 
-- Design Name: 
-- Module Name:    processor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity processor is
	generic(
		MEM_ADDR_BUS	:	integer	:=	32;
		MEM_DATA_BUS	:	integer	:=	32
	);
	port( 
		clk					:	in	STD_LOGIC;
		reset				:	in	STD_LOGIC;
		processor_enable	:	in	STD_LOGIC;
		imem_address 		:	out	STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		imem_data_in 		:	in	STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_data_in 		:	in	STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_address 		:	out	STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		dmem_address_wr		:	out	STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		dmem_data_out		:	out	STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_write_enable	:	out	STD_LOGIC
	);
	
	-- States
	constant STATE_FETCH	:	STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant STATE_EXECUTE	:	STD_LOGIC_VECTOR(1 downto 0) := "10";
	constant STATE_STALL	:	STD_LOGIC_VECTOR(1 downto 0) := "11";
	
	-- Opcodes
	constant OP_RRR		:	STD_LOGIC_VECTOR(5 downto 0) := "000000";
	constant OP_LW		:	STD_LOGIC_VECTOR(5 downto 0) := "100011";
	constant OP_SW		:	STD_LOGIC_VECTOR(5 downto 0) := "101011";
	constant OP_LUI		:	STD_LOGIC_VECTOR(5 downto 0) := "001111";
	constant OP_J		:	STD_LOGIC_VECTOR(5 downto 0) := "000010";
	constant OP_BEQ		:	STD_LOGIC_VECTOR(5 downto 0) := "000100";
	
	-- Functions
	constant FUNC_ADD	:	STD_LOGIC_VECTOR(5 downto 0) := "100000";
	constant FUNC_SUB	:	STD_LOGIC_VECTOR(5 downto 0) := "100010";
	constant FUNC_AND	:	STD_LOGIC_VECTOR(5 downto 0) := "100100";
	constant FUNC_OR	:	STD_LOGIC_VECTOR(5 downto 0) := "100101";
	constant FUNC_SLT	:	STD_LOGIC_VECTOR(5 downto 0) := "101010";
	
end processor;

architecture Behavioral of processor is

	component register_file is
		port(
			CLK 		:	in	STD_LOGIC;
			RESET		:	in	STD_LOGIC;
			RW			:	in	STD_LOGIC;
			RS_ADDR 	:	in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			RT_ADDR 	:	in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			RD_ADDR 	:	in	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
			WRITE_DATA	:	in	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
			RS			:	out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
			RT			:	out	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0)
		);
	end component;
	
	component alu is
		generic (N: NATURAL := DDATA_BUS);
		port(
			X			:	in STD_LOGIC_VECTOR(N-1 downto 0);
			Y			:	in STD_LOGIC_VECTOR(N-1 downto 0);
			ALU_IN		:	in ALU_INPUT;
			R			:	out STD_LOGIC_VECTOR(N-1 downto 0);
			FLAGS		:	out ALU_FLAGS
		);
	end component;
	
	-- Fun signals
	signal state 		:	STD_LOGIC_VECTOR(1 downto 0);
	signal state_new	:	STD_LOGIC_VECTOR(1 downto 0);
	
	-- Instruction signals
	signal pc 			:	STD_LOGIC_VECTOR(31 downto 0);
	signal instruction	:	STD_LOGIC_VECTOR(31 downto 0);
	signal opcode		:	STD_LOGIC_VECTOR(5 downto 0);
	signal rs			:	STD_LOGIC_VECTOR(4 downto 0);
	signal rt			:	STD_LOGIC_VECTOR(4 downto 0);
	signal rd			:	STD_LOGIC_VECTOR(4 downto 0);
	signal shift		:	STD_LOGIC_VECTOR(5 downto 0);
	signal func			:	STD_LOGIC_VECTOR(5 downto 0);
	signal immedi		:	STD_LOGIC_VECTOR(15 downto 0);
	signal target		:	STD_LOGIC_VECTOR(25 downto 0);
	
	-- Register signals			
	signal reg_rw			:	STD_LOGIC;				
	signal reg_rs_addr 		:	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
	signal reg_rt_addr 		:	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
	signal reg_rd_addr 		:	STD_LOGIC_VECTOR (RADDR_BUS-1 downto 0);
	signal reg_write_data	:	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
	signal reg_rs			:	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
	signal reg_rt			:	STD_LOGIC_VECTOR (DDATA_BUS-1 downto 0);
	
	-- ALU signals
	signal alu_x		:	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
	signal alu_y		:	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
	signal alu_in		:	ALU_INPUT;
	signal alu_r		:	STD_LOGIC_VECTOR(DDATA_BUS-1 downto 0);
	signal alu_flags	:	ALU_FLAGS;
begin

	REG_FILE: register_file
	port map(
		CLK 			=> clk,
		RESET			=> reset,
		RW				=> reg_rw,
		RS_ADDR 		=> reg_rs_addr,
		RT_ADDR 		=> reg_rt_addr,
		RD_ADDR 		=> reg_rd_addr,
		WRITE_DATA		=> reg_write_data,
		RS				=> reg_rs,
		RT				=> reg_rt
	);
	
	ALU: alu
	generic map (N=>DDATA_BUS)
	port map(
		X			=> alu_x,
		Y			=> alu_y,
		ALU_IN		=> alu_in,
		R			=> alu_r,
		FLAGS		=> alu_flags
	);

	PROC : process (clk, reset, state_new)
	begin
		if rising_edge(clk) then
			-- Reset
			if reset = '1' then
				state_new <= STATE_FETCH;
				pc <= ZERO32b;
				
			-- Fetch state
			elsif state = STATE_FETCH then
				
				instruction <= imem_data_in;
				
				-- Next: Execute!
				state_new <= STATE_EXECUTE;
				
			-- Execute state
			elsif state = STATE_EXECUTE then
				
				-- Split!
				opcode	<=	instruction(31 downto 26);
				rs		<=	instruction(25 downto 21);
				rt		<=	instruction(20 downto 16);
				rd		<=	instruction(15 downto 11);
				shift	<=	instruction(10 downto 6);
				func	<=	instruction(5 downto 0);
				immedi	<=	instruction(15 downto 0);
				target	<=	instruction(25 downto 0);
				
				
				-- Decode!
				case opcode is
					when OP_RRR =>
						-- Set up lines
						reg_rs_addr <= rs;
						reg_rt_addr <= rt;
						reg_rd_addr <= rd;
						
						alu_x <= reg_rs;
						alu_y <= reg_rt;
						
						reg_write_data <= alu_r;
						reg_rw <= '1';
						
						-- Set alu function
						case func is
							when others =>
								null;
						end case;
						
					when others =>
						null;
				end case;
				
				-- Compute
				
				-- if memory then
				-- Next: Stall!
				-- state <= STATE_STALL;
				-- else
				-- Next: Fetch!
				state_new <= STATE_FETCH;
				-- end if;
				
			-- Stall state (To give memory some slack)
			elsif state = STATE_STALL then
				-- Next: Fetch!
				state_new <= STATE_FETCH;
				
			-- Something went wrong!
			else
				-- SKY NET RISES!
			end if;
			
			-- Go to next state
			state <= state_new;
		end if;
	end process PROC;
	
end Behavioral;

