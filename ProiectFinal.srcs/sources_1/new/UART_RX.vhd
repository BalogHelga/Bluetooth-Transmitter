----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2022 03:33:58 PM
-- Design Name: 
-- Module Name: UART_RX - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_RX is
  Port ( Clk: in STD_LOGIC;
         Rst: in STD_LOGIC;
         Rx_Data: out STD_LOGIC_VECTOR(7 downto 0);
         RxRdy: out STD_LOGIC;
         baudEn: in STD_LOGIC;
         Rx: in STD_LOGIC
        );
end UART_RX;

architecture Behavioral of UART_RX is
type state_type is(idle,start,bitS,stop,waitS);
signal St :state_type;
signal CntRate: STD_LOGIC_VECTOR(3 downto 0);
signal CntBit: STD_LOGIC_VECTOR(2 downto 0);

begin
process(Clk)
begin
    if Rst = '1' then
        St<=idle;
        CntRate<="0000";
    else
        if rising_edge(Clk) then
            if baudEn = '1' then
                case St is
                    when idle => if Rx = '0' then
                                    CntRate<="0000";
                                    CntBit<="000";
                                    St<=start;
                                 end if;
                    when start => CntRate<=CntRate+1;
                                  if CntRate = "0111" then
                                       if Rx = '1' then
                                          St<=idle;
                                          CntRate<="0000";
                                       else
                                          CntRate<="0000";
                                          CntBit<="000";
                                          St<=bitS;
                                       end if;
                                end if;
                    when bitS =>  CntRate<=CntRate+1;
                                  if CntRate = "1111" then
                                       Rx_Data(conv_integer(CntBit))<=Rx;
                                       CntBit<=CntBit+1;
                                  if CntBit = "111" then
                                        St<=stop;
                                        CntBit<="000";
                                        CntRate<="0000";
                                  else
                                        St<=bitS;
                                        CntRate<="0000";
                                  end if;
                               end if;
                    when stop => CntRate<=CntRate+1;
                                 if CntRate = "1111" then
                                      St<=waitS;
                                      CntRate<="0000";
                                 end if;
                    when waitS => CntRate<=CntRate+1;
                                  if CntRate = "0111" then
                                      CntRate<="0000";
                                      St<=idle;
                                  end if; 
                end case;
            end if;
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(Clk) then
        if baudEn = '1' then
             case St is 
                     when idle => RxRdy<='0';
                     when start => RxRdy<='0';
                     when bitS => RxRdy<='0';
                     when stop => RxRdy<='0';
                     when waitS => RxRdy<='1';
            end case;
        end if;
     end if;
end process;

end Behavioral;