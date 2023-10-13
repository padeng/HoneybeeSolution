-- AbsoluteValue Module
-- for Honeybee
-- Glenn Paden

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AbsoluteValue is
    port (
        --clk     : in std_logic;
        I      : in std_logic_vector(9 downto 0);
        ABSi      : out std_logic_vector(9 downto 0)
    );
end AbsoluteValue;

architecture rtl of AbsoluteValue is

--signal flipI : std_logic_vector(9 downto 0);

begin
    
    abs_Calc_proc : process (I)
    begin
        if I(9) = '1' then        
            ABSi <= std_logic_vector(to_unsigned(to_integer(unsigned( I nand I )) + 1, 10));
        else    
            ABSi <= I;
        end if; 
    end process;

end rtl;