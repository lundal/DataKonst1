--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:54:20 05/03/2012
-- Design Name:   
-- Module Name:   E:/My-documents/Dropbox/tdt4255_final/single_cycle/tb_toplevel.vhd
-- Project Name:  single_cycle
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: toplevel
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

ENTITY tb_toplevelfib IS
END tb_toplevelfib;
 
ARCHITECTURE behavior OF tb_toplevelfib IS 
 
  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT toplevel
    PORT(
      clk : IN  std_logic;
      reset : IN  std_logic;
      command : IN  std_logic_vector(0 to 31);
      bus_address_in : IN  std_logic_vector(0 to 31);
      bus_data_in : IN  std_logic_vector(0 to 31);
      status : OUT  std_logic_vector(0 to 31);
      bus_data_out : OUT  std_logic_vector(0 to 31)
     );
   END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal command : std_logic_vector(0 to 31) := (others => '0');
   signal bus_address_in : std_logic_vector(0 to 31) := (others => '0');
   signal bus_data_in : std_logic_vector(0 to 31) := (others => '0');

 	--Outputs
   signal status : std_logic_vector(0 to 31);
   signal bus_data_out : std_logic_vector(0 to 31);

   -- Clock period definitions
   constant clk_period : time := 40 ns;
	
	constant zero : std_logic_vector(0 to 31)  := "00000000000000000000000000000000";
	constant addr1 : std_logic_vector(0 to 31) := "00000000000000000000000000000001";
	constant addr2 : std_logic_vector(0 to 31) := "00000000000000000000000000000010";
	constant addr3 : std_logic_vector(0 to 31) := "00000000000000000000000000000011";
	constant addr4 : std_logic_vector(0 to 31) := "00000000000000000000000000000100";
	constant addr5 : std_logic_vector(0 to 31) := "00000000000000000000000000000101";
	constant addr6 : std_logic_vector(0 to 31) := "00000000000000000000000000000110";
	constant addr7 : std_logic_vector(0 to 31) := "00000000000000000000000000000111";
	constant addr8 : std_logic_vector(0 to 31) := "00000000000000000000000000001000";
	constant addr9 : std_logic_vector(0 to 31) := "00000000000000000000000000001001";
	constant addr10: std_logic_vector(0 to 31) := "00000000000000000000000000001010";
  constant addr11: std_logic_vector(0 to 31) := "00000000000000000000000000001011";
  constant addr12: std_logic_vector(0 to 31) := "00000000000000000000000000001100";
  constant addr13: std_logic_vector(0 to 31) := "00000000000000000000000000001101";
  constant addr14: std_logic_vector(0 to 31) := "00000000000000000000000000001110";
  constant addr15: std_logic_vector(0 to 31) := "00000000000000000000000000001111";
  constant addr16: std_logic_vector(0 to 31) := "00000000000000000000000000010000";

  -- This is written to memory initially
  constant data0 : std_logic_vector(0 to 31):= X"00000000";
  constant data1 : std_logic_vector(0 to 31):= X"00000001";
  constant data2 : std_logic_vector(0 to 31):= X"00000002";
  constant data3 : std_logic_vector(0 to 31):= X"00000000";
  constant data4 : std_logic_vector(0 to 31):= X"00000000";
  constant data5 : std_logic_vector(0 to 31):= X"00000000";
  constant data6 : std_logic_vector(0 to 31):= X"00000000";
  constant data7 : std_logic_vector(0 to 31):= X"00000000";
  constant data8 : std_logic_vector(0 to 31):= X"00000000";
  constant data9 : std_logic_vector(0 to 31):= X"00000000";
  constant data10 : std_logic_vector(0 to 31):= X"00000000";
  constant data11 : std_logic_vector(0 to 31):= X"00000000";
  constant data12 : std_logic_vector(0 to 31):= X"00000000";
  constant data13 : std_logic_vector(0 to 31):= X"00000000";
  constant data14 : std_logic_vector(0 to 31):= X"00000000";
  constant data15 : std_logic_vector(0 to 31):= X"00000010";
  constant data16 : std_logic_vector(0 to 31):= X"00000000";
  
  -- These are the instructions executed by the CPU (loaded to instruction-memory)
  -- See ins.txt for what they actually mean (that is a file used when loading them to the FPGA)
  constant ins0  : std_logic_vector(0 to 31) := X"8c010001";
  constant ins1  : std_logic_vector(0 to 31) := X"8c020002";
  constant ins2  : std_logic_vector(0 to 31) := X"8c03000f";
  constant ins3  : std_logic_vector(0 to 31) := X"00222020";
  constant ins4  : std_logic_vector(0 to 31) := X"00400820";
  constant ins5  : std_logic_vector(0 to 31) := X"00801020";
  constant ins6  : std_logic_vector(0 to 31) := X"0062202a";
  constant ins7  : std_logic_vector(0 to 31) := X"1004fffc";
  constant ins8  : std_logic_vector(0 to 31) := X"ac030010";
  constant ins9  : std_logic_vector(0 to 31) := X"0800000a";
   
  -- Used to control the COM-module
  constant CMD_IDLE	: std_logic_vector(0 to 31) := "00000000000000000000000000000000";
	constant CMD_WI	  : std_logic_vector(0 to 31) := "00000000000000000000000000000001";
	constant CMD_RD	  : std_logic_vector(0 to 31) := "00000000000000000000000000000010";
	constant CMD_WD	  : std_logic_vector(0 to 31) := "00000000000000000000000000000011";
	constant CMD_RUN	: std_logic_vector(0 to 31) := "00000000000000000000000000000100";
	
BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
  uut: toplevel PORT MAP (
    clk => clk,
    reset => reset,
    command => command,
    bus_address_in => bus_address_in,
    bus_data_in => bus_data_in,
    status => status,
    bus_data_out => bus_data_out
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
	
    -- hold reset state for 20 ns.
    wait for 20 ns;	

    -- insert stimulus here 
    
		-- INSTR: WRITE DATA TO DMEM
		command <= CMD_WD;					
    bus_address_in <= addr1;
    bus_data_in <= data1;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;
		
    command <= CMD_WD;					
    bus_address_in <= addr2;
    bus_data_in <= data2;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr3;
    bus_data_in <= data3;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr4;
    bus_data_in <= data4;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr5;
    bus_data_in <= data5;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr6;
    bus_data_in <= data6;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr7;
    bus_data_in <= data7;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr8;
    bus_data_in <= data8;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr9;
    bus_data_in <= data9;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr10;
    bus_data_in <= data10;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr11;
    bus_data_in <= data11;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr12;
    bus_data_in <= data12;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr13;
    bus_data_in <= data13;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr14;
    bus_data_in <= data14;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr15;
    bus_data_in <= data15;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    command <= CMD_WD;					
    bus_address_in <= addr16;
    bus_data_in <= data16;
    wait for clk_period*3;
      
    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;
		
    -- Add instruction 0
		command <= CMD_WI;					
    bus_address_in <= zero;
    bus_data_in <= ins0;
    wait for clk_period*3;

    command <= CMD_IDLE;					
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 1
    command <= CMD_WI;          
    bus_address_in <= addr1;
    bus_data_in <= ins1;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 2
    command <= CMD_WI;          
    bus_address_in <= addr2;
    bus_data_in <= ins2;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 3
    command <= CMD_WI;          
    bus_address_in <= addr3;
    bus_data_in <= ins3;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 4
    command <= CMD_WI;          
    bus_address_in <= addr4;
    bus_data_in <= ins4;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 5
    command <= CMD_WI;          
    bus_address_in <= addr5;
    bus_data_in <= ins5;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 6
    command <= CMD_WI;          
    bus_address_in <= addr6;
    bus_data_in <= ins6;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 7
    command <= CMD_WI;          
    bus_address_in <= addr7;
    bus_data_in <= ins7;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 8
    command <= CMD_WI;          
    bus_address_in <= addr8;
    bus_data_in <= ins8;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;

    -- Add instruction 9
    command <= CMD_WI;          
    bus_address_in <= addr9;
    bus_data_in <= ins9;
    wait for clk_period*3;

    command <= CMD_IDLE;          
    bus_address_in <= zero;
    bus_data_in <= zero;
    wait for clk_period*3;
		
    -- Run CPU!
		command <= CMD_RUN;					
    bus_address_in <= zero;
    bus_data_in <= zero;
		wait for clk_period*100;

    wait;
    
 end process;

END;
