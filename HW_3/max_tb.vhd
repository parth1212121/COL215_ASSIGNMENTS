library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity max_tb is
end max_tb;

architecture sim of max_tb is
  signal clk : std_logic := '1';
  signal cntrl : std_logic := '1';
  signal inp : signed(23 downto 0);
  signal outp : signed(23 downto 0);
  
  component max
    Port (
      clk : in std_logic;
      cntrl : in std_logic;
      inp : in signed(23 downto 0);
      outp : out signed(23 downto 0)
    );
  end component;

begin
  uut: max port map (
    clk => clk,
    inp => inp,
    cntrl => cntrl,
    outp => outp
  );

  process
  begin
    clk <= not clk;  
    wait for 5 ns;
  end process;

  process
  begin
    
    inp <= to_signed(10, 24);  
    cntrl <= '1'; 
    
    wait for 10 ns;
    
    
    inp <= to_signed(5, 24); 
    wait for 10 ns;
    
    
    inp <= to_signed(15, 24);  
    wait for 10 ns;
    
      
    inp <= to_signed(25, 24);  
    wait for 10 ns;
    
        
    inp <= to_signed(3, 24);  
    wait for 10 ns;
    
        
    inp <= to_signed(1, 24); 
    wait for 10 ns;
    
    
           
    inp <= to_signed(45, 24);  
    wait for 10 ns;

    
    
    cntrl <= '0';  -- Disable the comparator
    inp <= to_signed(1, 24);
    wait for 10 ns;
    
    
    cntrl <= '1';  -- Reanble
    wait for 10 ns;

    wait;
  end process;
end sim;