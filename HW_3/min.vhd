library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity min is
  Port (
    clk : in std_logic;
    inp : in signed(23 downto 0);
    cntrl : in std_logic;
    outp : out signed(23 downto 0)
  );
end min;

architecture Behavioral of min is
    signal w_e : std_logic := '1';
    signal comp_out : signed(23 downto 0) := x"7fffff";

begin
    
    comp_out <= inp when rising_edge(clk) and (inp < comp_out or cntrl = '0') else comp_out;
    outp <= comp_out;

end Behavioral;