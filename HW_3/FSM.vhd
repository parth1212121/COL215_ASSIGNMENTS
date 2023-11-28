library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity controller is
  Port (
    clk   : in std_logic :='0';
    reset : in STD_LOGIC:='0';
    hsync : out STD_LOGIC:='0';
    vsync : out STD_LOGIC:='0';
    rgb   : out STD_LOGIC_VECTOR(11 downto 0):= (others => '0')
  );
end controller;

architecture Behavioral of controller is

    type state_t is (CONV, NORM, DISP);
    type compute_t is (NONE, MULT, STORE);
    type norm_t  is (NONE, CALC_M, CALC_D, TRUNC, STORE);

    signal rgb_reg : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal video_on : STD_LOGIC;
    signal en : STD_LOGIC;
    signal p_tick : STD_LOGIC;
    signal x : STD_LOGIC_VECTOR(9 downto 0);
    signal y : STD_LOGIC_VECTOR(9 downto 0);
    signal vga_active : STD_LOGIC := '0';

    signal ram_addr : STD_LOGIC_VECTOR(11 downto 0);
    signal ram_din : STD_LOGIC_VECTOR(23 downto 0);
    signal ram_we : STD_LOGIC := '0';
    signal ram_dout : STD_LOGIC_VECTOR(23 downto 0);

    signal img_rom_addr : STD_LOGIC_VECTOR(11 downto 0);
    signal img_rom_dout : STD_LOGIC_VECTOR(7 downto 0);

    signal ker_rom_addr : STD_LOGIC_VECTOR(3 downto 0);
    signal ker_rom_dout : STD_LOGIC_VECTOR(7 downto 0);

    signal mac_cntrl : STD_LOGIC;
    signal mac_inp1 : signed(15 downto 0);
    signal mac_inp2 : signed(7 downto 0);
    signal mac_outp : signed(23 downto 0);

    signal max_cntrl : STD_LOGIC := '0';
    signal max_inp : signed(23 downto 0);
    signal max_outp : signed(23 downto 0);

    signal min_cntrl : STD_LOGIC := '0';
    signal min_inp : signed(23 downto 0);
    signal min_outp : signed(23 downto 0);

    signal curr_state : state_t := CONV;
    signal curr_compute : compute_t := MULT;
    signal curr_norm : norm_t := CALC_M;

    signal i : integer := 0;

    signal conv_ram_addr : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal j : integer := 0;

    signal norm_ram_addr : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal norm_val : integer;
    signal trunc_norm_val : signed(7 downto 0);
    signal disp_ram_addr : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');

    signal p_clk : STD_LOGIC;

    signal c : integer := 0;

COMPONENT ramRAM
        PORT(
            a: in std_logic_vector(11 downto 0):= (others => '0');
            d: in std_logic_vector(23 downto 0):= (others => '0');
            clk:in std_logic:='0';
            we:in std_logic:='0';
            spo:out std_logic_vector(23 downto 0):= (others => '0')
        );
    END component ;



    COMPONENT img_rom
        PORT(
            a : IN STD_LOGIC_VECTOR(11 DOWNTO 0):= (others => '0');
            clk : IN STD_LOGIC:='0';
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):= (others => '0')
        );
    END COMPONENT;



     COMPONENT ker_rom
        PORT(
            a : IN STD_LOGIC_VECTOR(3 DOWNTO 0):= (others => '0');
            clk : IN STD_LOGIC:='0';
            spo : OUT STD_LOGIC_VECTOR(7 DOWNTO 0):= (others => '0')
        );
    END COMPONENT;


