@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: dickinson.bedoya@estudiants.urv.cat				  ===
@;=== Programador tarea 1F:	dickinson.bedoya@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm




@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@;	repeticiones del elemento situado en la posición (f,c) de la matriz, 
@;	visitando las siguientes posiciones según indique el parámetro de
@;	orientación 'ori'.
@;	Restricciones:
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;		* la primera posición también se tiene en cuenta, de modo que el número
@;			mínimo de repeticiones será 1, es decir, el propio elemento de la
@;			posición inicial
@;	Parámetros:
@;		R0 = dirección base de la matriz
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@;	Resultado:
@;		R0 = número de repeticiones detectadas (mínimo 1)
	.global cuenta_repeticiones
cuenta_repeticiones:
		push {r1-r2, r4-r12, lr}
		
		mov r5, #COLUMNS
		mla r6, r1, r5, r2		@;R6 calculo del indice de la matriz
		add r4, r0, r6			@;R4 apunta al elemento (f,c) de 'mat'
		ldrb r5, [r4]			@;elem1
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		mov r10, r0				@;asignar a r10 la matriz para cambiar el registro para el numero de repeticiones
		mov r0, #1				@;R0 = número de repeticiones
		mov r8, #COLUMNS
		cmp r3, #0
		beq .Lconrep_este
		cmp r3, #1
		beq .Lconrep_sur
		cmp r3, #2
		beq .Lconrep_oeste
		cmp r3, #3
		beq .Lconrep_norte
		b .Lconrep_fin
		

