----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/05/2022 03:37:30 PM
-- Design Name: 
-- Module Name: modul_principal - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mmodul_principal is
  Port (Clk: in std_logic;
        Rst: in std_logic;
        Start: in std_logic;
        Start2: in std_logic;
        Din: in std_logic_vector(3 downto 0);
        Tx: out std_logic;
        Rx: in STD_LOGIC;
        TxRdy: out std_logic;
        RxRdy: out std_logic;
        an: out std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0) );
end mmodul_principal;

architecture Behavioral of mmodul_principal is

signal TxData: std_logic_vector(7 downto 0);
signal RxData: std_logic_vector(7 downto 0):="00000000";
signal Data: std_logic_vector(7 downto 0):="00000000";

signal rezultatDisplay: std_logic_vector(15 downto 0):="0000000000000000";

signal contor: integer := 0;
signal baudEn : std_logic := '0';
signal en: std_logic:='0';
signal en2: std_logic:='0';
signal enF : std_logic:='0';
begin

 --652 pentru 9600 si 55 pentru 115200
    baud_rate_generator:process(clk)
        begin
            if rising_edge(clk) then
                if contor < 55 then
                    contor <= contor + 1;
                    baudEn <= '0';
                elsif contor = 55 then 
                    contor <= 0;
                    baudEn <= '1';
                end if;    
            end if;
        end process;
    
    prelucrare_comenzi: process(clk, start, start2)
    begin
     if Start ='1' then
        Data <= RxData; 
        enF <= en;
     else 
        if Start2 ='1' then
        Data <= "0000" & Din;
        enF <= en2;
        end if;
     end if;
    end process;    
    
    PM_TX: entity work.UART_RX port map(
               Clk => clk,
               Rst =>Rst,
               Rx_Data =>RxData,
               RxRdy =>RxRdy,
               baudEn =>baudEn,
               Rx => Rx); 
              
                     
    rezultatDisplay<= "0000" & Din & RxData;
    
    PM_SSD: entity WORK.ssd port map(
              digits =>rezultatDisplay,
              clk => Clk,
              an => An,
              cat => cat);
   
    PM_RX: entity WORK.uart_tx port map(
              Clk => Clk,
              Rst => Rst,
              TxData => Data,
              Start=>enF,
              Tx =>Tx,
              TxRdy=> TxRdy);

    PM_DB1: entity Work.debouncer port map(
              Clk => Clk,
              Rst => Rst,
              Din => Start,
              Qout => en); 
               
    PM_DB2: entity Work.debouncer port map(
              Clk => Clk,
              Rst => Rst,
              Din => Start2,
              Qout => en2);         

end Behavioral;
