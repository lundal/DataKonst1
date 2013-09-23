--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:47:05 09/23/2013
-- Design Name:   
-- Module Name:   C:/Users/perthol/TDT4255_Exercise_1/tb_proc.vhd
-- Project Name:  TDT4255_Exercise_1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: processor
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

library WORK;
use WORK.MIPS_CONSTANT_PKG.ALL;

ENTITY tb_proc IS
END tb_proc;
 
ARCHITECTURE behavior OF tb_proc IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT processor
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         processor_enable : IN  std_logic;
         imem_address : OUT  std_logic_vector(31 downto 0);
         imem_data_in : IN  std_logic_vector(31 downto 0);
         dmem_data_in : IN  std_logic_vector(31 downto 0);
         dmem_address : OUT  std_logic_vector(31 downto 0);
         dmem_address_wr : OUT  std_logic_vector(31 downto 0);
         dmem_data_out : OUT  std_logic_vector(31 downto 0);
         dmem_write_enable : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal processor_enable : std_logic := '0';
   signal imem_data_in : std_logic_vector(31 downto 0) := (others => '0');
   signal dmem_data_in : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal imem_address : std_logic_vector(31 downto 0);
   signal dmem_address : std_logic_vector(31 downto 0);
   signal dmem_address_wr : std_logic_vector(31 downto 0);
   signal dmem_data_out : std_logic_vector(31 downto 0);
   signal dmem_write_enable : std_logic;

   -- Clock period definitions
   constant clk_period : time := 40 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: processor PORT MAP (
          clk => clk,
          reset => reset,
          processor_enable => processor_enable,
          imem_address => imem_address,
          imem_data_in => imem_data_in,
          dmem_data_in => dmem_data_in,
          dmem_address => dmem_address,
          dmem_address_wr => dmem_address_wr,
          dmem_data_out => dmem_data_out,
          dmem_write_enable => dmem_write_enable
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      
	  -- Reset
	  reset <= '1';
	  processor_enable <= '0';
	  
	  -- Hold reset state
      wait for 100 ns;
      wait for clk_period*10;
      
	  -- Begin!
	  reset <= '0';
	  processor_enable <= '1';
	  
	  -- LW : r1 = 256
	  imem_data_in <= OP_LW & "00000" & "00001" & ZERO16b;
	  dmem_data_in <= ZERO16b & "0000000100000000";
	  
	  wait for clk_period*3;
	  
	  -- LW : r2 = 8
	  imem_data_in <= OP_LW & "00000" & "00010" & ZERO16b;
	  dmem_data_in <= ZERO16b & "0000000000001000";
	  
	  wait for clk_period*3;
	  
	  -- OR : r3 = r1 | r2
	  imem_data_in <= OP_RRR & "00001" & "00010" & "00011" & "00000" & FUNC_OR;
	  dmem_data_in <= ZERO16b & "0000000000001000";

      wait;
   end process;

END;
