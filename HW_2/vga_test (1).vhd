library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity vga_test is
    Port (
        clk_100MHz : in STD_LOGIC;
        reset      : in STD_LOGIC;
        hsync      : out STD_LOGIC;
        vsync      : out STD_LOGIC;
        rgb        : out STD_LOGIC_VECTOR(11 downto 0)
    );
end vga_test;

architecture Behavioral of vga_test is
    signal rgb_reg : STD_LOGIC_VECTOR(11 downto 0);
    signal video_on : STD_LOGIC;
    signal en : STD_LOGIC;
    signal p_tick : STD_LOGIC;
    signal x : STD_LOGIC_VECTOR(9 downto 0);
    signal y : STD_LOGIC_VECTOR(9 downto 0);
    signal addr: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal data: STD_LOGIC_VECTOR(7 downto 0);
    signal done: std_logic:='0' ;
    
    signal rdaddress : std_logic_vector(15 downto 0) := (others => '0');
    signal ram_daddress : std_logic_vector(15 downto 0) := (others => '0');
    
    signal r_a : std_logic_vector(15 downto 0);

    signal rom_data : std_logic_vector(7 downto 0) := (others => '0');
    signal gradient: integer := 0;
    signal register1: integer:=0;
    signal register2: integer:=0;
    signal register3: integer:=0;

    signal ram_data:  std_logic_vector(7 downto 0):=(others =>'0');

    signal wr: std_logic:='1';
    signal wr_comp:integer:=0;
    signal i: integer:=0;
    signal j:integer:=-1;

    component vga_controller
        Port (
            clk_100MHz : in STD_LOGIC;
            reset      : in STD_LOGIC;
            done       : in std_logic ;
            video_on   : out STD_LOGIC;
            hsync      : out STD_LOGIC;
            vsync      : out STD_LOGIC;
            p_tick     : out STD_LOGIC;
            x          : out STD_LOGIC_VECTOR(9 downto 0);
            y          : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;

COMPONENT dist_mem_gen_0
    PORT(
        a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        clk : IN STD_LOGIC;
        spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END COMPONENT;

COMPONENT dist_mem_gen_1--RAM
    PORT(
        a: in std_logic_vector(15 downto 0);
        d: in std_logic_vector(7 downto 0);
        clk:in std_logic;
        we:in std_logic;
        spo:out std_logic_vector(7 downto 0)
    );
END component ;

use work.Clock_Divider;

signal ClockDiv4: std_logic;

begin

    clk_div: entity Clock_Divider 
        port map (
            clk_in=>clk_100MHz,pixel_clock=>ClockDiv4
        );

    vga_c : vga_controller
    port map (
        clk_100MHz => clk_100MHz,
        reset => reset,
        done => done,
        video_on => video_on,
        hsync => hsync,
        vsync => vsync,
        p_tick => p_tick,
        x => x,
        y => y
    );
        
    rom: dist_mem_gen_0
    port map (
        spo => rom_data,
        clk => clk_100MHz,
        a => rdaddress
    );
        
    ram : dist_mem_gen_1
    port map (
        clk => clk_100MHz,
        a => r_a,
        spo => data,
        we => wr,
        d => ram_data
    );

    process(clk_100MHz)
    begin
    if(rising_edge(clk_100MHz)) then
        if(i > 65536) then
            done <= '1';
            wr <= '0';
        end if;
        if(i<=65536) then

            if(wr_comp =0) then   -- Reading from ROM..
                if(i<65536) then
                    rdaddress <= std_logic_vector(TO_UNSIGNED(i,16));
                end if;
                if(i>=1) then
                    ram_daddress<=std_logic_vector(TO_UNSIGNED(i-1,16));
                end if;

                i<=i+1;
                if(j=255) then
                    j<=0;
                else
                    j<=j+1;
                end if;
                wr_comp<= wr_comp+1;

            elsif(wr_comp =1) then   -- Time_Pass
                wr_comp <=wr_comp+1;

            elsif(wr_comp = 2) then    -- Storing pixels in Registers...
                wr_comp<=wr_comp+1;

                register1 <= register2;
                register2 <= register3;
                register3 <=to_integer(unsigned(rom_data));

            elsif(wr_comp=3) then        -- Computing gradient...
                wr_comp <=wr_comp+1;
                if(i>1) then
                    if(j=0) then
                        gradient <= register1 - register2*2;
                elsif(j=1) then
                        gradient<= register3 - register2*2;
                    else
                        gradient <=register1-register2*2+register3;
                    end if;

                end if;

            elsif(wr_comp = 4) then      -- Writing into the RAM....
                wr_comp <=0;
                if(gradient >255) then
                    ram_data <= "11111111";
                elsif(gradient <0) then
                    ram_data<= "00000000";
                else
                    ram_data <= std_logic_vector(to_unsigned(gradient,8));
                end if;
            end if;

        end if;
        
    end if;
    
end process;
            

    -- RGB Buffer
    process(clk_100MHz, reset)
    begin
        if reset = '1' then
            rgb_reg <= (others => '0');
        elsif rising_edge(clk_100MHz) then
            rgb_reg <= data(7 downto 4) & data(7 downto 4) & data(7 downto 4);
        end if;
    end process;

    process(ClockDiv4, reset)
    begin
        if reset = '1' then
            addr <= (others => '0');
        elsif falling_edge(ClockDiv4) and en = '1' then
            if(to_integer(unsigned(addr)) < 65536) then
                addr <= addr + "0000000000000001";
            end if;
        end if;
    end process;
    
    r_a <= ram_daddress when done = '0' else addr;

    en <= '1' when (to_integer(unsigned(x)) >= 194 and to_integer(unsigned(x)) < 450 and to_integer(unsigned(y)) >= 131 and to_integer(unsigned(y)) < 387) else '0';

    rgb <= (others => '0') when video_on = '0' or en = '0' else rgb_reg;

end Behavioral;