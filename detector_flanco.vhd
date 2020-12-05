----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:43:20 10/26/2018 
-- Design Name: 
-- Module Name:    detector_flanco - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Additional Comments: 
-------------------------------------------------------
------- DETECTOR DE FLANCOS ------ 
-- M�dulo que se utiliza para filtrar los flancos de la se�al y as� evitar glitches y rebotes.
-- La finalidad del mismo es detectar si los flancos que le llegan son de subida o de bajada muestreando la se�al 
-- constantemente y almancenando esas muestras en un registro de desplazamiento s�ncrono y
-- calculando la suma de los 20 bits del registro de forma continua.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity detector_flanco is
    Port ( CLK_1ms : in  STD_LOGIC; -- Entrada de la se�al de reloj
           LIN : in  STD_LOGIC;		-- Entrada de datos
           VALOR : out  STD_LOGIC); -- Se�al que nos muestra si el umbral est� por encima del valor especificado o no. 
end detector_flanco;

architecture Behavioral of detector_flanco is

constant UMBRAL0 : STD_LOGIC_VECTOR (7 downto 0) := "00000101"; -- 5 umbral para el 0
constant UMBRAL1 : STD_LOGIC_VECTOR (7 downto 0) := "00001111"; -- 15 umbral para el 1

signal reg_desp : STD_LOGIC_VECTOR (19 downto 0):="00000000000000000000"; -- Se�al auxiliar de 20 bits del registro de desplazamiento
signal suma : STD_LOGIC_VECTOR (7 downto 0) :="00000000"; -- Se�al en la que vamos almacenando el valor de la suma de los 20 bits del registro
signal s_valor : STD_LOGIC; -- Se�al auxiliar para operar dentro del process

begin

process (CLK_1ms) -- Proceso que calcula la suma de los bits del registro

begin

if (CLK_1ms'event and CLK_1ms='1') then  
		suma <= suma + LIN - reg_desp(19); --(Para ello sumamos la nueva muestra que llega y restamos la �ltima que sale)

-- Desplazar los datos del registro capturando la nueva muestra en el registro. 
-- Para ello concatenamos (con &) el bit de la entrada
-- de datos con los los bits del registro de desplazamiento-1 
-- (hueco en el que introducimos ese dato nuevo) .

	reg_desp <= reg_desp(18 downto 0)& LIN; 
	 
-- Finalmente vemos si la suma supera los umbrales y asignamos a s_valor el valor adecuado
	
	if suma < UMBRAL0 then  	-- Si la suma de los valores del registro de desplazamiento 
			s_valor <= '0';		-- es menor que el umbral establecido 
										-- indicar� que es un flanco de bajada
										-- y pondr� la salida (VALOR) a 0.
			
	elsif suma > UMBRAL1 then 	-- Si la suma de los valores del registro de desplazamiento 
				s_valor <= '1';  	-- es mayor que el umbral establecido
										-- indicar� que es un flanco de subida
										-- pondr� la salida (VALOR) a 1.
			
		end if; 
		
	end if; 
	end process;

VALOR<=s_valor; 		-- La salida se corresponde con la se�al auxiliar s_valor.

end Behavioral;

