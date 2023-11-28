library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity min_tb is
end min_tb;

architecture sim of min_tb is
  signal clk, cntrl : std_logic;
  signal inp : signed(23 downto 0);
  signal outp : signed(23 downto 0);
  
  component min
    Port (
      clk : in std_logic;
      cntrl : in std_logic;
      inp : in signed(23 downto 0);
      outp : out signed(23 downto 0)
    );
  end component;

begin
  uut: min port map (
    clk => clk,
    inp => inp,
    cntrl => cntrl,
    outp => outp
  );

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

    
   
    cntrl <= '0';  -- Disable.
    inp <= to_signed(3, 24);
    wait for 10 ns;
    
    
    cntrl <= '1';   -- Reanable.
    wait for 10 ns;
    
  
    
    wait;
  end process;
  
  
  process
  begin
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
  end process;

end sim;
