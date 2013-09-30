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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

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
	
	-- Instruction signals
	signal pc 			:	STD_LOGIC_VECTOR(31 downto 0);
	signal instruction	:	STD_LOGIC_VECTOR(31 downto 0);
	signal opcode		:	STD_LOGIC_VECTOR(5 downto 0);
	signal rs			:	STD_LOGIC_VECTOR(4 downto 0);
	signal rt			:	STD_LOGIC_VECTOR(4 downto 0);
	signal rd			:	STD_LOGIC_VECTOR(4 downto 0);
	signal shift		:	STD_LOGIC_VECTOR(4 downto 0);
	signal func			:	STD_LOGIC_VECTOR(5 downto 0);
	signal immedi		:	STD_LOGIC_VECTOR(15 downto 0);
	signal target		:	STD_LOGIC_VECTOR(25 downto 0);
	signal immedi_ext	:	STD_LOGIC_VECTOR(31 downto 0);
	signal target_ext	:	STD_LOGIC_VECTOR(31 downto 0);
	
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
	
	-- Control signals
	signal state 		:	STD_LOGIC_VECTOR(1 downto 0);

	signal alu_src		:	STD_LOGIC;
	signal mem_write	:	STD_LOGIC;
	signal mem_to_reg	:	STD_LOGIC;
	signal reg_write	:	STD_LOGIC;
	signal reg_dst		:	STD_LOGIC;
	signal branch		:	STD_LOGIC;
	signal jump			:	STD_LOGIC;

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
	
	ALU_1: alu
	generic map (N=>DDATA_BUS)
	port map(
		X			=> alu_x,
		Y			=> alu_y,
		ALU_IN		=> alu_in,
		R			=> alu_r,
		FLAGS		=> alu_flags
	);

	CONTROL : process (clk, reset)
		constant STATE_FETCH	:	STD_LOGIC_VECTOR(1 downto 0) := "01";
		constant STATE_EXECUTE	:	STD_LOGIC_VECTOR(1 downto 0) := "10";
		constant STATE_STALL	:	STD_LOGIC_VECTOR(1 downto 0) := "11";
	begin
		if rising_edge(clk) then
			-- Reset
			if reset = '1' then
				state <= STATE_FETCH;
				pc <= ZERO32b;
			elsif processor_enable = '0' then
				-- NA
			else
				-- Default advancement of PC
				--pc <= pc + 4;
				
				case state is
					-- Fetch
					when STATE_FETCH =>
						-- Next: Execute!
						state <= STATE_EXECUTE;
						
						-- Get instruction
						instruction <= imem_data_in;
						
						-- Control signals (Are theese needed?)