@; CÓDIGO PARA CONTAR LAS REPETICIONES EN CADA ORIENTACIÓN
		.Lconrep_este:
			mov r11, #COLUMNS
			sub r11, r11, #1
			mla r7, r1, r8, r11		@;calculo de la posicion final --> r7 = pos = (f*dim)+8
			add r11, r6, #1			@;r11 es indice + 1. Esto sirve para entrar en la siguiente posicion de la matriz
			add r4, r10, r11		@;R4 apunta al elemento(f,c) de la matriz
			ldrb r9, [r4] 			@;elem2
			and r9, #7				@;r9 es el valor filtrado
			cmp r6, r7				@;comparar indices
			beq .Lconrep_fin			
			
			@;while
			.LWhileEste:
				cmp r9,	#0			
				beq .Lconrep_fin
				cmp r9,	#7			
				beq .Lconrep_fin
				cmp r5,r9			@;comparar elementos
				bne .Lconrep_fin
				.LcontinuaEste:
					cmp r5, r9
					bne .Lconrep_fin
					add r0, #1
					add r6, r6, #1		@;incrementar en 1 el indice
					cmp r6, r7	
					beq .Lconrep_fin
					bne .LsiguienteE
					.LsiguienteE:
						add r11, r6, #1
						add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
						ldrb r9, [r4] 		@;elem2
						and r9, #7			@;r9 es el valor filtrado
						cmp r9,	#0			
						beq .Lconrep_fin
						cmp r9,	#7			
						beq .Lconrep_fin			
						bne .LcontinuaEste
		@;-------------------------------------------------
			
		.Lconrep_sur:
			mov r11, #COLUMNS-1
			@;sub r11, r11, #1
			mla r7,r11,r8,r2	@;calculo de la posicion final --> r7 = pos = (f*dim)+0
			add r11, r6, #COLUMNS @;r11 es indice + 9. Esto sirve para entrar en la siguiente posicion de la matriz
			add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
			ldrb r9, [r4] 		@;elem2
			and r9, #7			@;r9 es el valor filtrado
			cmp r6, r7
			beq .Lconrep_fin
			
			@;while
			.LWhileSur:
				cmp r9,	#0			
				beq .Lconrep_fin
				cmp r9,	#7			
				beq .Lconrep_fin
				cmp r5,r9			@;comparar elementos
				bne .Lconrep_fin
				.LcontinuaSur:
					cmp r5, r9
					bne .Lconrep_fin
					add r0, #1
					add r6, r6, #COLUMNS
					cmp r6, r7	
					beq .Lconrep_fin
					bne .LsiguienteS
				.LsiguienteS:
						add r11, r6, #COLUMNS
						add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
						ldrb r9, [r4] 		@;elem2
						and r9, #7			@;r9 es el valor filtrado
						cmp r9,	#0			
						beq .Lconrep_fin
						cmp r9,	#7			
						beq .Lconrep_fin			
						bne .LcontinuaSur
						
		@;-------------------------------------------------
		
		.Lconrep_oeste:
			mov r11, #0
			mla r7,r1,r8, r11	@;calculo de la posicion final --> r7 = pos = (f*dim)+8
			sub r11, r6, #1		@;r11 es indice - 1. Esto sirve para entrar en la siguiente posicion de la matriz
			add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
			ldrb r9, [r4] 		@;elem2
			and r9, #7			@;r9 es el valor filtrado
			cmp r6, r7
			beq .Lconrep_fin		
			
			@;while
			.LWhileOeste:
				cmp r9,	#0			
				beq .Lconrep_fin
				cmp r9,	#7			
				beq .Lconrep_fin
				cmp r5,r9			@;comparar elementos
				bne .Lconrep_fin
				.LcontinuaOeste:
					cmp r5, r9
					bne .Lconrep_fin
					add r0, #1
					sub r6, r6, #1		
					cmp r6, r7	
					beq .Lconrep_fin
					bne .LsiguienteO
					.LsiguienteO:
						sub r11, r6, #1
						add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
						ldrb r9, [r4] 		@;elem2
						and r9, #7			@;r9 es el valor filtrado
						cmp r9,	#0			
						beq .Lconrep_fin
						cmp r9,	#7			
						beq .Lconrep_fin			
						bne .LcontinuaOeste

		@;-------------------------------------------------
			
		.Lconrep_norte:
			mov r11, #0
			mla r7,r11,r8,r2	@;calculo de la posicion final --> r7 = pos = (f*dim)+8
			sub r11, r6, #COLUMNS @;r11 es indice - 9. Esto sirve para entrar en la siguiente posicion de la matriz
			add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
			ldrb r9, [r4] 		@;elem2
			and r9, #7			@;r9 es el valor filtrado
			cmp r6, r7
			beq .Lconrep_fin
			
			@;while
			.LWhileNorte:
				cmp r9,	#0			
				beq .Lconrep_fin
				cmp r9,	#7			
				beq .Lconrep_fin
				cmp r5,r9			@;comparar elementos
				bne .Lconrep_fin
				.LcontinuaNorte:
					cmp r5, r9
					bne .Lconrep_fin
					add r0, #1
					sub r6, r6, #COLUMNS
					cmp r6, r7	
					beq .Lconrep_fin
					bne .LsiguienteN
				.LsiguienteN:
						sub r11, r6, #COLUMNS
						add r4,r10,r11		@;R4 apunta al elemento(f,c) de la matriz
						ldrb r9, [r4] 		@;elem2
						and r9, #7			@;r9 es el valor filtrado
						cmp r9,	#0			
						beq .Lconrep_fin
						cmp r9,	#7			
						beq .Lconrep_fin			
						bne .LcontinuaNorte
		
		.Lconrep_fin:
		
		pop {r1-r2, r4-r12, pc}



