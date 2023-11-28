LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
ENTITY tb_vga_controller IS
END tb_vga_controller;
ARCHITECTURE behavior OF tb_vga_controller IS
COMPONENT vga_controller
Port (
        clk_100MHz : in STD_LOGIC;    -- from Basys 3
        reset      : in STD_LOGIC;    -- system reset
        done       : in std_logic;
        video_on   : out STD_LOGIC;   -- ON while pixel counts for x and y are within the display area
        hsync      : out STD_LOGIC;   -- horizontal sync
        vsync      : out STD_LOGIC;   -- vertical sync
        p_tick     : out STD_LOGIC;   -- the 25MHz pixel/second rate signal, pixel tick
        x          : out STD_LOGIC_VECTOR(9 downto 0); -- pixel count/position of pixel x, max 0-799
        y          : out STD_LOGIC_VECTOR(9 downto 0)  -- pixel count/position of pixel y, max 0-524
    );
END COMPONENT;
--Inputs
signal clock : std_logic := '0';
signal reset : std_logic := '0';
signal done  : in std_logic := '1';
--Outputs
signal video_on : std_logic := '0';
signal hsync : std_logic := '0';
signal vsync : std_logic := '0';
signal p_tick : std_logic := '0';
signal x : std_logic_vector(9 downto 0) := (others => '0');
signal y : std_logic_vector(9 downto 0) := (others => '0');
-- Clock period definitions
constant clock_period : time := 10 ns;
BEGIN
-- Read image in VHDL
controller: vga_controller PORT MAP (
clk_100MHz => clock,
reset => reset,
done => done,
video_on => video_on,
hsync => hsync,
vsync => vsync,
p_tick => p_tick,
x => x,
y => y
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