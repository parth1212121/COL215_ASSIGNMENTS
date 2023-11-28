library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mac_tb is
end mac_tb;

architecture sim of mac_tb is
  signal clk : std_logic := '1';
  signal cntrl : std_logic := '1';
  signal inp1: signed(15 downto 0);
  signal inp2: signed(7 downto 0);
  signal outp : signed(23 downto 0);
  
  component mac
    Port (
      clk : in std_logic;
      cntrl : in std_logic;
      inp1 : in signed(15 downto 0);
      inp2 : in signed(7 downto 0);
      outp : out signed(23 downto 0)
    );
  end component;

begin
  uut: mac port map (
    clk => clk,
    cntrl => cntrl,
    inp1 => inp1,
    inp2 => inp2,
    outp => outp
  );

  process
  begin
    clk <= not clk;  
    wait for 5 ns;
  end process;

  process
  begin
    
    cntrl <= '1'; 
    inp1 <= to_signed(5, 16);  
    inp2 <= to_signed(-2, 8);      
    wait for 10 ns;
      
    inp1 <= to_signed(8, 16);  
    inp2 <= to_signed(3, 8);   
    wait for 10 ns;
         
    inp1 <= to_signed(1, 16);  
    inp2 <= to_signed(13, 8);   
    wait for 10 ns;
          
    inp1 <= to_signed(18, 16); 
    inp2 <= to_signed(30, 8);   
    wait for 10 ns;
           
    inp1 <= to_signed(3, 16);  
    inp2 <= to_signed(5, 8);   
    wait for 10 ns;
        
    inp1 <= to_signed(4, 16);  
    inp2 <= to_signed(2, 8); 
    wait for 10 ns;
           
    inp1 <= to_signed(-12, 16);  
    inp2 <= to_signed(11, 8);  
    wait for 10 ns;
        
    inp1 <= to_signed(10, 16);  
    inp2 <= to_signed(10, 8);  
    wait for 10 ns;
      
    inp1 <= to_signed(0, 16);  
    inp2 <= to_signed(0, 8);   
    cntrl <= '0';  
    wait for 10 ns;
            
    inp1 <= to_signed(10, 16);  
    inp2 <= to_signed(10, 8);   
    wait for 10 ns;
   
    
    wait;
  end process;
end sim;