@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en sentido inclinado; cada llamada a
@;	la función sólo baja elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si está todo quieto.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina 'mod_random' (ver fichero
@;			"candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que puede que
@;				queden movimientos pendientes. 
	.global baja_elementos
baja_elementos:
		push {r1-r12, lr}
		
		mov r4, r0
		bl baja_verticales
		cmp r0, #1
		beq .LfinElementos
		
		bl baja_laterales
			
		.LfinElementos:
		pop {r1-r12, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 

baja_verticales:
		push {r1-r3, r5-r10,lr}
		
		mov r0, #0				@;incializar el resultado a 0, si se mueven elementos se cambia a 1
		mov r1, #ROWS-1 		@;r1 es f = 8
		mov r2, #COLUMNS-1		@;r2 es c = 8
		mov r10, #ROWS*COLUMNS 	@;r10 es el indice
		sub r10, #1
		
		cmp r10, #ROWS - 1
		ble .LfinVerticales
		.LWhileVerticales:
			
			add r9, r4, r10 	@;r2 apunta a la posicion de (f,c) de la matriz
			ldrb r9, [r9] 	@; r2 es el elemento de la matriz 	
			cmp r9, #0 		@; if(elemento == 0) --> mirar si se puede bajar elemento
			beq .LTratarZero
			cmp r9, #8
			beq .LTratarOcho
			cmp r9, #16
			beq .LTratar16
			
			.LcontinuaVerticales:
				bl modificaIndice
				sub r10, #1
				cmp r10, #ROWS - 1
				ble .LfinVerticales
				b .LWhileVerticales
			@;---------------------------
			
			.LTratarZero:
				sub r8, r10, #ROWS @;r8 es el indice - FILAS
				add r3, r4, r8
				ldrb r3, [r3]	@;elemento de arriba
				cmp r3, #15
				beq .LBajarDosZero
				cmp r3, #7
				beq .LPonerZero
				and r3, #7
				cmp r3, #0
				bne .LBajarUnoZero
				b .LcontinuaVerticales
				@;-------------------------------
				.LBajarUnoZero:			
					bl convertirEnSimple
					
					strb r3, [r10,r4] 	@;matriz[indice] = arriba;
					strb r5, [r8, r4] 	@;matriz[indice - 9] = 0;
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					mov r0, #1
					b .LcontinuaVerticales
				@;-------------------------------
				.LBajarDosZero:
					sub r8, #ROWS
					add r3, r4, r8
					ldrb r3, [r3] @;elemento de arriba
					cmp r3, #0
					beq .LcontinuaVerticales
					cmp r3, #7
					beq .LcontinuaVerticales
					cmp r3, #15
					beq .LBajarDosZero
					
					bl convertirEnSimple
					
					strb r3, [r10, r4]
					strb r5, [r8,r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .LcontinuaVerticales
				
				@;-------------------------------
			.LTratarOcho:
				sub r8, r10, #ROWS @;r8 es el indice - 9
				add r3, r4, r8
				ldrb r3, [r3]	@;elemento de arriba
				cmp r3, #15
				beq .LBajarDosOcho
				cmp r3, #7
				beq .LPoner8
				and r3, #7
				cmp r3, #0
				bne .LBajarUnoOcho
				b .LcontinuaVerticales	
				@;-------------------------------
				.LBajarUnoOcho:
					bl convertirEnGelatinaSimple 	@;llamar a rutina para cambiar a gelatinas simples
					strb r3, [r10,r4] 				@;matriz[indice] = arriba;
					strb r5, [r8, r4] 				@;matriz[indice - 9] = 0;
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .LcontinuaVerticales
				@;-------------------------------
				.LBajarDosOcho:
					sub r8, #ROWS
					add r3, r4, r8
					ldrb r3, [r3] 		@;elemento de arriba
					cmp r3, #0
					beq .LcontinuaVerticales
					cmp r3, #7
					beq .LBajarDosOcho
					
					bl convertirEnGelatinaSimple	@;llamar a rutina para cambiar a gelatinas simples
					
					strb r3, [r10, r4]
					strb r5, [r8,r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .LcontinuaVerticales
				
				@;-------------------------------
			.LTratar16:
				sub r8, r10, #ROWS @;r8 es el indice - 9
				add r3, r4, r8
				ldrb r3, [r3]	@;elemento de arriba
				cmp r3, #15
				beq .LBajarDos16
				cmp r3, #7
				beq .LPoner16
				and r3, #7
				cmp r3, #0
				bne .LBajarUno16
				b .LcontinuaVerticales
				@;-------------------------------
				.LBajarUno16:
					bl convertirEnGelatinaDoble	@;llamar a rutina para cambiar a gelatinas dobles
					strb r3, [r10,r4] 	@;matriz[indice] = arriba;
					strb r5, [r8, r4] 	@;matriz[indice - 18] = 0;
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .LcontinuaVerticales
				@;-------------------------------
				.LBajarDos16:
					sub r8, #ROWS
					add r3, r4, r8
					ldrb r3, [r3] 		@;elemento de arriba
					cmp r3, #0
					beq .LcontinuaVerticales
					cmp r3, #7
					beq .LBajarDos16
					
					bl convertirEnGelatinaDoble	@;llamar a rutina para cambiar a gelatinas dobles
					
					strb r3, [r10, r4]
					strb r5, [r8,r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					mov r0, #1
					b .LcontinuaVerticales
		
		.LPonerZero:
			mov r3, #0
			strb r3, [r10, r4] @;matriz[indice] = 0;
			b .LcontinuaVerticales
		
		.LPoner8:
			mov r3, #8
			strb r3, [r10, r4] @;matriz[indice] = 0;
			b .LcontinuaVerticales
		
		.LPoner16:
			mov r3, #16
			strb r3, [r10, r4] @;matriz[indice] = 0;
			b .LcontinuaVerticales
		
		@;-------------------------------
		.LfinVerticales:
			bl colocaNuevosElementos
		pop {r1-r3, r5-r10,pc}

@;--------------------------------------------------
@;rutinas mias para poder reducir codigo
	
@;	r3 --> entero a modificar
@;Resultado
@;	r3 -->entero modificado
@;	r5 -->casilla modificada
convertirEnSimple:
	push {r0-r2, lr}
	
	cmp r3, #7
	blt .LEsSimple
	cmp r3, #16
	bgt .LZeroGrande
	cmp r3, #15
	blt .LZeroPequenyo
					
	.LZeroGrande:
		and r3, #7
		mov r5, #16
		b .LfinSimple
	.LZeroPequenyo:
		and r3, #7
		mov r5, #8
		b .LfinSimple
	.LEsSimple:
		mov r5, #0
		b .LfinSimple
	.LfinSimple:

	pop {r0-r2, pc}

@;	r3 --> entero a modificar
@;Resultado
@;	r3 -->entero modificado
@;	r5 -->casilla modificada
convertirEnGelatinaSimple:
	push {r0-r2, lr}
	
	cmp r3, #8
	blt .LOchoPequenyo
	cmp r3, #15
	blt .LGelatinaSimple
	bgt .LOchoGrande
					
	.LOchoGrande:
		sub r3, #8
		mov r5, #16
		b .LfinGel8
	.LOchoPequenyo:
		add r3, #8
		mov r5, #0
		b .LfinGel8
	.LGelatinaSimple:
		mov r5, #8
		b .LfinGel8
	.LfinGel8:
	pop {r0-r2, pc}

@;	r3 --> entero a modificar
@;Resultado
@;	r3 -->entero modificado
@;	r5 -->casilla modificada
convertirEnGelatinaDoble:
	push {r0-r2, lr}
	
	cmp r3, #16
	bgt .LGelatinaDoble
	blt .L16Pequenyo
					
	.L16Pequenyo:
		cmp r3, #7
		blt .L16MasPequenyo
		b .LGELsimple
		
	.LGELsimple:
		add r3, #7
		mov r5, #8
		b .LfinGel16
	.L16MasPequenyo:
		add r3, #16
		mov r5, #0
		b .LfinGel16
	.LGelatinaDoble:
		mov r5, #16
		b .LfinGel16
	.LfinGel16:
	pop {r0-r2, pc}

@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función sólo baja elementos una posición y
@;	devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento. 
baja_laterales:
		push {r1-r3, r5-r12,lr}
		
		mov r1, #ROWS-1
		mov r2, #COLUMNS-1
		mov r10, #ROWS*COLUMNS @;r10 es el indice
		sub r10, #1
		cmp r10, #COLUMNS	
		bLe .LfinLaterales
		@;--------------------------------
		.LWhileLaterales:
			add r5, r4, r10
			ldrb r5, [r5]	@;r5 es elem1
			cmp r5,#0
			beq .LContinuaZero
			cmp r5, #8
			beq .LContintua8
			cmp r5, #16
			beq .LContinua16
		
			.Lcontinua:
				@;decrementar f y c
				bl modificaIndice
				sub r10, #1
				cmp r10, #ROWS - 1
				ble .LfinLaterales
				b .LWhileLaterales
		@;--------------------------------
		
			.LContinuaZero:
				@;tratar para elementos simples
				cmp r2, #8
				beq .L0BordeDerecho
				cmp r2, #0
				beq .L0BordeIzquierdo
				bne .L0Enmedio
			.LContintua8:
				@;tratar para gelatinas simples
				cmp r2, #8
				beq .L8BordeDerecho
				cmp r2, #0
				beq .L8BordeIzquierdo
				bne .L8Enmedio
			.LContinua16:
				@;tratar para gelatinas dobles
				cmp r2, #8
				beq .L16BordeDerecho
				cmp r2, #0
				beq .L16BordeIzquierdo
				bne .L16Enmedio
		
		@;--------------------------------
			.L0BordeDerecho:
				sub r6, r10, #ROWS + 1
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				cmp r7, #0
				beq .Lcontinua
				cmp r7, #7
				beq .Lcontinua
				cmp r7, #15
				beq .Lcontinua
				cmp r7, #8
				beq .Lcontinua
				cmp r7, #16
				beq .Lcontinua
				
				bl convertirEnSimpleLaterales
				strb r7, [r10, r4]
				strb r8, [r6, r4]
				
				sub r0, r1, #ROWS	@;fila del elemento
				mov r11, r1 		@;guardar fila
				sub r1, r2, #COLUMNS@;columna del elemento
				mov r12, r2
					
				mov r2, r11
				mov r3, r12
					
				bl activa_elemento
				mov r0, #1
				mov r1, r11
				mov r2, r12
				b .Lcontinua
				
			.L0BordeIzquierdo:
				sub r6, r10, #ROWS - 1	
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				cmp r7, #0
				beq .Lcontinua
				cmp r7, #7
				beq .Lcontinua
				cmp r7, #15
				beq .Lcontinua
				cmp r7, #8
				beq .Lcontinua
				cmp r7, #16
				beq .Lcontinua
				
				bl convertirEnSimpleLaterales
				strb r7, [r10, r4]
				strb r8, [r6, r4]
				
				sub r0, r1, #ROWS	@;fila del elemento
				mov r11, r1 		@;guardar fila
				sub r1, r2, #COLUMNS@;columna del elemento
				mov r12, r2
					
				mov r2, r11
				mov r3, r12
					
				bl activa_elemento
				mov r0, #1
				mov r1, r11
				mov r2, r12
				b .Lcontinua
				
			.L0Enmedio:
				@;comprobar primero arriba derecha
				sub r6, r10, #ROWS - 1	
				add r7, r4, r6				@;r7 es elem2
				ldrb r7, [r7]
				mov r9, r7					@;guardar en r9 el elemento
				and r9, #7
				cmp r9, #0
				beq .LArribaIzquierda
				cmp r9, #7
				beq .LArribaIzquierda
				bne .LArribaDerecha
				.LArribaDerecha:
					
					bl convertirEnSimpleLaterales
					strb r7, [r10, r4]
					strb r8, [r6, r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .Lcontinua
					
				.LArribaIzquierda:
					sub r6, r10, #ROWS + 1	
					add r7, r4, r6		@;r7 es elem2
					ldrb r7, [r7]
					mov r9, r7
					and r9, #7
					cmp r9, #0
					beq .Lcontinua
					cmp r9, #7
					beq .Lcontinua
					bl convertirEnSimpleLaterales
					strb r7, [r10, r4]
					strb r8, [r6, r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .Lcontinua
		@;--------------------------------	
			.L8BordeDerecho:
				sub r6, r10, #ROWS + 1	@;r6 es indice - 10
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				cmp r7, #0
				beq .Lcontinua
				cmp r7, #7
				beq .Lcontinua
				cmp r7, #15
				beq .Lcontinua
				cmp r7, #8
				beq .Lcontinua
				cmp r7, #16
				beq .Lcontinua
				
				bl convertirEnGelatinaSimpleLateral
				strb r7, [r10, r4]
				strb r8, [r6, r4]
				
				sub r0, r1, #ROWS	@;fila del elemento
				mov r11, r1 		@;guardar fila
				sub r1, r2, #COLUMNS@;columna del elemento
				mov r12, r2
				
				mov r2, r11
				mov r3, r12
					
				bl activa_elemento
				mov r0, #1
				mov r1, r11
				mov r2, r12
				b .Lcontinua
				
			.L8BordeIzquierdo:
				sub r6, r10, #ROWS - 1		@;r6 es indice - 8
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				cmp r7, #0
				beq .Lcontinua
				cmp r7, #7
				beq .Lcontinua
				cmp r7, #15
				beq .Lcontinua
				cmp r7, #8
				beq .Lcontinua
				cmp r7, #16
				beq .Lcontinua
				
				bl convertirEnGelatinaSimpleLateral
				strb r7, [r10, r4]
				strb r8, [r6, r4]
				
				sub r0, r1, #ROWS	@;fila del elemento
				mov r11, r1 		@;guardar fila
				sub r1, r2, #COLUMNS@;columna del elemento
				mov r12, r2
					
				mov r2, r11
				mov r3, r12
					
				bl activa_elemento
				mov r0, #1
				mov r1, r11
				mov r2, r12
				b .Lcontinua
			.L8Enmedio:
				sub r6, r10, #ROWS - 1		
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				mov r9, r7
				and r9, #7
				cmp r9, #0
				beq .LArribaIzquierda8
				cmp r9, #7
				beq .LArribaIzquierda8
				bne .LArribaDerecha8
				
				.LArribaDerecha8:
					
					bl convertirEnGelatinaSimpleLateral
					strb r7, [r10, r4]
					strb r8, [r6, r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .Lcontinua
					
				.LArribaIzquierda8:
					sub r6, r10, #ROWS + 1	@;r6 es indice - 10
					add r7, r4, r6		 @;r7 es elem2
					ldrb r7, [r7]
					mov r9, r7
					and r9, #7
					cmp r9, #0
					beq .Lcontinua
					cmp r9, #7
					beq .Lcontinua
					bl convertirEnGelatinaSimpleLateral
					strb r7, [r10, r4]
					strb r8, [r6, r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .Lcontinua
		@;--------------------------------
			.L16BordeDerecho:
				sub r6, r10, #ROWS+1	@;r6 es indice - 10
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				cmp r7, #0
				beq .Lcontinua
				cmp r7, #7
				beq .Lcontinua
				cmp r7, #15
				beq .Lcontinua
				cmp r7, #8
				beq .Lcontinua
				cmp r7, #16
				beq .Lcontinua
				
				bl convertirEnGelatinaDobleLateral
				strb r7, [r10, r4]
				strb r8, [r6, r4]
				
				sub r0, r1, #ROWS	@;fila del elemento
				mov r11, r1 		@;guardar fila
				sub r1, r2, #COLUMNS@;columna del elemento
				mov r12, r2
					
				mov r2, r11
				mov r3, r12
					
				bl activa_elemento
				mov r0, #1
				mov r1, r11
				mov r2, r12
				b .Lcontinua
				
			.L16BordeIzquierdo:
				sub r6, r10, #ROWS-1		@;r6 es indice - 8
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				cmp r7, #0
				beq .Lcontinua
				cmp r7, #7
				beq .Lcontinua
				cmp r7, #15
				beq .Lcontinua
				cmp r7, #8
				beq .Lcontinua
				cmp r7, #16
				beq .Lcontinua
				
				bl convertirEnGelatinaDobleLateral
				strb r7, [r10, r4]
				strb r8, [r6, r4]
				
				sub r0, r1, #ROWS	@;fila del elemento
				mov r11, r1 		@;guardar fila
				sub r1, r2, #COLUMNS@;columna del elemento
				mov r12, r2
					
				mov r2, r11
				mov r3, r12
					
				bl activa_elemento
				mov r0, #1
				mov r1, r11
				mov r2, r12
				b .Lcontinua
			.L16Enmedio:
				sub r6, r10, #ROWS-1		@;r6 es indice - 8
				add r7, r4, r6		@;r7 es elem2
				ldrb r7, [r7]
				mov r9, r7
				and r9, #7
				cmp r9, #0
				beq .LArribaIzquierda16
				cmp r9, #7
				beq .LArribaIzquierda16
				bne .LArribaDerecha16
				
				.LArribaDerecha16:
					
					bl convertirEnGelatinaDobleLateral
					strb r7, [r10, r4]
					strb r8, [r6, r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .Lcontinua
					
				.LArribaIzquierda16:
					sub r6, r10, #ROWS+1	@;r6 es indice - 10
					add r7, r4, r6		@;r7 es elem2
					ldrb r7, [r7]
					mov r9, r7
					and r7, #7
					cmp r7, #0
					beq .Lcontinua
					cmp r7, #7
					beq .Lcontinua
					bl convertirEnGelatinaDobleLateral
					strb r9, [r10, r4]
					strb r8, [r6, r4]
					
					sub r0, r1, #ROWS	@;fila del elemento
					mov r11, r1 		@;guardar fila
					sub r1, r2, #COLUMNS@;columna del elemento
					mov r12, r2
					
					mov r2, r11
					mov r3, r12
					
					bl activa_elemento
					mov r0, #1
					mov r1, r11
					mov r2, r12
					b .Lcontinua
		@;--------------------------------
		.LfinLaterales:
		
		pop {r1-r3, r5-r12,pc}
	
@;rutina para modificar el indice
@;parametros
@;	r1 --> fila, r2 -->columna
@;resultado
@;	r1 --> indice
	
modificaIndice:
		push {r4-r9,lr}
		
		cmp r2, #0
		bgt .LdecrementaColumna
		beq .Lcoloca8Columna
		
		.LdecrementaColumna:
			sub r2, #1
			b .LfinIndice
			
		.Lcoloca8Columna:
			mov r2, #ROWS-1
			b .LdecrementaFila
			
		.LdecrementaFila:
			sub r1, #1
			b .LfinIndice
			
		.LfinIndice:
			
		pop {r4-r9,pc}
		
@;	r7 --> entero a modificar
@;Resultado
@;	r7 -->entero modificado
@;	r8 -->casilla modificada
convertirEnSimpleLaterales:
	push {r0-r6,r9-r10, lr}
	
	cmp r7, #7
	blt .LEsSimpleLateral
	cmp r7, #16
	bgt .LZeroGrandeLateral
	cmp r7, #15
	blt .LZeroPequenyoLateral
					
	.LZeroGrandeLateral:
		and r7, #7
		mov r8, #16
		b .LfinSimpleLateral
	.LZeroPequenyoLateral:
		and r7, #7
		mov r8, #8
		b .LfinSimpleLateral
	.LEsSimpleLateral:
		mov r8, #0
		b .LfinSimpleLateral
	.LfinSimpleLateral:

	pop {r0-r6,r9-r10, pc}

@;	r7 --> entero a modificar
@;Resultado
@;	r7 -->entero modificado
@;	r8 -->casilla modificada

convertirEnGelatinaSimpleLateral:
	push {r0-r6,r9-r10, lr}
	
	cmp r7, #8
	blt .LOchoPequenyoLateral
	cmp r7, #15
	blt .LGelatinaSimpleLateral
	bgt .LOchoGrandeLateral
					
	.LOchoGrandeLateral:
		sub r7, #8
		mov r8, #16
		b .LfinGel8Lateral
	.LOchoPequenyoLateral:
		add r7, #8
		mov r8, #0
		b .LfinGel8Lateral
	.LGelatinaSimpleLateral:
		mov r8, #8
		b .LfinGel8Lateral
	.LfinGel8Lateral:
	pop {r0-r6,r9-r10, pc}

@;	r7 --> entero a modificar
@;Resultado
@;	r7 -->entero modificado
@;	r8 -->casilla modificada

convertirEnGelatinaDobleLateral:
	push {r0-r6,r9-r10, lr}
	
	cmp r7, #16
	bgt .LGelatinaDobleLateral
	blt .L16PequenyoLateral
					
	.L16PequenyoLateral:
		cmp r7, #7
		blt .L16MasPequenyoLateral
		b .LGELsimpleLateral
		
	.LGELsimpleLateral:
		add r7, #7
		mov r8, #8
		b .LfinGel16Lateral
	.L16MasPequenyoLateral:
		add r7, #16
		mov r8, #0
		b .LfinGel16Lateral
	.LGelatinaDobleLateral:
		mov r8, #16
		b .LfinGel16Lateral
	.LfinGel16Lateral:
	pop {r0-r6,r9-r10, pc}
	
@;	r4 --> matriz a modificar
@;Resultado
@;	r4 --> matriz modificada

colocaNuevosElementos:
	push {r1-r3, r5-r12,lr}
	
		mov r1, #0	@;fila
		mov r2, #0	@;columna	
		mov r3, #COLUMNS
		mla r9, r1, r3, r2 
		cmp r2, #COLUMNS - 1
		bgt .Lfin
		
		.LWhile:
			add r5, r4, r9
			ldrb r5, [r5]	
			cmp r5,#0
			beq .LZero
			cmp r5, #8
			beq .L8
			cmp r5, #16
			beq .L16
			bne .LbajaFila
		
			.LbajaFila:
				add r1, #1
				mla r9, r1, r3, r2 
				add r5, r4, r9
				ldrb r5, [r5]	
				cmp r5,#0
				beq .LZero
				cmp r5, #8
				beq .L8
				cmp r5, #16
				beq .L16
				cmp r1, #8
				beq .Lcont
				b .LbajaFila
			.Lcont:
				mov r1, #0
				add r2, #1
				mla r9, r1, r3, r2 
				cmp r2, #COLUMNS - 1
				bgt .Lfin
				b .LWhile
		
		@;-------------------------
		
		.LZero:
			cmp r1, #1
			blt .LconZero
			bl comprueba_arriba
			cmp r12, #1
			beq .LconZero
			bne .Lcont
			.LconZero:
				mov r0, #7
				bl mod_random
				cmp r0, #0
				beq .LZero
				strb r0, [r9, r4]
				bl crea_elemento		@;fila y columna en sus respectivos registros, tipo de elemento en r0
				mov r0, #1
				b .Lcont
		
		@;-------------------------
		.L8:
			cmp r1, #1
			blt .Lcon8
			bl comprueba_arriba
			cmp r12, #1
			beq .Lcon8
			bne .Lcont
			.Lcon8:
				mov r0, #7
				bl mod_random
				cmp r0, #0
				beq .L8
				add r0, #8
				strb r0, [r9,r4]
				bl crea_elemento
				
				mov r0, #1
				b .Lcont
		@;-------------------------
		.L16:
			cmp r1, #1
			blt .Lcon16
			bl comprueba_arriba
			cmp r12, #1
			beq .Lcon16
			bne .Lcont
			.Lcon16:
				mov r0, #7
				bl mod_random
				cmp r0, #0
				beq .L16
				add r0, #16
				strb r0, [r9,r4]
				
				bl crea_elemento
				
				mov r0, #1
				b .Lcont
		@;-------------------------
		.Lfin:
			
	pop {r1-r3, r5-r12,pc}

	
	
@;	r4 --> matriz a comprobar
@;	r1 -->fila r2 -->columa r3 -->dim
@;Resultado
@;	r12 --> 1 se puede, 0 no se puede

comprueba_arriba:
	push {r0-r11,lr}
	
	
	.LwhileComprueba:
		sub r1, #1	@;restar 1 a la fila para mirar arriba
		mla r5, r1, r3, r2 @;caclulo del indice
		add r6, r4, r5
		ldrb r6, [r6]
		cmp r6, #15
		beq .LwhileComprueba
		cmp r6, #7
		beq .Lno_sePuede
		cmp r1,#1
		ble .Lno_sePuede	@;esta ya en la fila 1 o 0
		bne .Lse_Puede
	
	.Lno_sePuede:
		mov r12, #0
		b .LfinComprueba
	.Lse_Puede:
		mov r12, #1
		b .LfinComprueba
	.LfinComprueba:
	
	pop {r0-r11,pc}
	
	
.end
