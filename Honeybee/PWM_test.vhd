----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2023 12:06:08 PM
-- Design Name: 
-- Module Name: PWM_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PWM_test is
--  Port ( );
end PWM_test;

architecture Behavioral of PWM_test is
    
    -- params
    constant X : natural := 6;
    constant Y : natural := 6;
    constant Z : natural := 7;
    constant start_inhibit : natural := 1256;

    -- DualPWM inputs    
    signal clk : std_logic := '0';
    signal comp1_in : std_logic_vector(X-1 downto 0) := (others => '0');
    signal comp2_in : std_logic_vector(Y-1 downto 0) := (others => '0');
    signal PER_in   : std_logic_vector(Z-1 downto 0) := (others => '0');
    signal nreset   : std_logic := '1';
    -- DualPWM oututs    
    signal PWM1_out, PWM2_out : std_logic;

    -- IMonitor inputs    
    signal IA : std_logic_vector(9 downto 0) := (others => '0');
    signal IB : std_logic_vector(9 downto 0) := (others => '0');
    signal nreset_imon : std_logic := '1'; --BD shows them seperately
    -- IMonitor outputs    
    signal ninhibit : std_logic;    


    signal counter : integer := 0;
    signal iterate_stim : std_logic := '0';

    signal data_int : integer := 0;


begin
    -- Reset and clock
    clk <= not clk after 1 ns;
    nreset <= '0', '1' after 5 ns;

    dualPWM_uut : entity work.DualPWM(rtl)
    generic map (
        COMP1_SIZE => X,
        COMP2_SIZE => Y,
        PER_SIZE => Z
    )    
    port map(
        clk     => clk,
        COMP1   => comp1_in,
        COMP2   => comp2_in,
        PER     => PER_in,
        EN      => ninhibit,
        nRST    => nreset,
        PWM1    => PWM1_out,
        PWM2    => PWM2_out
    );
    
    imonitor_uut : entity work.iMonitor(rtl)
    port map(
        clk  => clk,
        IA   => IA,
        IB   => IB,
        nRST => nreset_imon,
        nINH => ninhibit       
    );



    counter_proc: -- not really used here but the idea was to check that stimulus made output change before 5 clock cycles
    process (clk) begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = 4 then
                counter <= 0;
                iterate_stim <= '1';
            else 
                counter <= counter + 1;
                iterate_stim <= '0';
            end if;          
        end if;
    end process;
        
    stimulus: -- static stimuli for DualPWM, but here is the process I had envisioned changing stimuli
    process (iterate_stim) begin
        if rising_edge(iterate_stim) then
            data_int <= data_int+1;
            if data_int > start_inhibit then
                IA <= std_logic_vector(to_unsigned((data_int-start_inhibit), 10));
                IB <= std_logic_vector(to_unsigned((data_int-start_inhibit)/2 + 100, 10));            
            else
                IA <= std_logic_vector(to_unsigned((100), 10));
                IB <= std_logic_vector(to_unsigned((100), 10));            
            end if;
            comp1_in <= std_logic_vector(to_unsigned(50, X));
            comp2_in <= std_logic_vector(to_unsigned(250 + 100, Y));            
            PER_in <= std_logic_vector(to_unsigned(500 + 100, Z));            

            -- reset IMon to keep flow
            -- in "real world" this type of fault we would leave hung until dealt with
            if ninhibit = '0' then
                nreset_imon <= '0';
            else 
                nreset_imon <= '1';
            end if;             
        end if;
    end process;
    
end Behavioral;
