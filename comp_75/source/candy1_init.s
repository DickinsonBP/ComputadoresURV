@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: alex.moriana@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: alex.moriana@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global 'mapas'), y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:
		push {r0-r12,lr}			@;guardar registros utilizados
		mov r10, r0					@; guardar una copia de la matriz de juego en r10
		mov r4, #0					@; indice de la matriz
		mov r2,#ROWS*COLUMNS		@; dimensiones totales de la matrix
		ldr r11, =mapas				@; mapas de configuracion
		mla r5, r2, r1, r11			@; mida*numero de mapa de conf(nivell)+mapa actual, buscar el mapa dessitjat
		mov r6, r1					@; copiem el nivell de la matriu de configuracio
		
		mov r12,#COLUMNS			@; columnes maximes en r12
		mov r1,#0					@; files a 0
		.L_forFila:
			mov r2, #0				@; inicialitzar columnes a 0 per cada fila 
		.L_forColumna:
			mla r4,r1,r12,r2		@; files*COLUMNS+ columna actuals
			ldrb r7,[r5,r4]			@; llegir el caracter de la matriu de configuracio del index actual
			mov r8,r7				@; copia del caracter en el cas de que s'hagi d'aplicar cuenta repeticiones i unaltre numero random
			and r8, #0x07			@; agafa el valor dels ultims 3 bits del bit
			cmp r8, #0				@; compara els ultims 3 bits per saber si es buit, simple o doble gelatina,(acabats en 000 tots tres)
			beq .L_sumarli			@; hem de sumar un mod_random al valor de la gelatina simple doble o casella buida
			strb r7, [r10,r4]		@; guardem el bit a la copia de la  matriu de joc 
			b .L_continuar
		.L_reintentar:
			sub r7,r8				@; restarli el numero aleatori sumat
			strb r7,[r10,r4]		@; tornar a ficar el numero original per a reintentar-ho
			
		.L_sumarli:
			mov r0,#6
			bl mod_random			@; mod random retorna a r0 un valor entre  0 i r0-1
			add r0,#1
			mov r8,r0				@; copiem el numero aleatori
			add r7,r0				@; sumem el numero de la matriu de configuracio al numero aleatori 
			strb r7,[r10,r4]		@; guardem el nom valor a la copia de la matriu de joc 
			mov r0,r10 				@; copiem a r0 la matriu de joc per a cridar la funcio cuenta_repeticiones 
			mov r3, #2				@; orientacio horitzontal
			bl cuenta_repeticiones 	@; comprovem si al oest hi ha una sequencia de 3 elements
			cmp r0,#3				@; comprovem si retorna 3 o mes alt 
			bhs .L_reintentar
			
			mov r0,r10				@; tornem a posar a r0 la matriu de joc 
			mov r3,#3 				@; orientacio nort 
			bl cuenta_repeticiones 	@;comprovem si al nort hi ha sequencia de 3 elements o mes 
			cmp r0,#3 
			bhs .L_reintentar
			
		.L_continuar:
			add r2,#1 				@; columnes++
			cmp r2,#COLUMNS			@; comprovacio del while 
			blo .L_forColumna		@; tornar al bucle de columnes
			
			add r1,#1				@; files++
			cmp r1,#ROWS			@; comprovacio del while 
			blo .L_forFila			@; tornar al primer for
			
		pop {r0-r12,pc}				@;recuperar registros y volver



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en 'mat_recomb1', para luego ir
@;	escogiendo elementos de forma aleatoria y colocandolos en 'mat_recomb2',
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			'mod_random'
@;		* para evitar generar secuencias se invocará la rutina
@;			'cuenta_repeticiones' (ver fichero "candy1_move.s")
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina 'hay_combinacion' (ver fichero "candy1_comb.s")
@;		* se supondrá que siempre existirá una recombinación sin secuencias y
@;			con combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
		push {r0-r12,lr}
		.L_recomb:
			mov r10,r0				@; hacer una copia de la matriz de juego
			ldr r11,=mat_recomb1	@; matriz de recombinacion 1
			ldr r12,=mat_recomb2	@; matriz de recombinacion 2
			mov r1,#0				@; variable filas a 0, bucle para recorrer matriz
		.L_for:
			mov r2,#0				@; variable columnas a 0, bucle para recorrer matriz
		.L_for2:
			mov r5, #COLUMNS		@; reutilitzacio de la variable r5 durant el codi
			mla r6, r1,r5,r2		@; index actual de la posicio de la matriu
			mov r5,r6 				@;copia de index original
			ldrb r7,[r10,r6]		@; llegir el caracter del index corresponent a la matriu
			
			mov r8,r7
			and r8, #0x07		
			cmp r8,#0x07			@; comprovem que no sigui un 7, bloc solid 
			bne .L_tipus
			mov r0,#0				@; si esta buid i solid es un 0
			strb r0,[r11,r6]		@; guardem el 0 a la posicio del bloc
			strb r7,[r12,r6]		@; guardem el caracter original en la mat2
			b .L_fi_for
		.L_tipus:
			mov r0,#8				@; guia per a saber si es una gelatina simple 
			mov r9,r7, lsr #3		@; moure 3 espais a la dreta la posible gelatina o doble gelatina 
			and r9,#0x03			@; agafar els ultims 2 bits 
			cmp r9,#0x01			@; comprovar-ho amb el numero 1((( pero el ultim =8 o el 16 tmb?))))
			beq .L_gelatina			@; gelatina simple 
			mov r0,#16				@; guia per a saber si es una gelatina doble
			cmp r9,#0x02			@; gelatina doble
			bne .L_buit				@; si no es cap de les dues, es casella buida 
		.L_gelatina:
			strb r8,[r11,r6]		@; numero simple restant el corresponent gelatina 	
			strb r0,[r12,r6]		@; guardem el valor gelatina a la mat_recomb2
			b .L_fi_for
		.L_buit:
			cmp r7,#0				@; comprovem que sigui un espai buit 
			bne .L_elem				@; si no es un espai buit, es un element simple 
			strb r7,[r11,r6]		@; copiem el numero 0 a la posicio del espai buit
			strb r7,[r12,r6]		@; copiem literalment el espai buit a la matriu_recomb2 ( tambe 0)
			b .L_fi_for
		.L_elem:
			mov r0,#0
			strb r8,[r11,r6]		@; copiem els bits del element simple 1-6
			strb r0,[r12,r6]		@; copiem el 0 a la posico del element simple a la matriu_recomb2
		.L_fi_for:
			add r2,#1				@; contador columnes++
			cmp r2,#COLUMNS			@; columnes amb CMax
			blo .L_for2				@; comprovacio fi del bucle 
			add r1,#1				@; contador files++
			cmp r1,#ROWS			@; files amb FMax
			blo .L_for				@; comprovacio fi del bucle
			
			
			
			mov r1,#0				@; files=0
		.L_for3:
			mov r2,#0				@; columnes=0
		.L_for4: 
			mov r0,#COLUMNS			@; proba per a poder reutilitzar r5 pe la fase 2
			
			mla r6, r1,r0,r2		@; index actual de la posicio de la matriu
			mov r8, r6				@; copia del index  
			ldrb r9,[r12,r6]		@; agafem el valor de la matriu_recomb2 del index
			
			mov r0,r9 				@; copia del element a tractar 
			and r0,#0x07			@; agafem els 3 primers bits 
			cmp r0,#0x07			@; comprovem si es solit 
			beq .L_fi_for2
			ldrb r0,[r10,r6]		@; agafem el valor original de la matriu de joc 
			and r0,#0x07
			cmp r0,#0				@; comrpovem si es hueco
			beq .L_fi_for2
			mov r4,#500
			b .L_combinar
		.L_restaurar2:
			sub r9,r7				@; tornem el valor original de, elem.mat2 - elem.mat1
			strb r9,[r12,r8]
			
		.L_combinar:
			sub r4,#1				@; comprovar els intentents maxims contador--
			cmp r4,#0
			beq .L_recomb 			@; reiniciar la funcio si no troba solucio
			
			mov r0,#ROWS
			bl mod_random			@; cridem mod random perque ens dongui una posicio de la matriu en files i mes tard columnes 
			mov r7,r0				@; copia de la fila 
			mov r0,#COLUMNS 		@; ara en columnes 
			bl mod_random
			mov r3,#COLUMNS			@; intento reciclar r5,#columns 
			mla r6, r7,r3,r0		@; index actual de la posicio  per a la matriu recomb_1
			
			ldrb r7,[r11,r6]		@; guardem en r7 la posicio de la matriu_recomb1
			cmp r7,#0				@; comprovem que no hagi sigut utilitzat abans
			beq .L_combinar 		@; tornar a probar 
			
			add r9,r7				@; sumem els valors de la matriu2 i el random matriu1
			strb r9,[r12,r8]		@; guardem el nou valor de la suma a mat_recomb2 
			
			mov r0,r12				@; preparem els requisits de cuenta repeticiones, matriu a r0
			mov r3,#3				@; orientacio vertical, nord 
			bl cuenta_repeticiones
			cmp r0,#3
			bhs .L_restaurar2		@; començar unaltre cop el intent
			
			mov r0,r12
			mov r3,#2				@; comprovem la orientacio horitzontal 
			bl cuenta_repeticiones
			cmp r0,#3
			bhs .L_restaurar2		@; començar unaltre cop el intent
			
			mov r3,#0
			strb r3,[r11,r6]
			
			@;   r5 index inicial, r6 index final, requisits per a la funcio activar sprite
			mov r0,r5				@; posicion inicial de cada elemento
			mov r1,r6				@;posicion final de cada elemento
			bl activa_elemento
			
			.L_fi_for2:
			add r2,#1				@; columnes++
			cmp r2,#COLUMNS
			blo .L_for4
			
			add r1,#1				@;files++
			cmp r1,#ROWS
			blo .L_for3
			
			mov r10,r12				@; o a r0, copiem la matriu final recomb2 a la matriu de joc
		pop {r0-r12,pc}



@;:::RUTINAS DE SOPORTE:::
@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina 'random'
@;	Restricciones:
@;		* el parámetro 'n' tiene que ser un valor entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}
		cmp r0, #2					@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2					@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff				@;filtra los 8 bits de menos peso
		sub r2, r0, #1				@;R2 = R0-1 (número más alto permitido)
		mov r3, #1					@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2					@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1					@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random					@;R0 = número aleatorio de 32 bits
		and r4, r0, r3				@;filtra los bits de menos peso según máscara
		cmp r4, r2					@;si resultado superior al permitido,
		bhi .Lmodran_loop			@; repite el proceso
		mov r0, r4					@; R0 devuelve número aleatorio restringido a rango
		pop {r1-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global 'seed32' (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de 'seed32' no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en 'seed32')
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32					@;R0 = dirección de la variable 'seed32'
	ldr r1, [r0]					@;R1 = valor actual de 'seed32'
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3						@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]					@;guarda los 32 bits bajos en 'seed32'
	mov r0, r5						@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
