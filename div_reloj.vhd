----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:43:07 10/17/2018 
-- Design Name: 
-- Module Name:    div_reloj - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Additional Comments: 

-----------------------------------------------------
------------------- DIVISOR DE RELOJ ----------- 
--- El objetivo de este módulo es conseguir la frecuencia de reloj deseada dividiendo 
--- la que viene dada por el reloj interno de la FPGA (que trabaja a 50 Mhz).
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_1164.ALL;

entity div_reloj is 
    Port ( CLK : in  STD_LOGIC; 		  -- ENTRADA CLK DE frecuencia 50 MHz 
												  -- (el reloj propio de la FPGA)
           CLK_1ms : out  STD_LOGIC); -- SALIDA CLK con periodo modificado. 
												  -- Frecuencia 1000 MHz
end div_reloj;

architecture Behavioral of div_reloj is -- Basado en el ejemplo del manual de referencia de la BASYS2

signal contador : STD_LOGIC_VECTOR (15 downto 0);
signal flag : STD_LOGIC; 
                   
  begin          
process(CLK)
 begin
 if (CLK'event and CLK='1') then 
		contador<=contador+1; 
		
 if (contador=25000) then  		-- El reloj tiene un periodo de 20 ns 
											--(1/50Mhz) por tanto tras 
		contador<=(others=>'0');	-- pasar 25000 cuentas habran 
											-- transcurrido 0.5ms.
		flag<= not flag;
		end if;
	end if;
 end process;
 
CLK_1ms<=flag;

end Behavioral;