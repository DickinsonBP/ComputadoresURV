@;=                                                               		=
@;=== candy1_combi.s: rutinas para detectar y sugerir combinaciones   ===
@;=                                                               		=
@;=== Programador tarea 1G: mariona.valero@estudiants.urv.cat		  ===
@;=== Programador tarea 1H: mariona.valero@estudiants.urv.cat		  ===
@;=                                                             	 	=



.include "../include/candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos en gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1, r2, r4-r10, lr}
		
		mov r4, r0				@;dreccion de la mariz a r4
		
		mov r9, #ROWS-1			@;indice maximo de filas
		mov r10, #COLUMNS-1		@;indice maximo de columnas
		
		mov r1, #0				@;Indice filas
		mov r2, #0				@;Indice columnas
		mov r6, #0				@;Desplazamiento de las posiciones
		
	.Lbucle:
		ldrb r5, [r4, r6]
		bl es_valid
		cmp r5, #1
		beq .Lcomprobar_horizontal
	
	.Lnextcol:
		add r2, #1
		add r6, #1
		cmp r2, #COLUMNS
		bne .Lbucle
		mov r2, #0
		
	.Lnextfila:
		add r1, #1
		cmp r1, #ROWS
		bne .Lbucle
		mov r0, #0
		b .Lfibucle
		
	.Lcomprobar_horizontal:
		cmp r2, r10							@; comprobamos que no estamos en la ultima columna
		beq .Lcomprobar_vertical
		
		
		add r8, r6, #1						@; comprovamos que el numero de al lado sea valido i diferente
		ldrb r7, [r4, r6]
		ldrb r5, [r4, r8]
		and r5, #7
		and r7, #7
		cmp r5, r7
		beq .Lcomprobar_vertical
		bl es_valid
		cmp r5, #0
		beq .Lcomprobar_vertical			@; si no es valido comprovamos verticalmente
		
		bl intercambio_horizontal			@; los intercambiamos si es valido i comprobamos si hay sequencia
		bl detectar_orientacion
		bl intercambio_horizontal	
		cmp r0, #6							
		bne .Lhay_sequencia					@; si hay sequencia acabamos
	 
     
		bl intercambio_horizontal			@; si no comprobamos si hay sequencia en la posicion de abajo
		add r2, #1
		bl detectar_orientacion
		bl intercambio_horizontal
		sub r2, #1
		cmp r0, #6
		bne .Lhay_sequencia
		
	.Lcomprobar_vertical:
		cmp r1, r9							@; Comprobamos que no estamos en la ultima fila
		beq .Lnextcol
		
		add r8, r6, #COLUMNS				@; comprobamos que el numero de abajo sea valido i diferente
		ldrb r7, [r4, r6]
		ldrb r5, [r4, r8]
		and r5, #7
		and r7, #7
		cmp r5, r7
		beq .Lnextcol
		bl es_valid 
		cmp r5, #0
		beq .Lnextcol						@; Si no es valido vamos a la siguiente posicion de la matriz
		
		bl intercambio_vertical				@; si es valido comproamos si hay sequencia en la posicion de arriba
		bl detectar_orientacion
		bl intercambio_vertical
		cmp r0, #6
		bne .Lhay_sequencia	
     
		bl intercambio_vertical				@; si no comprobamos si hay sequencia en la posicion de abajo
		add r1, #1
		bl detectar_orientacion
		bl intercambio_vertical
		sub r1, #1
		cmp r0, #6
		beq .Lnextcol
		
	.Lhay_sequencia:
		mov r0, #1
	
	.Lfibucle:
	
		pop {r1, r2, r4-r10, pc}