--						alu_src		<= '0';
--						mem_write	<= '0';
--						mem_to_reg	<= '0';
--						reg_write	<= '0';
--						reg_dst		<= '0';
--						branch		<= '0';
--						jump		<= '0';
					
					-- Execute
					when STATE_EXECUTE =>
						-- Next: Fetch!
						state <= STATE_FETCH;
						
						case opcode is
							-- Tripple register operation
							when OP_RRR =>
								-- Control signals
								alu_src		<= '0';
								mem_write	<= '0';
								mem_to_reg	<= '0';
								reg_write	<= '1';
								reg_dst		<= '1';
								branch		<= '0';
								jump		<= '0';
								
								-- ALU function
								case func is
									when FUNC_ADD =>
										alu_in.Op3	<=	'0';
										alu_in.Op2	<=	'0';
										alu_in.Op1	<=	'1';
										alu_in.Op0	<=	'0';
									when FUNC_SUB =>
										alu_in.Op3	<= '0';
										alu_in.Op2	<= '1';
										alu_in.Op1	<= '1';
										alu_in.Op0	<= '0';
									when FUNC_AND =>
										alu_in.Op3	<=	'0';
										alu_in.Op2	<=	'0';
										alu_in.Op1	<=	'0';
										alu_in.Op0	<=	'0';
									when FUNC_OR =>
										alu_in.Op3	<=	'0';
										alu_in.Op2	<=	'0';
										alu_in.Op1	<=	'0';
										alu_in.Op0	<=	'1';
									when FUNC_SLT =>
										alu_in.Op3	<=	'0';
										alu_in.Op2	<=	'0';
										alu_in.Op1	<=	'1';
										alu_in.Op0	<=	'1';
									when others =>
										null;
								end case;
							
							-- Load word ($t = MEM[$s + offset])
							when OP_LW =>
								-- Control signals
								alu_src		<= '1';
								mem_write	<= '0';
								mem_to_reg	<= '1';
								reg_write	<= '1';
								reg_dst		<= '0';
								branch		<= '0';
								jump		<= '0';
								
								-- ALU function: Add
								alu_in.Op3	<=	'0';
								alu_in.Op2	<=	'0';
								alu_in.Op1	<=	'1';
								alu_in.Op0	<=	'0';
								
								-- This one is a bit slow
								state <= STATE_STALL;
							
							-- Store word (MEM[$s + offset] = $t)
							when OP_SW =>
								-- Control signals
								alu_src		<= '1';
								mem_write	<= '1';
								mem_to_reg	<= '0';
								reg_write	<= '0';
								reg_dst		<= '0';
								branch		<= '0';
								jump		<= '0';
								
								-- ALU function: Add
								alu_in.Op3	<=	'0';
								alu_in.Op2	<=	'0';
								alu_in.Op1	<=	'1';
								alu_in.Op0	<=	'0';
							
							when OP_LUI =>
								-- Control signals
								alu_src		<= '1';
								mem_write	<= '0';
								mem_to_reg	<= '0';
								reg_write	<= '1';
								reg_dst		<= '0';
								branch		<= '0';
								jump		<= '0';
								
								-- ALU function: Shift 16
								alu_in.Op3	<=	'1';
								alu_in.Op2	<=	'0';
								alu_in.Op1	<=	'0';
								alu_in.Op0	<=	'0';
							
							when others =>
								null;
						end case;
					
					-- Stall (To give memory some slack)
					when STATE_STALL =>
						-- Next: Fetch!
						state <= STATE_FETCH;
						
					-- Something went wrong!
					when others =>
						-- SKY NET RISES!
						state <= STATE_FETCH;
				end case;
				
			end if;
		end if;
	end process;
	
	-- Split instruction
	opcode	<= instruction(31 downto 26);
	rs		<= instruction(25 downto 21);
	rt		<= instruction(20 downto 16);
	rd		<= instruction(15 downto 11);
	shift	<= instruction(10 downto 6);
	func	<= instruction(5 downto 0);
	immedi	<= instruction(15 downto 0);
	target	<= instruction(25 downto 0);
	
	-- Register File Inputs
	reg_rs_addr		<= rs;
	reg_rt_addr		<= rt;
	reg_rd_addr		<= rd when reg_dst = '1' else rt; -- RegDst Mux
	reg_write_data	<= dmem_data_in when mem_to_reg = '1' else alu_r; -- MemToReg Mux
	reg_rw			<= reg_write;
	
	-- ALU Inputs (TODO: FUNC)
	alu_x	<= reg_rs;
	alu_y	<= immedi_ext when alu_src = '1' else reg_rt; -- ALUSrc Mux
	
	-- Data Memory Inputs
	dmem_address		<= alu_r;
	dmem_address_wr		<= alu_r;
	dmem_write_enable	<= mem_write;
	dmem_data_out		<= reg_rt;
	
	-- Immediate Sign Extension
	immedi_ext <= ZERO16b & immedi when immedi(15) = '0' else ONE16b & immedi;
	
	-- Target Concatenation
	target_ext <= pc(31 downto 28) & target & "00";
	
end Behavioral;

