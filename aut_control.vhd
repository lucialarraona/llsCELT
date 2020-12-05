	----------------------------------------------------------------------------------
	-- Company: 
	-- Engineer: 
	-- 
	-- Create Date:    23:07:25 11/09/2018 
	-- Design Name: 
	-- Module Name:    aut_control - Behavioral 
	-- Project Name: 
	-- Target Devices: 
	-- Tool versions: 
	-- Description: 
	-- Additional Comments: 
	---------------------------------------------------------------------------------
	--------------- AUTOMATA DE CONTROL ----------------
	-- Módulo encargado de componer el código del mensaje y validarlo cuando aparece un
	-- espacio, para que pueda mostrarse en el display de la FPGA
	----------------------------------------------------------------------------------
	library IEEE;
	use IEEE.STD_LOGIC_ARITH.ALL;
	use IEEE.STD_LOGIC_UNSIGNED.ALL;
	use IEEE.STD_LOGIC_1164.ALL;

	entity aut_control is
		 Port ( CLK_1ms : in  STD_LOGIC; -- Entrada de la señal de reloj
				  VALID : in  STD_LOGIC; 	-- Entrada VALID y DATO que se activan según dicta el autómata 
				  DATO : in  STD_LOGIC;	   -- de duración.
				  C0 : in  STD_LOGIC;      -- Entrada para la salida del comparador 0.
				  C1 : in  STD_LOGIC;    	-- Entrada para la salida del comparador 1.
				  
				  C2 : in STD_LOGIC;  		-- NUEVA ENTRADA PARA LA SALIDA DEL COMPARADOR 2.
				  
				  BTN2: in STD_LOGIC;		-- NUEVA ENTRADA PARA LA SEÑAL EXTERNA RESET.
				  
				  CODIGO  : out  STD_LOGIC_VECTOR (7 downto 0); -- Código de 7 bits que después se envía al display
																				-- para poder visualizarlo
				  VALID_DISP : out  STD_LOGIC); -- Salida hacia el display para validar su activación.
	end aut_control;

	architecture Behavioral of aut_control is

	type STATE_TYPE is (ESPACIO,RESET,SIMBOLO,ESPERA, SEPARACION1,SEPARACION2); -- AÑADIMOS DOS NUEVOS ESTADOS

	signal ST : STATE_TYPE := RESET;
	-- el codigo de salida tiene 7 bits, pero lo dividimos en 2 trozos para manejarlos dentro 
	-- del proceso de manera más sencilla
	signal s_ncod : STD_LOGIC_VECTOR (2 downto 0):="000"; -- Los 3 bits  más significativos de código.
	signal s_cod : STD_LOGIC_VECTOR (4 downto 0):="00000"; -- Los ultimos 5 bits de código.
	signal n : INTEGER range 0 to 4; -- Entero n con el que definiremos la posicion del bit dentro de código


		begin
			process (CLK_1ms,BTN2) -- Metemos el CLK Y BTN2 en la lista de sensibilidad	
			begin	
				if ( BTN2 = '1') then  -- Cuando accionamos el pulsador BTN2,
			s_ncod <= "100";			  -- apagamos todos los displays con la letra X.
			s_cod <= "10010";
		
			ST <= ESPACIO;					-- Y pasamos al estado ESPACIO, puesto que desde ahí vamos directos al RESET.
	
			elsif (CLK_1ms'event and CLK_1ms='1') then -- Los cambios de estado son síncronos con los flancos de subida del reloj
		case ST is   										 
		
			when SIMBOLO =>		 -- En el estado SIMBOLO:
				s_ncod<=s_ncod+1;  -- Incrementa el valor de los 3 bits más significativos del código
										 -- a los que hemos denominado s_ncod.
				s_cod(n)<=C1;      -- El resultado del comparador indica punto o raya (C1) y 
										 -- lo coloca en la posición n del código.
				n<=n-1;				 -- Decrementa n en una unidad para poder almacenar el siguiente valor de C1 
										 -- en caso de que aparezca otro símbolo.
				ST<=ESPERA;			 -- Pasa al estado espera.
				


			when RESET => 			 -- En el estado de RESET. (ESTADO INICIAL DEL AUTÓMATA DE CONTROL)
				n <= 4;				 -- El integer n vuelve al valor 4. 
				s_ncod<="000";		 -- Reiniciamos el valor del código
				s_cod<="00000";    -- a cero. 
				
		if (VALID='1' and DATO='1') then  --Si efectivamente valid y dato están a 1, 
													 --volvemos al estado de símbolo
			ST<=SIMBOLO;
		else
			ST<=RESET;							 -- si no, volvemos al estado reset
	end if;

	when ESPERA =>  -- En el estado ESPERA puede alcanzar todos los estados definidos previamente: 
		
		if (VALID = '1' and DATO = '0' and C2 = '1' and C0 ='1') then  -- Si VALID = 1, DATO = 0 , C0= 1, C2 = 1
		ST <= SEPARACION1;															-- pasamos al nuevo estado SEPARACION1. 
		
		elsif (VALID ='1' and DATO ='1') then			 						-- Si VALID = 1, DATO = 1 pasamos al estado
		ST <= SIMBOLO;											  						-- símbolo. 

		elsif (VALID = '1' and DATO = '0' and C0 ='1'and C2 ='0') then -- Si VALID = 1, DATO = 0 y C0 = 1, C2 = 0
	   ST <= ESPACIO;											 						-- pasamos al estado ESPACIO
		
		elsif (VALID='1' and DATO='0' and C0='0' and C2 ='0') then   	-- Volvemos al estado ESPERA si se cumplen estas
		ST <= ESPERA;											 						-- condiciones a la vez 
		
		elsif ( VALID = '0') then							 						-- o también si VALID = 0, directamente. 
		ST <= ESPERA;											 
		
	end if; 

	when ESPACIO =>																	-- Desde el estado ESPACIO, pasamos directamente a RESET
		ST <= RESET;
		
	when SEPARACION1 => 																-- Desde SEPARACIÓN1, siempre llegamos a SEPARACION2
		ST <= SEPARACION2; 
		
		
	when SEPARACION2 =>																-- En el estado SEPARACION2 utilizamos el código de la
	s_ncod <= "100";																	-- letra X para introducir un espacio en blanco
	s_cod <= "10010"; 																-- Y pasamos al estado ESPACIO que nos lleva directamente 
																							-- al RESET
	 ST <=ESPACIO; 
	 

	end case;
	end if;
	end process;


	-- PARTE COMBINACIONAL
	-- En esta parte el objetivo es asignar las salidas del autómata dependiendo del estado en el que nos encontremos.

	-- Solo activamos el valid_disp cuando estamos en el estado ESPACIO, estado en el que validamos la palabra. 
	-- Para la mejora1 es necesario establecer que SEPARACION1 valide también el display. 
	
	VALID_DISP<='0' when (ST = SIMBOLO or ST= RESET or ST=ESPERA or ST = SEPARACION2) else '1';
	 
	-- Y asignamos a los bits correspondientes del código su correspondiente señal auxiliar.

	CODIGO(4 downto 0)<= s_cod;  -- Los bits que almacenan la salida de las comparaciones. 
	CODIGO(7 downto 5)<= s_ncod; -- Los tres bits mas sigificatvos que habíamos definido en s_ncod y
										  -- en los que almacenamos la cuenta de cuantos símbolos detectado.


	end Behavioral;

	