@;TAREA 1H;
@; sugiere_combinacion(*matriz, *sug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos en gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se supone que existe por lo menos una combinación en la matriz
@;			 (se debe verificar antes con la rutina 'hay_combinacion')
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina 'mod_random'
@;			 (ver fichero "candy1_init.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (char *), donde la rutina
@;				guardará las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {r2-r12, lr}
		
		mov r4, r0				@; direccion base de la matriz
		
		mov r3, r1				@; direcion base del vector
		
		mov r9, #ROWS-1			@; indice maximo filas
		mov r10, #COLUMNS-1		@; indice maximo columnas
		
		mov r11, #ROWS			@; filas de la matriz
		mov r12, #COLUMNS		@; columnas de la matriz
		
		mov r0, #ROWS
		bl mod_random
		mov r1, r0				@; indice aleatorio de filas
		
		mov r0, #COLUMNS
		bl mod_random
		mov r2, r0				@; indice aleatorio de columnas
		
		mla r6, r1, r12, r2		@; desplazamiento
		
	.Lloop:
		ldrb r5, [r4, r6]
		bl es_valid
		cmp r5, #1
		beq .Lhorizontal_left
	
	.Lsiguiente_col:
		add r2, #1
		add r6, #1
		cmp r2, r12
		bne .Lloop
	
	.Lsiguiente_fila:
		mov r2, #0
		add r1, #1
		cmp r1, r11
		bne .Lloop
		
		mov r1, #0							@; si ha acabado la matriz, se va a la posicion inicial
		mov r6, #0
		b .Lloop
		
	.Lhorizontal_left:
		cmp r2, r10							@; comprobamos que no estamos en la ultima columna
		beq .Lvertical_up
		
		add r8, r6, #1						@; comprovamos que el numero de al lado sea valido i diferente
		ldrb r7, [r4, r6]
		ldrb r5, [r4, r8]
		and r5, #7
		and r7, #7
		cmp r5, r7
		beq .Lvertical_up
		bl es_valid
		cmp r5, #0
		beq .Lvertical_up					@; si no es valido comprovamos verticalmente
		
		bl intercambio_horizontal			@; los intercambiamos si es valido i comprobamos si hay sequencia
		bl detectar_orientacion
		bl intercambio_horizontal	
		cmp r0, #6							
		beq .Lhorizontal_right				@; si no hay sequencia vamos seguimos buscando
	
		mov r7, #0
		b .Lhay_combo
		
	.Lhorizontal_right:
		bl intercambio_horizontal			@; si no comprobamos si hay sequencia en la posicion de abajo
		add r2, #1
		bl detectar_orientacion
		bl intercambio_horizontal
		sub r2, #1
		cmp r0, #6
		beq .Lvertical_up
		
		add r2, #1							@; cojemos la posicion inicial correcta
		mov r7, #1							@; asignamos codigo de posicion inicial
		b .Lhay_combo
	
	.Lvertical_up:
		cmp r1, r9							@; Comprobamos que no estamos en la ultima fila
		beq .Lsiguiente_col
		
		add r8, r6, #COLUMNS				@; comprobamos que el numero de abajo sea valido i diferente
		ldrb r7, [r4, r6]
		ldrb r5, [r4, r8]
		and r5, #7
		and r7, #7
		cmp r5, r7
		beq .Lsiguiente_col
		bl es_valid 
		cmp r5, #0
		beq .Lsiguiente_col				@; Si no es valido vamos a la siguiente posicion de la matriz
		
		bl intercambio_vertical				@; si es valido comproamos si hay sequencia en la posicion de arriba
		bl detectar_orientacion
		bl intercambio_vertical
		cmp r0, #6
		beq .Lvertical_down

		mov r7, #2							@; asignamos codigo de posicion inicial
		b .Lhay_combo
		
	.Lvertical_down:
		bl intercambio_vertical				@; si no comprobamos si hay sequencia en la posicion de abajo
		add r1, #1
		bl detectar_orientacion
		bl intercambio_vertical
		sub r1, #1
		cmp r0, #6
		beq .Lsiguiente_col
		
		add r1, #1							@; cojemos la posicion inicial correcta
		mov r7, #3							@; asignamos codigo de posicion inicial
		
	.Lhay_combo:
		mov r5, r0
		mov r6, r4
		mov r0, r3
		mov r3, r5
		mov r4, r7
		
		bl generar_posiciones
		
		mov r1, r0
		mov r0, r6
		
		pop {r2-r12, pc}




@;:::RUTINAS DE SOPORTE:::



@; generar_posiciones(vect_pos,f,c,ori,cpi): genera las posiciones de sugerencia
@;	de combinación, a partir de la posición inicial (f,c), el código de
@;	orientación 'ori' y el código de posición inicial 'cpi', dejando las
@;	coordenadas en el vector 'vect_pos'.
@;	Restricciones:
@;		* se supone que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los límites
@;			de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones 'vect_pos'
@;		R1 = fila inicial 'f'
@;		R2 = columna inicial 'c'
@;		R3 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
generar_posiciones:
		push {lr}
		
	.Lcpi0:
		cmp r4, #0
		bne .Lcpi1
		
		add r2, #1
		strb r2, [r0]
		strb r1, [r0, #1]
		sub r2, #1
		b .Lcori1
		
	.Lcpi1:
		cmp r4, #1
		bne .Lcpi2
		
		sub r2, #1
		strb r2, [r0]
		strb r1, [r0, #1]
		add r2, #1
		b .Lcori0
		
	.Lcpi2:
		cmp r4, #2
		bne .Lcpi3
		
		add r1, #1
		strb r2, [r0]
		strb r1, [r0, #1]
		sub r1, #1
		b .Lcori0
		
	.Lcpi3:
		sub r1, #1
		strb r2, [r0]
		strb r1, [r0, #1]
		add r1, #1
		
	.Lcori0:
		cmp r3, #0
		bne .Lcori1
		
		add r2, #1
		strb r2, [r0, #2]
		strb r1, [r0, #3]
		
		add r2, #1
		strb r2, [r0, #4]
		strb r1, [r0, #5]
		
		b .Lvector_final
		
	.Lcori1:
		cmp r3, #1
		bne .Lcori2

		add r1, #1
		strb r2, [r0, #2]
		strb r1, [r0, #3]
		
		add r1, #1
		strb r2, [r0, #4]
		strb r1, [r0, #5]
		
		b .Lvector_final
	
	.Lcori2:
		cmp r3, #2
		bne .Lcori3

		sub r2, #1
		strb r2, [r0, #2]
		strb r1, [r0, #3]
		
		sub r2, #1
		strb r2, [r0, #4]
		strb r1, [r0, #5]
		
		b .Lvector_final
		
	.Lcori3:
		cmp r3, #3
		bne .Lcori4
		
		sub r1, #1
		strb r2, [r0, #2]
		strb r1, [r0, #3]
		
		sub r1, #1
		strb r2, [r0, #4]
		strb r1, [r0, #5]
		
		b .Lvector_final
		
	.Lcori4:
		cmp r3, #4
		bne .Lcori5
		
		sub r2, #1
		strb r2, [r0, #2]
		strb r1, [r0, #3]
		
		add r2, #2
		strb r2, [r0, #4]
		strb r1, [r0, #5]
		
		b .Lvector_final
		
	.Lcori5:
		sub r1, #1
		strb r2, [r0, #2]
		strb r1, [r0, #3]
		
		add r1, #2
		strb r2, [r0, #4]
		strb r1, [r0, #5]
	
	.Lvector_final:
	
		pop {pc}



@; detectar_orientacion(f,c,mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina 'mod_random'
@;			(ver fichero "candy1_init.s")
@;		* para detectar secuencias se invocará la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;		* sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila 'f'
@;		R2 = columna 'c'
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detectar_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		bne .Ldetori_vert
		mov r3, #4				@;detección secuencia horizontal
		b .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}

@; es_valid(valor): comprueva si un valor de la matriz es o no un espació vacio
@;	un bloque solido o un hueco
@;
@;	Parámetros:
@;		R5 = valor a comprovar
@;	Resultado:
@;		R5 = 1 si es valido, 0 si no
@;
es_valid:
		push {lr}
	.Lcomparaciones:
		and r5, #7
		cmp r5, #0
		beq .Lno_valido
		cmp r5, #7
		beq .Lno_valido
		cmp r5, #15
		beq .Lno_valido
		
		mov r5, #1
		b .Lfin
	.Lno_valido:
		mov r5, #0
		
	.Lfin:
		pop {pc}

@; intercambio_horizontal(f, c, matriz, desplazamiento): cambia el valor de la posicion especificada
@;	por el valor de la derecha y viceversa
@;
@;	Parámetros:
@;		R4 = direccion base de la matriz
@;		R6 = desplazamiento
@;	Resultado:
@;		matriz cambiada devuelta por referencia
@;
intercambio_horizontal:
		push {r5, r7, r8, lr}
		
		add r8, r6, #1
		
		ldrb r5, [r4, r6]
		ldrb r7, [r4, r8]
		
		strb r7, [r4, r6]
		strb r5, [r4, r8]
		
		pop {r5, r7, r8, pc}
	
@; intercambio_vertical(f, c, matriz, desplazamiento): cambia el valor de la posicion especificada
@;	por el valor inferior y viceversa
@;
@;	Parámetros:
@;		R1 = fila
@;		R2 = columna
@;		R4 = direccion base de la matriz
@;		R6 = desplazamiento 
@;	Resultado:
@;		matriz cambiada devuelta por referencia
@;
intercambio_vertical:
		push {r5, r7, r8, lr}
	
		add r8, r6, #COLUMNS
		
		ldrb r5, [r4, r6]
		ldrb r7, [r4, r8]
		
		strb r7, [r4, r6]
		strb r5, [r4, r8]
		
		pop {r5, r7, r8, pc}
		
	
	.end
