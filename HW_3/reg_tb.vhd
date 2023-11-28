library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity reg_tb is
--  Port ( );
end reg_tb;

architecture Behavioral of reg_tb is
    signal clk : std_logic := '0';
    signal w_e : std_logic := '1';
    
    signal din : signed(7 downto 0) := "00000000";
    signal dout : signed(7 downto 0) :="00000000";
    
    signal i : integer:=0;
    signal finished : std_logic := '0';

begin
    DUT : entity work.reg port map (
        clk => clk,
        we => w_e,
        din => din,
        dout => dout
    );
    
    clk <= not clk after 5ns when finished /= '1' else '0';
   -- w_e <= not w_e after 100ns;
    stim_process : process
    
    begin
        for i in 0 to 63 loop
            din <= to_signed(i, din'length);
            wait for 20ns;
        end loop;
        finished <= '1';
        
    end process;

end Behavioral;
