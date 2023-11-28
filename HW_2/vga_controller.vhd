library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity vga_controller is
    Port (
        clk_100MHz : in STD_LOGIC;
        reset      : in STD_LOGIC;
        done       : in std_logic;
        video_on   : out STD_LOGIC;
        hsync      : out STD_LOGIC;
        vsync      : out STD_LOGIC;
        p_tick     : out STD_LOGIC;
        x          : out STD_LOGIC_VECTOR(9 downto 0);
        y          : out STD_LOGIC_VECTOR(9 downto 0)
    );
end vga_controller;

architecture Behavioral of vga_controller is
    
    constant HD   : integer := 640;
    constant HF   : integer := 48;
    constant HB   : integer := 16;
    constant HR   : integer := 96;
    constant HMAX : integer := HD+HF+HB+HR-1;

    constant VD   : integer := 480;
    constant VF   : integer := 10;
    constant VB   : integer := 33;
    constant VR   : integer := 2;
    constant VMAX : integer := VD+VF+VB+VR-1;

    signal r_25MHz : STD_LOGIC_VECTOR(1 downto 0);
    signal w_25MHz : STD_LOGIC;

    signal h_count_r, h_count_n : STD_LOGIC_VECTOR(9 downto 0);
    signal v_count_r, v_count_n : STD_LOGIC_VECTOR(9 downto 0);

    signal v_sync_r, h_sync_r : STD_LOGIC;
    signal v_sync_n, h_sync_n : STD_LOGIC;

begin
    process(clk_100MHz, reset)
    begin
        if reset = '1' then
            r_25MHz <= "00";
        elsif rising_edge(clk_100MHz) then
            r_25MHz <= r_25MHz + "01";
        end if;
    end process;

    w_25MHz <= '1' when r_25MHz = "00" else '0';

    process(clk_100MHz, reset)
    begin
        if reset = '1' then
            v_count_r <= (others => '0');
            h_count_r <= (others => '0');
            v_sync_r  <= '0';
            h_sync_r  <= '0';
        elsif rising_edge(clk_100MHz) and done='1' then
            v_count_r <= v_count_n;
            h_count_r <= h_count_n;
            v_sync_r  <= v_sync_n;
            h_sync_r  <= h_sync_n;
        end if;
    end process;

    process(w_25MHz, reset)
    begin
        if reset = '1' then
            h_count_n <= (others => '0');
        elsif rising_edge(w_25MHz) and done='1' then
            if to_integer(unsigned(h_count_r)) = HMAX then
                h_count_n <= (others => '0');
            else
                h_count_n <= h_count_r + "0000000001";
            end if;
        end if;
    end process;

    process(w_25MHz, reset)
    begin
        if reset = '1' then
            v_count_n <= (others => '0');
        elsif rising_edge(w_25MHz) and done = '1' then
            if to_integer(unsigned(h_count_r)) = HMAX then
                if to_integer(unsigned(v_count_r)) = VMAX then
                    v_count_n <= (others => '0');
                else
                    v_count_n <= v_count_r + "0000000001";
                end if;
            end if;
        end if;
    end process;

    h_sync_n <= '1' when (to_integer(unsigned(h_count_r)) > (HD+HB-1) and to_integer(unsigned(h_count_r)) < (HD+HB+HR)) else '0';

    v_sync_n <= '1' when (to_integer(unsigned(v_count_r)) > (VD+VB-1) and to_integer(unsigned(v_count_r)) < (VD+VB+VR)) else '0';

    video_on <= '1' when (to_integer(unsigned(h_count_r)) < HD and to_integer(unsigned(v_count_r)) < VD) else '0';

    hsync <= h_sync_r;
    vsync <= v_sync_r;
    x <= h_count_r;
    y <= v_count_r;
    p_tick <= w_25MHz;
end Behavioral;