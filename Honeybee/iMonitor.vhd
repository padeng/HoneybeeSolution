-- IMonitor Module
-- for Honeybee
-- Glenn Paden

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iMonitor is
    port (
        IA      : in std_logic_vector(9 downto 0);
        IB      : in std_logic_vector(9 downto 0);
        nRST    : in std_logic;
        clk     : in std_logic;
        nINH    : out std_logic       
    );
    
end iMonitor;

architecture rtl of iMonitor is
-- signals
signal absIA    : std_logic_vector(9 downto 0);
signal absIB    : std_logic_vector(9 downto 0);
--signal absIA2   : std_logic_vector(11 downto 0);
--signal absIB2   : std_logic_vector(11 downto 0);
signal absIAint    : integer;
signal absIBint    : integer;
signal absIA2int   : integer;
signal absIB2int   : integer;

signal faultA   : std_logic;
signal faultB   : std_logic;
signal fault    : std_logic;

type t_State is (IDLE,HAULT);
signal state : t_State;

signal nINH_d : std_logic;

begin
    fault <= faultA OR faultB;
    absIAint <= to_integer(unsigned(absIA));
    absIBint <= to_integer(unsigned(absIB));
    absIA2int <= absIAint*2;
    absIB2int <= absIBint*2;
    
    absInputA : entity work.AbsoluteValue(rtl) 
    port map(
        I => IA,
        ABSi => absIA
    );

    absInputB : entity work.AbsoluteValue(rtl) 
    port map(
        I => IB,
        ABSi => absIB
    );

    inh_proc : 
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when IDLE =>
                    if fault = '1' then
                        state <= HAULT;
                        nINH <= '0';
                    else 
                        state <= IDLE;
                        nINH <= '1';
                    end if;
                 
                when others => -- HAULT and startup XX
                    nINH <= '0';
                    if nRST = '0' then
                        state <= IDLE;
                    else
                        state <= HAULT;
                    end if;
                    
             end case;
        end if;
    end process;
    
    fault_proc : 
    process(clk)
    begin
        if rising_edge(clk) then
            if absIAint > absIB2int then
                faultA <= '1';
            else 
                faultA <= '0';
            end if;
              
            if absIBint > absIA2int then
                faultB <= '1';
            else 
                faultB <= '0';
            end if;
            
        end if;    
    end process;

end rtl;
