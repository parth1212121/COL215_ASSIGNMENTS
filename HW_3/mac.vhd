library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mac is
  Port (
    clk : in std_logic;
    cntrl : in std_logic;
    inp1 : in signed(15 downto 0);
    inp2 : in signed(7 downto 0);
    outp : out signed(23 downto 0)
  );
end mac;

architecture Behavioral of mac is
    signal w_e : std_logic := '1';
    signal mac_out : signed(23 downto 0) := "000000000000000000000000";
    signal acc_out : signed(23 downto 0) := "000000000000000000000000";
    signal mult : signed(23 downto 0) := "000000000000000000000000";
begin
    
    acc : entity work.reg generic map (
        size => 24
    ) port map (
        clk => clk,
        we => w_e,
        din => mac_out,
        dout => acc_out
    );
    
    mult <= inp1*inp2;
    mac_out <= mult + acc_out when cntrl = '1' else mult;
    outp <= acc_out;
    

end Behavioral;
