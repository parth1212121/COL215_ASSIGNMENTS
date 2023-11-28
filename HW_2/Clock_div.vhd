library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity Clock_Divider is
    Port ( 
        clk_in : in std_logic;
        pixel_clock : out std_logic
    );
end Clock_Divider;

architecture Behavioral of Clock_Divider is

begin
    clock_divider : process (clk_in)

    variable c_v : std_logic_vector( 1 downto 0) := (others => '0');

    begin

    if (rising_edge(clk_in)) then
        if (c_v ="00") then
            c_v :=c_v + 1;
        elsif (c_v="01") then
            pixel_clock <='1';
            c_v := c_v +1;
        elsif (c_v="10") then
            pixel_clock <= '0';
            c_v := c_v +1;
        else
            c_v := "00";
        end if;
    end if;

    end process clock_divider;
end Behavioral;
