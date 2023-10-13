-- DualPWM Module
-- for Honeybee
-- Glenn Paden

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DualPWM is
    generic (
        COMP1_SIZE: natural;
        COMP2_SIZE: natural;
        PER_SIZE: natural
    );
    port (
        clk     : in std_logic;
        COMP1   : in std_logic_vector(COMP1_SIZE-1 downto 0);
        COMP2   : in std_logic_vector(COMP2_SIZE-1 downto 0);
        PER     : in std_logic_vector(PER_SIZE-1 downto 0);
        EN      : in std_logic;
        nRST    : in std_logic;
        PWM1    : out std_logic;       
        PWM2    : out std_logic       
    );    
end DualPWM;

architecture rtl of DualPWM is

signal counter : integer := 0;
type t_counterState is (COUNTUP,COUNTDOWN);
signal countState : t_counterState;
type t_State is (LOW,RISE, HIGH, FALL);
signal statePWM1 : t_State;
signal statePWM2 : t_State;

begin

    pwm_proc : 
    process(clk)
    begin
        if rising_edge(clk) then
            if nRST = '0' then
                counter <= 0;
                PWM1 <= '0';
                PWM2 <= '0';
                statePWM1 <= LOW;
                statePWM2 <= LOW;
                countState <= COUNTUP;
                
            else
                -- check to make sure PER is nonZero
                if (EN = '1' AND (to_integer(unsigned(PER)) /= 0)) then
                    case countState is
                        when COUNTDOWN =>
                            if counter = 0 then
                                countState <= COUNTUP;
                                counter <= 1;
                            else 
                                countState <= COUNTDOWN;
                                counter <= counter -1;
                            end if;
                        when others => -- COUNTUP
                            if counter = to_integer(unsigned(PER)) then
                                countState <= COUNTDOWN;
                                counter <= to_integer(unsigned(PER))-1; 
                            else 
                                countState <= COUNTUP;
                                counter <= counter + 1;
                            end if;
                    end case;                            
                    
                    -- PWM 1
                    case statePWM1 is
                        when HIGH =>
                            if counter = to_integer(unsigned(COMP1)) then
                                PWM1 <= '0';
                                statePWM1 <= LOW;
                            else
                                PWM1 <= '1';
                                statePWM1 <= HIGH;
                            end if;
                        when others => --LOW
                            if counter = to_integer(unsigned(COMP1)) then
                                PWM1 <= '1';
                                statePWM1 <= HIGH;
                            else
                                PWM1 <= '0';
                                statePWM1 <= LOW;
                            end if;
                    end case;
                    
                    --PWM 2
                    case statePWM2 is
                        when HIGH =>
                            if counter = to_integer(unsigned(COMP2)) then
                                PWM2 <= '0';
                                statePWM2 <= LOW;
                            else
                                PWM2 <= '1';
                                statePWM2 <= HIGH;
                            end if;
                        when others => --LOW
                            if counter = to_integer(unsigned(COMP2)) then
                                PWM2 <= '1';
                                statePWM2 <= HIGH;
                            else
                                PWM2 <= '0';
                                statePWM2 <= LOW;
                            end if;
                    end case;
                else -- not EN
                    PWM1 <= '0';
                    PWM2 <= '0';
                    -- states should retain current state but that adds a latch
                end if;        
            end if;
        end if;
    end process;


end rtl;