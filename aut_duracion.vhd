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
	-------- AUTÓMATA DE MEDIDA DE DURACIÓN DE CEROS Y UNOS ---
	--Autómata que calcula el numero de ciclos de reloj entre flancos consecutivos. 
	--La finalidad del módulo es calcular cuanto dura la señal a 0 y la señal a 1, del mensaje 
	--recibido. De esta forma podremos diferenciar, más adelante, si se trata de un punto, una raya,
	--o un espacio. 
	----------------------------------------------------------------------------------
	library IEEE;
	use IEEE.STD_LOGIC_1164.ALL;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;

	entity aut_duracion is
		 Port ( CLK_1ms : in  STD_LOGIC;    -- ENTRADA DE RELOJ
				  ENTRADA : in  STD_LOGIC;    -- ENTRADA DE DATOS
				  VALID : out  STD_LOGIC;     -- Señal de validacion que indica que el intervalo ha terminado, 
														-- es decir, que ha llegado a un flanco.
				  DATO : out  STD_LOGIC;      -- Valor binario que indica si se trata de un intervalo de 0 a 1
				  DURACION : out  STD_LOGIC_VECTOR (15 downto 0)); -- Registro de 16 bits que almacena el 
																					-- número de ciclos de reloj contados.
	end aut_duracion;

	architecture Behavioral of aut_duracion is

	type STATE_TYPE is (CERO,ALM_CERO,VALID_CERO,UNO,ALM_UNO,VALID_UNO,VALID_FIN);

	signal ST : STATE_TYPE := CERO;
	signal cont : STD_LOGIC_VECTOR (15 downto 0):="0000000000000000"; -- Señal auxiliar de 16 bits que utilizaremos para contar.
																							-- Los ciclos de reloj entre flancos cosecutivos.
	signal reg : STD_LOGIC_VECTOR (15 downto 0) :="0000000000000000"; -- Señal en la que vamos almacenando el resultado de esa cuenta.

		begin
	process (CLK_1ms) -- autómata
		begin
		if (CLK_1ms'event and CLK_1ms='1') then   -- En cada flanco de reloj
			case ST is        							
			
	when CERO =>  					-- En el estado 0 
		cont<=cont+1;				-- actualizamos el valor del contador.
			if (cont > 800) then -- EL VALOR NECESITA SER MAYOR QUE EL SÍMBOLO MÁS GRANDE, EN ESTE CASO LA SEPARACIÓN DE 700ns
										-- para que así pueda salir del bucle en caso de recibir ceros durante más de 800ns.
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
								  -- pero en este caso se pondrían a 1 y 0 respectivamente. 



	when UNO => 			   -- En el estado UNO 
		cont <= cont+1;	   -- actualizamos el contador.
	if (ENTRADA = '1') then -- Cuando la entrada es = 1 
		ST <= UNO;			   -- nos mantenemos en ese estado
	else 						   -- y si no 
		ST <= ALM_UNO;		   -- pasamos al estado ALM_UNO
	end if;  


		
		
	when ALM_UNO => 		  -- En el estado ALM_UNO
		reg <=cont;			  -- guardamos en el registro el valor del contador. 
		cont <= "0000000000000000";  -- Después reiniciamos el contador
		ST <= VALID_UNO;    -- y cambiamos al estado VALID_UNO

	when VALID_UNO =>		  -- Cuando llegamos al estado valid_uno
	 ST <= CERO;			  -- cambiamos al estado cero y volvemos a empezar
								  -- Misma dinámica que en VALID_CERO. En este caso
								  -- actualizamos VALID=1 y DATO =1 pero fuera del proceso.

	when VALID_FIN => 	  -- En el estado valid_fin 
	 reg<= cont;			  -- actualizamos el registro con el valor del contador 
	 cont <= "0000000000000000"; --y lo reiniciamos 
	 ST <= CERO;           -- y cambiamos de estado a cero para volver a empezar.
	 
	 
	 
	end case;
	end if;
	end process;

	-- PARTE COMBINACIONAL
	-- En esta parte declaramos las salidas de las señales VALID Y CERO mencionadas previamente durante el proceso. 
	-- Las salidas quedan en función del estado en el que se encuentren, como dicta el diagrama de estados. 

	 -- En los estados valid_cero, valid_uno y valid_fin activamos la señal VALID, en los demás la mantenemos a 0.
	VALID<='1' when (ST=VALID_CERO or ST=VALID_UNO or ST=VALID_FIN) else '0';

	-- En los estado CERO, ALM_CERO VALID_CERO Y VALID_FIN ponemos DATO a 0, y en los demás casos a 1.
	DATO <= '0' when (ST=CERO or ST =ALM_CERO or ST= VALID_CERO or ST =VALID_FIN) else '1';

	-- Almacena los 16 bits que llevan la cuenta del número de ciclos de reloj. Como esta cuenta se almacena en "reg",
	-- asociamos su salida a dicho registro.  
	DURACION<= reg; 

	end Behavioral;

