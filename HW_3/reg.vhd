library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity reg is
  generic (
    size : integer := 8
  );
  Port (
    clk : in std_logic;
    we : in std_logic;
    din : in signed(size-1 downto 0):= (others => '0');
    dout : out signed(size-1 downto 0) := (others => '0')
  );
end reg;

architecture Behavioral of reg is
begin
    dout <= din when(rising_edge(clk) and  we = '1');
end Behavioral;
