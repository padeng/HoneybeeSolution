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

entity tb_abs is
--  Port ( );
end tb_abs;

architecture Behavioral of tb_abs is
    signal clock : std_logic := '0';
    signal data_in : std_logic_vector(9 downto 0) := (others => '0');
    signal data_out : std_logic_vector(9 downto 0);    
    
    signal counter : integer := 0;
    signal iterate_stim : std_logic := '0';

    signal data_int : integer := 0;
begin
    -- Reset and clock
    clock <= not clock after 1 ns;
    -- reset <= '1', '0' after 5 ns;

    abs_uut : entity work.AbsoluteValue(rtl)
    port map(
        I    => data_in,
        ABSi => data_out
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
            data_in <= std_logic_vector(to_unsigned(data_int, 10));
        end if;
    end process;
    

end Behavioral;