begin

    vga : entity work.vga port map(
        clk => clk,
        reset => reset,
        active => vga_active,
        video_on => video_on,
        hsync => hsync,
        vsync => vsync,
        p_tick => p_tick,
        x => x,
        y => y
    );

    ra :ram port map(
        clk => clk,
        a => ram_addr,
        spo => ram_dout,
        we => ram_we,
        d => ram_din
    );

    img_ro : img_rom port map(
        clk => clk,
        a => img_rom_addr,
        spo => img_rom_dout
    );

    ker_ro : ker_rom port map(
        clk => clk,
        a => ker_rom_addr,
        spo => ker_rom_dout
    );

    mac : entity work.mac port map(
        clk => clk,
        cntrl => mac_cntrl,
        inp1 => mac_inp1,
        inp2 => mac_inp2,
        outp => mac_outp
    );

    max : entity work.max port map(
        clk => clk,
        inp => max_inp,
        outp => max_outp,
        cntrl => max_cntrl
    );

    min : entity work.min port map(
        clk => clk,
        inp => min_inp,
        outp => min_outp,
        cntrl => min_cntrl
    );

    pclk : entity work.p_clk port map(
        clk => clk,
        p_clk => p_clk
    );

    vga_active <= '1' when curr_state = DISP else '0';
    en <= '1' when (to_integer(unsigned(x)) >= 290 and to_integer(unsigned(x)) < 354 and to_integer(unsigned(y)) >= 227 and to_integer(unsigned(y)) < 291) else '0';
    rgb <= (others => '0') when video_on = '0' or en = '0' else rgb_reg;

    mac_inp1 <= signed(x"00" & img_rom_dout(7 downto 0)) when curr_state = CONV and curr_compute = MULT else x"0000";

    mac_inp2 <= signed(ker_rom_dout(7 downto 0));

    ram_din <= std_logic_vector(mac_outp) when curr_state = CONV  else
                std_logic_vector(x"0000" & trunc_norm_val) when curr_state = NORM else (others => '0');

    max_inp <= mac_outp when curr_state = CONV else x"FFFFFF";

    min_inp <= mac_outp when curr_state = CONV else x"7FFFFF";

    ram_addr <= conv_ram_addr when curr_state = CONV else
                norm_ram_addr when curr_state = NORM else
                disp_ram_addr when curr_state = DISP else
                (others => '0');

    process(clk)
    begin
        if rising_edge(clk) then
            if curr_state = CONV then
                if curr_compute = MULT then
                    if i = 0 then
                        mac_cntrl <= '0';
                    else
                        mac_cntrl <= '1';
                    end if;

                    if i = 9 then
                        curr_compute <= STORE;
                    else
                        if(j > 0 and j < 63 and to_integer(unsigned(conv_ram_addr)) >= 64 and to_integer(unsigned(conv_ram_addr)) < 4032) then
                            if(i = 0) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) - 65, 12));
                                ker_rom_addr <= "0000";
                            elsif(i = 1) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) - 64, 12));
                                ker_rom_addr <= "0001";
                            elsif(i = 2) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) - 63, 12));
                                ker_rom_addr <= "0010";
                            elsif(i = 3) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) - 1, 12));
                                ker_rom_addr <= "0011";
                            elsif(i = 4) then
                                img_rom_addr <= conv_ram_addr;
                                ker_rom_addr <= "0100";
                            elsif(i = 5) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) + 1, 12));
                                ker_rom_addr <= "0101";
                            elsif(i = 6) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) + 63, 12));
                                ker_rom_addr <= "0110";
                            elsif(i = 7) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) + 64, 12));
                                ker_rom_addr <= "0111";
                            elsif(i = 8) then
                                img_rom_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(conv_ram_addr)) + 65, 12));
                                ker_rom_addr <= "1000";
                            end if;
                            i <= i + 1;
                        else
                            i <= 9;
                        end if;
                    end if;
                elsif curr_compute = STORE then
                    if(j > 0 and j < 63 and to_integer(unsigned(conv_ram_addr)) >= 64 and to_integer(unsigned(conv_ram_addr)) < 4032) then
                        ram_we <= '1';
                        max_cntrl <= '1';
                        min_cntrl <= '1';
                        if(c = 2) then
                            c <= 0;
                            curr_compute <= NONE;
                        else
                            c <= c + 1;
                        end if;
                    else
                        curr_compute <= NONE;
                    end if;
                else
                    i <= 0;
                    ram_we <= '0';
                    max_cntrl <= '0';
                    min_cntrl <= '0';
                    if(conv_ram_addr = x"FFE") then
                        curr_state <= NORM;
                        j <= 0;
                    else
                        conv_ram_addr <= conv_ram_addr + x"001";
                        if(j = 63) then
                            j <= 0;
                        else
                            j <= j + 1;
                        end if;
                        curr_compute <= MULT;
                    end if;
                end if;
            elsif curr_state = NORM then
                if curr_norm = CALC_M then
                    if(j > 0 and j < 63 and to_integer(unsigned(conv_ram_addr)) >= 64 and to_integer(unsigned(conv_ram_addr)) < 4032) then
                        norm_val <= ( to_integer(signed(ram_dout) - min_outp) * 255 );
                    end if;
                    curr_norm <= CALC_D;
                elsif curr_norm = CALC_D then
                    if(j > 0 and j < 63 and to_integer(unsigned(conv_ram_addr)) >= 64 and to_integer(unsigned(conv_ram_addr)) < 4032) then
                        norm_val <= norm_val / ( to_integer(max_outp - min_outp) );
                    end if;
                    curr_norm <= TRUNC;
                elsif curr_norm = TRUNC then
                    if(j > 0 and j < 63 and to_integer(unsigned(conv_ram_addr)) >= 64 and to_integer(unsigned(conv_ram_addr)) < 4032) then
                        trunc_norm_val <= to_signed(norm_val, 8);
                    end if;
                    curr_norm <= STORE;
                elsif curr_norm = STORE then
                    if(j > 0 and j < 63 and to_integer(unsigned(conv_ram_addr)) >= 64 and to_integer(unsigned(conv_ram_addr)) < 4032) then
                        ram_we <= '1';
                        if(c = 2) then
                            c <= 0;
                            curr_norm <= NONE;
                        else
                            c <= c + 1;
                        end if;
                    else
                        curr_norm <= NONE;
                    end if;
                else
                    ram_we <= '0';
                    if(norm_ram_addr = x"FFE") then
                        curr_state <= DISP;
                    else
                        norm_ram_addr <= norm_ram_addr + x"001";
                        if(j = 63) then
                            j <= 0;
                        else
                            j <= j + 1;
                        end if;
                        curr_norm <= CALC_M;
                    end if;
                end if;
            else
                rgb_reg <= ram_dout(7 downto 4) & ram_dout(7 downto 4) & ram_dout(7 downto 4);
            end if;

        end if;


    end process;

   process(p_clk)
   begin
        if falling_edge(p_clk) and en = '1' then
            if(to_integer(unsigned(x)) < 4096) then
                disp_ram_addr <= disp_ram_addr + x"001";
            end if;
        end if;
   end process;

end Behavioral;