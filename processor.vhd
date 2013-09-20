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
	generic  (
		MEM_ADDR_BUS	: integer	:= 32;
		MEM_DATA_BUS	: integer	:= 32
	);
	Port ( 
		clk					: in STD_LOGIC;
		reset				: in STD_LOGIC;
		processor_enable	: in  STD_LOGIC;
		imem_address 		: out  STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		imem_data_in 		: in  STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_data_in 		: in  STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_address 		: out  STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		dmem_address_wr		: out  STD_LOGIC_VECTOR (MEM_ADDR_BUS-1 downto 0);
		dmem_data_out		: out  STD_LOGIC_VECTOR (MEM_DATA_BUS-1 downto 0);
		dmem_write_enable	: out  STD_LOGIC
	);
	
	constant STATE_FETCH	: STD_LOGIC_VECTOR(1 downto 0) := "01";
	constant STATE_EXECUTE	: STD_LOGIC_VECTOR(1 downto 0) := "10";
	constant STATE_STALL	: STD_LOGIC_VECTOR(1 downto 0) := "11";
	
end processor;

architecture Behavioral of processor is
	
	signal state : STD_LOGIC_VECTOR(1 downto 0);
	signal pc : STD_LOGIC_VECTOR(31 downto 0);
	
begin

	STATE_CHANGER : process (clk, reset)
	begin
		if reset = '1' then
			-- reset something?
			state <= STATE_FETCH;
		elsif rising_edge(clk) then
			if state = STATE_FETCH then
				state <= STATE_EXECUTE;
			elsif state = STATE_EXECUTE then
				-- if memory then
				-- state <= STATE_STALL;
				-- else
				state <= STATE_FETCH;
				-- end if;
			else
				state <= STATE_FETCH;
			end if;
		end if;
	end process STATE_CHANGER;
	
	imem_address <= pc;
	
end Behavioral;

