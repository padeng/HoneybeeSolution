----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/12/2023 10:56:43 PM
-- Design Name: 
-- Module Name: tb_IMonitor - Behavioral
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

entity tb_DualPWM is
--  Port ( );
end tb_DualPWM;

architecture Behavioral of tb_DualPWM is
    
    constant X : natural := 6;
    constant Y : natural := 6;
    constant Z : natural := 7;
    
    signal clock : std_logic := '0';
    signal data_in1 : std_logic_vector(X-1 downto 0) := (others => '0');
    signal data_in2 : std_logic_vector(Y-1 downto 0) := (others => '0');
    signal PER_in   : std_logic_vector(Z-1 downto 0) := (others => '0');
    signal nreset   : std_logic := '1';
    signal enable   : std_logic;    
    signal PWM1_out, PWM2_out : std_logic;

    signal counter : integer := 0;
    signal iterate_stim : std_logic := '0';

    signal data_int : integer := 0;


begin
    -- Reset and clock
    clock <= not clock after 1 ns;
    nreset <= '0', '1' after 5 ns;
    enable <= '1' after 15 ns;    

    dualPWM_uut : entity work.DualPWM(rtl)
    generic map (
        COMP1_SIZE => X,
        COMP2_SIZE => Y,
        PER_SIZE => Z
    )    
    port map(
        clk     => clock,
        COMP1   => data_in1,
        COMP2   => data_in2,
        PER     => PER_in,
        EN      => enable,
        nRST    => nreset,
        PWM1    => PWM1_out,
        PWM2    => PWM2_out
    );


    counter_proc:
    process (clock) begin
        if rising_edge(clock) then
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
        
    stimulus:
    process (iterate_stim) begin
        if rising_edge(iterate_stim) then
            data_int <= data_int+1;
--            data_in1 <= std_logic_vector(to_unsigned(data_int, X));
 --           data_in2 <= std_logic_vector(to_unsigned(data_int/2 + 100, Y));            
            data_in1 <= std_logic_vector(to_unsigned(50, X));
            data_in2 <= std_logic_vector(to_unsigned(250 + 100, Y));            
            PER_in <= std_logic_vector(to_unsigned(500 + 100, Z));            
        end if;
    end process;
    
end Behavioral;
