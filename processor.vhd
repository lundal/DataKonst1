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
	
	component adder is
		generic (N: natural := MEM_DATA_BUS);    
		port(
			X		:	in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y		:	in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN		:	in	STD_LOGIC;
			COUT	:	out	STD_LOGIC;
			R		:	out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component;
	
	-- Instruction signals
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
	signal state_next	:	STD_LOGIC_VECTOR(1 downto 0);
	signal alu_src		:	STD_LOGIC := '0';
	signal mem_write	:	STD_LOGIC := '0';
	signal mem_to_reg	:	STD_LOGIC := '0';
	signal reg_write	:	STD_LOGIC := '0';
	signal reg_dst		:	STD_LOGIC := '0';
	signal branch		:	STD_LOGIC := '0';
	signal jump			:	STD_LOGIC := '0';
	
	-- PC signals
	signal pc 			:	STD_LOGIC_VECTOR(MEM_ADDR_BUS-3 downto 0) := (others => '1');
	signal pc_1 		:	STD_LOGIC_VECTOR(MEM_ADDR_BUS-3 downto 0);
	signal pc_jump		:	STD_LOGIC_VECTOR(MEM_ADDR_BUS-3 downto 0);
	signal pc_branch	:	STD_LOGIC_VECTOR(MEM_ADDR_BUS-3 downto 0);
	signal pc_next		:	STD_LOGIC_VECTOR(MEM_ADDR_BUS-3 downto 0);
	
	-- States
	constant STATE_FETCH	:	STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant STATE_EXECUTE	:	STD_LOGIC_VECTOR(1 downto 0) := "10";
	constant STATE_STALL	:	STD_LOGIC_VECTOR(1 downto 0) := "11";
	
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
	
	ALU_THE: alu
	generic map (N=>DDATA_BUS)
	port map(
		X			=> alu_x,
		Y			=> alu_y,
		ALU_IN		=> alu_in,
		R			=> alu_r,
		FLAGS		=> alu_flags
	);
	
	ADDER_PC_1: adder
	generic map (N=>MEM_DATA_BUS-2)
	port map(
		X		=> pc,
		Y		=> (others => '0'),
		CIN		=> '1',
		R		=> pc_1
	);
	
	ADDER_PC_BRANCH: adder
	generic map (N=>MEM_DATA_BUS-2)
	port map(
		X		=> pc,
		Y		=> immedi_ext(MEM_DATA_BUS-3 downto 0),
		CIN		=> '0',
		R		=> pc_branch
	);
	
	CONTROL : process (clk, reset)
	begin
		if rising_edge(clk) then
			-- Reset
			if reset = '1' then
				state <= STATE_FETCH;
				pc <= (others => '0');
			elsif processor_enable = '0' then
				-- NA
			else
				case state is
					-- Fetch
					when STATE_FETCH =>
						-- Fetch that instruction!
						instruction <= imem_data_in;
						
						-- Update PC
						pc <= pc_next;
						
						-- Next: Execute!
						state <= STATE_EXECUTE;
					
					-- Execute
					when STATE_EXECUTE =>
						-- Let stuff decode and execute!
						
						-- Next: Fetch! (or possibly stall)
						state <= state_next;
					
					-- Stall
					when STATE_STALL =>
						-- Give memory some slack!
						
						-- Next: Fetch!
						state <= STATE_FETCH;
					
					-- Something went wrong!
					when others =>
						-- SKY NET RISES!
						
						-- Next: Fetch!
						state <= STATE_FETCH;
				end case;
				
			end if;
		end if;
	end process;
	
	SPLITTER : process (instruction)
	begin
		-- Split Instruction From IMEM
		opcode	<= instruction(31 downto 26);
		rs		<= instruction(25 downto 21);
		rt		<= instruction(20 downto 16);
		rd		<= instruction(15 downto 11);
		shift	<= instruction(10 downto 6);
		func	<= instruction(5 downto 0);
		immedi	<= instruction(15 downto 0);
		target	<= instruction(25 downto 0);
	end process;
	
	DECODER : process (opcode, func)
	begin
		-- Reset Control signals
		alu_src		<= '0';
		mem_write	<= '0';
		mem_to_reg	<= '0';
		reg_write	<= '0';
		reg_dst		<= '0';
		branch		<= '0';
		jump		<= '0';
		
		-- Reset ALU function
		alu_in.Op3	<=	'0';
		alu_in.Op2	<=	'0';
		alu_in.Op1	<=	'0';
		alu_in.Op0	<=	'0';
		
		-- Next state (after execute)
		state_next <= STATE_FETCH;
		
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
				
				-- Give it some slack
				state_next <= STATE_STALL;
			
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
			
			-- Load upper immediate 
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
			
			-- Jump
			when OP_J =>
				-- Control signals
				alu_src		<= '0';
				mem_write	<= '0';
				mem_to_reg	<= '0';
				reg_write	<= '0';
				reg_dst		<= '0';
				branch		<= '0';
				jump		<= '1';
				
				-- ALU function: Don't care
				alu_in.Op3	<=	'0';
				alu_in.Op2	<=	'0';
				alu_in.Op1	<=	'0';
				alu_in.Op0	<=	'0';
			
			-- Branch if equal
			when OP_BEQ =>
				-- Control signals
				alu_src		<= '0';
				mem_write	<= '0';
				mem_to_reg	<= '0';
				reg_write	<= '0';
				reg_dst		<= '0';
				branch		<= '1';
				jump		<= '0';
				
				-- ALU function: Sub
				alu_in.Op3	<=	'0';
				alu_in.Op2	<=	'1';
				alu_in.Op1	<=	'1';
				alu_in.Op0	<=	'0';
			
			when others =>
				null;
		end case;
	end process;
	
	PC_CHOOSER : process(pc_1, pc_jump, pc_branch, jump, branch, alu_flags)
	begin
		if jump = '1' then
			pc_next <= pc_jump;
		elsif branch = '1' and alu_flags.Zero = '1' then
			pc_next <= pc_branch;
		else
			pc_next <= pc_1;
		end if;
	end process;
	
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
	
	-- Jump Target Concatenation
	pc_jump <= pc(29 downto 26) & target;
	
	-- Send PC to IMEM
	imem_address <= "00" & pc_next;
	
end Behavioral;

