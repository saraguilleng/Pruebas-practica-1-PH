;Función patron_volteo, versión arm - c
;Autores: Sara Guillén (743220), Samuel Bonito (725646)
;Fecha: 30/09/2020

PATRON_ENCONTRADO EQU 1
NO_HAY_PATRON     EQU 0

		AREA prog, CODE, READONLY
		EXPORT patron_volteo_arm_c
		EXTERN ficha_valida
		PRESERVE8 {TRUE}
			
		
patron_volteo_arm_c

		MOV		IP, SP ;Guarda estado de SP apuntando a parametros
		STMDB     SP!,{R4-R11,LR}    	;Preserva los registros de la funcion padre. +1 extra para espacio var local.
		MOV FP, IP ;Copia puntero a parámetros en FP
		PUSH {R1} ;Guarda en pila @Longitud
		SUB SP, #4 ;Espacio para var posicion_valida
		
		LDR  	  R10,[R1]				;Guarda la varible longitud, se cambiará durante la función de manera local en registro, y al acabar se guardará en memoria
		MOV       R4,R0
		LDMIA     FP,{R7-R9}            ;Guarda el resto de parametros en los registros r7,r8,r9

		;PARAMS: ;añadir regs temps
		; R0:= @Tablero
		; R1:= @Longitud
		; R2:= Fila (FA)
		; R3:= Columna (CA)
		; R4:= @Tablero
		; R7:= SF
		; R8:= SC
		; R9:= Color
		; R10:= Longitud
		;
		; R13:= SP = posición valida

			
		ADD       R2,R2,R7			;FA = FA + SF;   ;R5:= Fila (FA)
		AND       R5,R2,#0xFF		;Deja solo los 8 primeros bits
		ADD       R2,R3,R8  		;CA = CA + SC;   ;R6:= Columna (CA)
		AND       R6,R2,#0xFF
									
		


		;Llamada a ficha_valida.
		;Params entrada:
		;R0 = @Tablero
		;R1 = FA (fila a analizar)
		;R2 = CA (columna a analizar)
		;R3 = @Posicion_valida
		MOV       R3,SP
		MOV       R2,R6
		MOV       R1,R5
		MOV       R0,R4
		BL        ficha_valida
		MOV       R1,R0
		;Recoge resultado
		;R1 = ficha (0 si posicion valida es falso)
   
		B         while


 
bucle	ADD       R2,R5,R7       ;FA = FA + SF;
		AND       R5,R2,#0xFF
		ADD       R2,R6,R8		 ;CA = CA + SC; 
		AND       R6,R2,#0xFF
		ADD       R10,R10,#1	 ;*longitud = *longitud + 1; 


		
		;Llamada a ficha_valida.
		;Params entrada:
		;R0 = @Tablero
		;R1 = FA (fila a analizar)
		;R2 = CA (columna a analizar)
		;r3 = @Posicion_valida
		MOV       R3,SP
		MOV       R2,R6
		MOV       R1,R5
		MOV       R0,R4
		BL        ficha_valida
		MOV       R1,R0
		;Recoge resultado
		;R1 = ficha (0 si posicion valida es falso)


while	LDR       R2,[SP]
		CMP       R2,#1
		MOVNE     R0,#NO_HAY_PATRON
		BNE       if
		CMP       R1,R9
		BNE       bucle



if		CMP       R1,R9
		MOVNE     R0,#NO_HAY_PATRON
		BNE       fin
		
		CMP       R10,#0
		MOVLE     R0,#NO_HAY_PATRON
		MOVGT     R0,#PATRON_ENCONTRADO
		


fin	ADD SP, SP,#4 ;Quita espacio reservado para pos. valida.
		POP {R1}
		STR       R10,[R1]				;Guarda en memoria los cambios hechos en la varible longitud
	
		LDMIA     SP!,{R4-R11,LR}
		MOV PC,LR

		END