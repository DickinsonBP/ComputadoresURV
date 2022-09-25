@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

@;=                                                          	     	=
@;=== RSI_timer2.s: rutinas para animar las gelatinas (metabaldosas)  ===
@;=                                                           	    	=
@;=== Programador tarea 2G: xxx.xxx@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_gel
	update_gel:	.hword	0			@;1 -> actualizar gelatinas
		.global timer2_on
	timer2_on:	.hword	0 			@;1 -> timer2 en marcha, 0 -> apagado
	divFreq2: .hword 	10473		@;divisor de frecuencia para timer 2



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Gb;
@;activa_timer2(); rutina para activar el timer 2.
	.global activa_timer2
activa_timer2:
		push {r0-r2, lr}
		
		ldr r0, =timer2_on				@; cargamos timer2_on en r0
		mov r1, #1						
		strh r1, [r0]					@; timer2_on = 1
		
		ldr r0, =0x04000108				@; cargamos TIMER2_DATA en r0
		ldr r2, =divFreq2				@; cargamos divFreq2 en r2
		ldrh r1, [r2]					@; r1 = divFreq2
		rsb r1, r1, #0
		strh r1, [r0]					@; TIMER2_DATA = divFreq2
		
		@; guardar en TIMER2_CR (0x0400010A) -> 11000001
		
		ldr r0, =0x0400010A				@; cargar TIMER2_CR en r0
		mov r1, #0xC1					@; s'ha de ficar el numero adecuat
		strh r1, [r0]					@; TIMER2_CR = 11000001 en hexadecimal
		
		pop {r0-r2, pc}


@;TAREA 2Gc;
@;desactiva_timer2(); rutina para desactivar el timer 2.
	.global desactiva_timer2
desactiva_timer2:
		push {r0, r1, lr}
		
		ldr r0, =0x0400010A				@; cargar TIMER2_CR en r0
		mov r1, #0x41					@; s'ha de ficar el numero adecuat
		strh r1, [r0]					@; TIMER2_CR = 01000001 en hexadecimal
		
		ldr r0, =timer2_on				@; cargamos timer2_on en r0
		mov r1, #0						
		strh r1, [r0]					@; timer2_on = 0
		
		pop {r0, r1, pc}




@;TAREA 2Gd;
@;rsi_timer2(); rutina de Servicio de Interrupciones del timer 2: recorre todas
@;	las posiciones de la matriz mat_gel y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 1, decrementa dicho código en una unidad
@;	y, en el caso que alguna llegue a 0, incrementa su código de metabaldosa y
@;	activa una variable global update_gel para que la RSI de VBlank actualize
@;	la visualización de dicha metabaldosa.
	.global rsi_timer2
rsi_timer2:
		push {r0-r9,  lr}
		
		mov r6, #ROWS-1			@;para el bucle de la matriz
		mov r7, #COLUMNS-1		@;para el buvle de la matriz
		mov r9, #COLUMNS		
		
		mov r1, #0				@;indice filas
		mov r2, #0				@;indice columnas
		
	.Lbucle:
		ldr r8, =mat_gel		@; r8 = mat_gel
		mul r3, r1, r9			@; r3 = fila * COLUMNS
		add r5, r3, r2			@; r5 = fila * COLUMNS + columna
		mov r3, #GEL_TAM
		mul r0, r5, r3			@; r0 = (fila * COLUMNS + columna) * GEL_TAM
		add r8, r0
		ldrb r3, [r8, #GEL_II]	@; r3 = mat_gel[fil][col].ii
		
		cmp r3, #0
		bgt .Liimajor
		
		cmp r3, #0
		bne .Lnextcol
		
		ldr r5, =update_gel
		mov r4, #1
		strb r4, [r5]
		
		ldrb r3, [r8, #GEL_IM]	@; r3 = mat_gel[fil][col].im
		
		cmp r3, #7
		beq .Lsimple 
		
		cmp r3, #15
		beq .Ldoble
		
		add r3, #1
		strb r3, [r8, #GEL_IM]	@; mat_gel[fil][col].ii = im+1
		b .Lnextcol
		
	.Lsimple:
		mov r3, #0
		strb r3, [r8, #GEL_IM]	@; mat_gel[fil][col].ii = 0
		b .Lnextcol
		
	.Ldoble:
		mov r3, #8
		strb r3, [r8, #GEL_IM]	@; mat_gel[fil][col].ii = 8
		b .Lnextcol
		
	.Liimajor:
		cmp r3, #0xff
		beq .Lnextcol
		sub r3, #1
		strb r3, [r8, #GEL_II]

	.Lnextcol:
		add r2, #1
		
		cmp r2, r7				@; Si estamos en la ultima columna pasamos a siguiente fila
		ble .Lbucle
		
	.Lnextfila:
		mov r2, #0
		add r1, #1				@; cambiamos de fila i ponemos columnas a 0
		
		cmp r1, r6
		ble .Lbucle				@; si hemos acabado de recorrer la matriz paramos
		
		pop {r0-r9, pc}	



.end

