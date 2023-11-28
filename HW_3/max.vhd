library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity max is
  Port (
    clk : in std_logic;
    inp : in signed(23 downto 0);
    cntrl : in std_logic;
    outp : out signed(23 downto 0)
  );
end max;

architecture Behavioral of max is
    signal w_e : std_logic := '1';
    signal comp_out : signed(23 downto 0) := x"ffffff";

begin
    comp_out <= inp when rising_edge(clk) and (inp > comp_out or cntrl = '0') else comp_out;
    outp <= comp_out;

end Behavioral;