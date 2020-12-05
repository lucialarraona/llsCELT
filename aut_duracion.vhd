----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:50:32 10/26/2018 
-- Design Name: 
-- Module Name:    aut_duracion - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
	------------------------------------------------
	-------- AUT�MATA DE MEDIDA DE DURACI�N DE CEROS Y UNOS ---
	--Aut�mata que calcula el numero de ciclos de reloj entre flancos consecutivos. 
	--La finalidad del m�dulo es calcular cuanto dura la se�al a 0 y la se�al a 1, del mensaje 
	--recibido. De esta forma podremos diferenciar, m�s adelante, si se trata de un punto, una raya,
	--o un espacio. 
	----------------------------------------------------------------------------------
	library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

	entity aut_duracion is
		 Port ( CLK_1ms : in  STD_LOGIC;    -- ENTRADA DE RELOJ
				  ENTRADA : in  STD_LOGIC;    -- ENTRADA DE DATOS
				  VALID : out  STD_LOGIC;     -- Se�al de validacion que indica que el intervalo ha terminado, 
														-- es decir, que ha llegado a un flanco.
				  DATO : out  STD_LOGIC;      -- Valor binario que indica si se trata de un intervalo de 0 a 1
				  DURACION : out  STD_LOGIC_VECTOR (15 downto 0)); -- Registro de 16 bits que almacena el 
																					-- n�mero de ciclos de reloj contados.
	end aut_duracion;

	architecture Behavioral of aut_duracion is

	type STATE_TYPE is (CERO,ALM_CERO,VALID_CERO,UNO,ALM_UNO,VALID_UNO,VALID_FIN);

	signal ST : STATE_TYPE := CERO;
	signal cont : STD_LOGIC_VECTOR (15 downto 0):="0000000000000000"; -- Se�al auxiliar de 16 bits que utilizaremos para contar.
																							-- Los ciclos de reloj entre flancos cosecutivos.
	signal reg : STD_LOGIC_VECTOR (15 downto 0) :="0000000000000000"; -- Se�al en la que vamos almacenando el resultado de esa cuenta.

		begin
	process (CLK_1ms) -- aut�mata
		begin
		if (CLK_1ms'event and CLK_1ms='1') then   -- En cada flanco de reloj
			case ST is        							
			
	when CERO =>  					-- En el estado 0 
		cont<=cont+1;				-- actualizamos el valor del contador.
			if (cont > 800) then -- EL VALOR NECESITA SER MAYOR QUE EL S�MBOLO M�S GRANDE, EN ESTE CASO LA SEPARACI�N DE 700ns
										-- para que as� pueda salir del bucle en caso de recibir ceros durante m�s de 800ns.
				ST <= VALID_FIN; 	-- ambiamos de estado a VALID_FIN.
	 else 						
	 
	if (ENTRADA='0') then 	-- Si la entrada es = 0
		ST<=CERO;				-- volvemos al estado CERO.
	else							-- Y si no ocurre nada de lo anterior
		ST<=ALM_CERO; 			-- cambiamos de estado a ALM_CERO.
	end if;
	end if;

	-- OTROS ESTADOS

	when ALM_CERO =>       -- En el estado ALM_CERO 
		reg <= cont;  		  -- metemos el valor del contador en el registro. 
		cont <= "0000000000000000"; -- Y ponemos el contador a 0  (es decir,lo reiniciamos)
	ST <= VALID_CERO;		  --  cambiamos de estado VALID_CERO.



	when VALID_CERO => 	  -- Cada vez que llegamos a VALID_CERO saltamos al estado UNO.
		ST <= UNO;			  -- Dentro del proceso no declaramos la salidas VALID ni DATO
								  -- pero en este caso se pondr�an a 1 y 0 respectivamente. 



	when UNO => 			   -- En el estado UNO 
		cont <= cont+1;	   -- actualizamos el contador.
	if (ENTRADA = '1') then -- Cuando la entrada es = 1 
		ST <= UNO;			   -- nos mantenemos en ese estado
	else 						   -- y si no 
		ST <= ALM_UNO;		   -- pasamos al estado ALM_UNO
	end if;  


		
		
	when ALM_UNO => 		  -- En el estado ALM_UNO
		reg <=cont;			  -- guardamos en el registro el valor del contador. 
		cont <= "0000000000000000";  -- Despu�s reiniciamos el contador
		ST <= VALID_UNO;    -- y cambiamos al estado VALID_UNO

	when VALID_UNO =>		  -- Cuando llegamos al estado valid_uno
	 ST <= CERO;			  -- cambiamos al estado cero y volvemos a empezar
								  -- Misma din�mica que en VALID_CERO. En este caso
								  -- actualizamos VALID=1 y DATO =1 pero fuera del proceso.

	when VALID_FIN => 	  -- En el estado valid_fin 
	 reg<= cont;			  -- actualizamos el registro con el valor del contador 
	 cont <= "0000000000000000"; --y lo reiniciamos 
	 ST <= CERO;           -- y cambiamos de estado a cero para volver a empezar.
	 
	 
	 
	end case;
	end if;
	end process;

	-- PARTE COMBINACIONAL
	-- En esta parte declaramos las salidas de las se�ales VALID Y CERO mencionadas previamente durante el proceso. 
	-- Las salidas quedan en funci�n del estado en el que se encuentren, como dicta el diagrama de estados. 

	 -- En los estados valid_cero, valid_uno y valid_fin activamos la se�al VALID, en los dem�s la mantenemos a 0.
	VALID<='1' when (ST=VALID_CERO or ST=VALID_UNO or ST=VALID_FIN) else '0';

	-- En los estado CERO, ALM_CERO VALID_CERO Y VALID_FIN ponemos DATO a 0, y en los dem�s casos a 1.
	DATO <= '0' when (ST=CERO or ST =ALM_CERO or ST= VALID_CERO or ST =VALID_FIN) else '1';

	-- Almacena los 16 bits que llevan la cuenta del n�mero de ciclos de reloj. Como esta cuenta se almacena en "reg",
	-- asociamos su salida a dicho registro.  
	DURACION<= reg; 

	end Behavioral;

