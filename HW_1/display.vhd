library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity seven_seg is
    Port ( clk : in STD_LOGIC;
	   	   num : in STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0));
end seven_seg;

architecture Behavioral of seven_seg is

signal led_bcd: STD_LOGIC_VECTOR (3 downto 0);
signal counter: STD_LOGIC_VECTOR (19 downto 0);
signal mux_sel: std_logic_vector(1 downto 0);
begin
process(led_bcd)
begin
    seg(6) <= (not led_bcd(3) and not led_bcd(2) and not led_bcd(1) and led_bcd(0)) or (not led_bcd(3) and led_bcd(2) and not led_bcd(1) and not led_bcd(0)) or (led_bcd(3) and not led_bcd(2) and led_bcd(1) and led_bcd(0)) or ( led_bcd(3) and led_bcd(2) and not led_bcd(1) and led_bcd(0));
    seg(5) <= (not led_bcd(3) and not led_bcd(1) and led_bcd(0)) or (led_bcd(2) and led_bcd(1) and not led_bcd(0)) or (led_bcd(3) and led_bcd(1) and led_bcd(0)) or (led_bcd(3) and led_bcd(2) and not led_bcd(0));
    seg(4) <= (led_bcd(3) and led_bcd(2) and led_bcd(1)) or (led_bcd(3) and led_bcd(2) and not led_bcd(0)) or (not led_bcd(3) and not led_bcd(2) and not led_bcd(1) and led_bcd(0)) or (not led_bcd(3) and not led_bcd(2) and not led_bcd(0) and led_bcd(1));
    seg(3) <= (led_bcd(2) and led_bcd(1) and led_bcd(0)) or (not led_bcd(2) and not led_bcd(1) and led_bcd(0)) or ( not led_bcd(3) and not led_bcd(1) and not led_bcd(0) and led_bcd(2)) or ( led_bcd(3) and not led_bcd(2)  and led_bcd(1) and not led_bcd(0));
    seg(2) <= (not led_bcd(3) and led_bcd(1) and led_bcd(0)) or (not led_bcd(3) and led_bcd(2) and not led_bcd(1)) or (led_bcd(3) and not led_bcd(2) and not led_bcd(1) and led_bcd(0));
    seg(1) <= (not led_bcd(3) and not led_bcd(2) and led_bcd(1)) or (not led_bcd(3) and led_bcd(1) and led_bcd(0)) or (led_bcd(3) and led_bcd(2) and not led_bcd(1) and led_bcd(0));
    seg(0) <= (not led_bcd(3) and not led_bcd(2) and not led_bcd(1)) or (not led_bcd(3) and led_bcd(2) and led_bcd(1) and led_bcd(0)) or (led_bcd(3) and led_bcd(2) and not led_bcd(1) and not led_bcd(0));
end process;

process(clk)
begin 
    if(rising_edge(clk)) then
        counter <= counter + 1;
    end if;
end process;

mux_sel <= counter(19 downto 18);

process(mux_sel)
begin
    case mux_sel is
    when "00" =>
        an <= "0111"; 
        led_bcd <= num(15 downto 12);
    when "01" =>
        an <= "1011"; 
        led_bcd <= num(11 downto 8);
    when "10" =>
        an <= "1101"; 
        led_bcd <= num(7 downto 4);
    when "11" =>
        an <= "1110"; 
        led_bcd <= num(3 downto 0);
    when others =>
    	an <= "1111";
        led_bcd <= "0000";
    end case;
end process;
end Behavioral;