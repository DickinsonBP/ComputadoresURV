@;=                                                          	     	=
@;=== RSI_timer1.s: rutinas para escalar los elementos (sprites)	  ===
@;=                                                           	    	=
@;=== Programador tarea 2F: anna.graciac@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global timer1_on
	timer1_on:	.hword	0 			@;1 -> timer1 en marcha, 0 -> apagado
	divFreq1: .hword	5692			@;divisor de frecuencia para timer 1


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	escSen: .space	2				@;sentido de escalado (0-> dec, 1-> inc)
	escFac: .space	2				@;Factor actual de escalado
	escNum: .space	2				@;número de variaciones del factor


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Fb;
@;activa_timer1(init); rutina para activar el timer 1, inicializando el sentido
@;	de escalado según el parámetro init.
@;	Parámetros:
@;		R0 = init;  valor a trasladar a la variable 'escSen' (0/1)
	.global activa_timer1
activa_timer1:
		push {r0-r3, lr}
		
		ldr r2, =escSen
		strh r0, [r2]			@; guardar el valor de init en escSen
		
		cmp r0, #0				@; si r0=0 se trata de un decremento del escalado, si =1 incremento
		bne .incEscalado
		
		ldr r3, =escFac			@; cargar en r3 la dirección de escFac
		mov r0, #0x100
		strh r0, [r3]			@; dar los valores a los registros para los paramétros de SPR_fijarEscalado
		mov r0, #0
		mov r1, #0x100				@; en r0 escFac que está en formato 0.8.8
		mov r2, #0x100				@; el escalado es 1,0
		bl SPR_fijarEscalado
		
	.incEscalado:
		ldr r1, =escNum
		mov r2, #0 				@; poner variable escNum a 0
		strh r2, [r1]
		ldr r3, =timer1_on
		mov r2, #1				
		strh r2, [r3]			@; activar timer 1, timer1_on =1
		
		@; activar el timer 1, para fijar el timer 1 a una freq Div_Frec = -(Frec_Entrada / Frec_Salida)
		@; 32 tics en menos de 0,35s 32/0,35= 91,428 aprox 92Hz, 1/92=0,01086956s 
		@; freq de entrada = freqbase/64 = 523.655,96875 Hz
		@; div_freq= -5692
		
		ldr r1, =divFreq1
		ldsh r2, [r1]
		rsb r2, r2, #0					@; 0 - divFreq1, para obtener la frequencia del timer1 en negativa
		ldr r3, =0x04000104				@; dirección del registro de datos del timer1, TIMER1_DATA
		strh r2, [r3]					@; guardamos en su registro de datos el valor de divFreq1
		
		@; activar timer1, mediante su registro de control TIMER1_CR
		@; bits 0..1 -> 01 (freqbase/64)
		@; bit 2 -> 0 (no enlazar con timer anterior)
		@; bit 6 -> 1 (activar interrupciones)
		@; bit 7 -> 1 (timer en marcha)
		@; TIMER1_CR -> 11000001 (8 bits, 1 byte)
		
		ldr r1, =0x04000106				@; dirección del TIMER1_CR
		mov r2, #0xC1				@; contenido a guardar en TIMER1_CR
		strh r2, [r1]
		
		pop {r0-r3, pc}


@;TAREA 2Fc;
@;desactiva_timer1(); rutina para desactivar el timer 1.
	.global desactiva_timer1
desactiva_timer1:
		push {r0, r2, lr}
		
		ldr r1, =0x04000106				@; dirección del TIMER1_CR
		ldrh r0, [r1]
		bic	r0, #0xFF
		strh r0, [r1]
		
		ldr r1, =timer1_on				@; ponemos timer1_on = 0
		mov r2, #0
		strh r2, [r1]
		
		pop {r0, r2, pc}



@;TAREA 2Fd;
@;rsi_timer1(); rutina de Servicio de Interrupciones del timer 1: incrementa el
@;	número de escalados y, si es inferior a 32, actualiza factor de escalado
@;	actual según el código de la variable 'escSen'. Cuando se llega al máximo
@;	se desactivará el timer1.
	.global rsi_timer1
rsi_timer1:
		push {r0-r6, lr}
		
		ldr r0, =escNum
		ldrh r1, [r0]
		cmp r1, #32				@; si escNum es 32 desactivar timer
		beq .LdesactivarT1
		add r1, #1				@; sino incrementar 1 escNum
		strh r1, [r0]
		
		ldr r2, =escSen
		ldrh r3, [r2]
		ldr r4, =escFac
		ldrh r5, [r4]
		
		cmp r3, #1				@; comprobar escSen para inc. o decr. el factor de escalado actual
		bne .LescSen0			@; escSen = 0 decremento
		mov r6, #1
		sub r5, r6, lsl #8
		strh r5, [r4]
		mov r0, #0
		mov r1, r5
		mov r2, r5
		bl SPR_fijarEscalado
		b .Lfin
		
	.LescSen0:	
		mov r6, #1
		add r5, r6, lsl #8
		strh r5, [r4]
		mov r0, #0
		mov r1, r5
		mov r2, r5
		bl SPR_fijarEscalado
		b .Lfin
	.LdesactivarT1:
		bl desactiva_timer1
		b .Lsalir
	.Lfin:
		ldr r1, =update_spr
		mov r2, #1
		strh r2, [r1]
		
	.Lsalir: 
		pop {r0-r6, pc}


.end
