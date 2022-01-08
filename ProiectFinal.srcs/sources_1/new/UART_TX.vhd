----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2022 03:34:41 PM
-- Design Name: 
-- Module Name: UART_TX - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_TX is generic (n : INTEGER := 115200);
      Port ( Clk : in STD_LOGIC;
             Rst : in STD_LOGIC;
             Start : in STD_LOGIC;
             TxData : in STD_LOGIC_VECTOR (7 downto 0);
             Tx : out STD_LOGIC;
             TxRdy : out STD_LOGIC);
end UART_TX;

architecture Behavioral of UART_TX is

attribute keep: boolean;
constant clk_frq :INTEGER := 100000000;
constant T_BIT : INTEGER := 868;
type stare is  (ready, load, send, waitbit, shift);
signal St : stare := ready;
signal CntRate, CntBit : INTEGER := 0;
signal LdData, ShData, TxEn : STD_LOGIC := '0';
signal TSR : STD_LOGIC_VECTOR (9 downto 0) := (others => '0'); 
attribute keep of St: signal is true;
attribute keep of CntRate, CntBit: signal is true;
attribute keep of TSR: signal is true;
begin

proc_control: process (Clk) 
    begin
        if RISING_EDGE (Clk) then
            if (Rst = '1') then
                St <= ready; 
            else
                case St is
                    when ready => 
                        CntRate <= 0; 
                        CntBit <= 0; 
                        if (Start = '1') then
                            St <= load; 
                        end if; 
                    when load => 
                        St <= send; 
                    when send => 
                        CntBit <= CntBit + 1; 
                        St <= waitbit; 
                    when waitbit => 
                        CntRate <= CntRate + 1; 
                        if (CntRate = T_BIT-3) then
                            CntRate <= 0; 
                            St <= shift; 
                        end if; 
                    when shift => 
                        if (CntBit = 10) then
                            St <= ready; 
                        else
                            St <= send; 
                        end if; 
                    when others => 
                        St <= ready; 
                end case; 
            end if; 
        end if; 
 end process proc_control; 
 

    LdData <= '1' when St = load else '0'; 
    ShData <= '1' when St = shift else '0'; 
    TxEn <= '0' when St = ready or St = load else '1'; 
    

    Tx <= TSR(0) when TxEn = '1' else '1'; 
    TxRdy <= '1' when St = ready else '0';
    

 process (Clk, Rst)
 begin
    if RISING_EDGE (Clk) then
             if (Rst = '1') then
                TSR <= (others => '0');
             else
                if(LdData = '1') then
                    TSR <= '1' & TxData & '0';
                elsif (ShData = '1') then
                    TSR <= '0' & TSR (9 downto 1);
                end if;
              end if;
     end if;
  end process;
end Behavioral;
