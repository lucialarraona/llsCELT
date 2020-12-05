----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:06:25 10/27/2018 
-- Design Name: 
-- Module Name:    comp_16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Additional Comments: 
	--------------------------------------------------
	------------ COMPARADOR DE 16 BITS --------------
	-- Módulo basado en circuito combinacional que compara los valores 
	-- binarios de las entradas P y Q. 
	----------------------------------------------------------------------------------
	library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

	entity comp_16 is
		 Port ( P : in  STD_LOGIC_VECTOR (15 downto 0);
				  Q : in  STD_LOGIC_VECTOR (15 downto 0);
				  P_GT_Q : out  STD_LOGIC);
	end comp_16;

	architecture Behavioral of comp_16 is

	-- modelamos el comparador como un proceso que toma P
	-- y Q en la lista de sensibilidad. 

		begin
			process(P,Q)
	 begin 
		if (P > Q) then  -- si p>q 

			P_GT_Q <= '1'; -- la salida es = 1

		else 

			P_GT_Q <= '0'; -- si p<q la salida es 0 

	end if;
	end process;
	end Behavioral;
	
