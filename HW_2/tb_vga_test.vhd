LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
ENTITY tb_vga_test IS
END tb_vga_test;
ARCHITECTURE behavior OF tb_vga_test IS
COMPONENT vga_test
PORT(
    clk_100MHz : in STD_LOGIC;     -- from Basys 3
        reset      : in STD_LOGIC;     -- system reset
        hsync      : out STD_LOGIC;    -- horizontal sync
        vsync      : out STD_LOGIC;    -- vertical sync
        rgb        : out STD_LOGIC_VECTOR(11 downto 0)  -- 12 FPGA pins for RGB(4 per color)
);
END COMPONENT;
--Inputs
signal clock : std_logic := '0';
signal reset : std_logic := '0';
--Outputs
signal rgb : std_logic_vector(11 downto 0) := (others => '0');
signal hsync : std_logic := '0';
signal vsync : std_logic := '0';
-- Clock period definitions
constant clock_period : time := 10 ns;
signal i: integer;
BEGIN
-- Read image in VHDL
test: vga_test PORT MAP (
clk_100MHz => clock,
reset => reset,
hsync => hsync,
vsync => vsync,
rgb =>rgb
);
-- Clock process definitions
clock_process :process
begin
clock <= '0';
wait for clock_period/2;
clock <= '1';
wait for clock_period/2;
end process;

reset <= '1', '0' after 10 ns;
END;