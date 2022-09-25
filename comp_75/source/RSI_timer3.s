@;=                                                          	     	=
@;=== RSI_timer3.s: rutinas para desplazar el fondo 3 (imagen bitmap) ===
@;=                                                           	    	=
@;=== Programador tarea 2H: dickinson.bedoya@estudiants.urv.cat		  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_bg3
	update_bg3:	.hword	0			@;1 -> actualizar fondo 3
		.global timer3_on
	timer3_on:	.hword	0 			@;1 -> timer3 en marcha, 0 -> apagado
		.global offsetBG3X
	offsetBG3X: .hword	0			@;desplazamiento vertical fondo 3
	sentidBG3X:	.hword	0			@;sentido desplazamiento (0-> inc / 1-> dec)
	divFreq3: 	.hword	52366		@;divisor de frecuencia para timer 3
	@;10 interrupciones en 1 segundo --> 10Hz --> freq_base/64
	@;divFreq = -(523.655,96875 / 10) = -52.365,596875 = -52.366


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm


@;TAREA 2Hb;
@;activa_timer3(); rutina para activar el timer 3.
	.global activa_timer3
activa_timer3:
		push {r0,r1,lr}
		
		ldr r0, =0x0400010C	@;registro de datos del timer 3 (TIMER3_DATA)
		ldr r1, =divFreq3	@;divisor de frecuencia
		ldrh r1, [r1]	
		rsb r1, r1, #0
		strh r1, [r0]		@;guardar el divisor de frecuencia en el registro de datos del timer 3
		
		ldr r0, =0x0400010E	@;registro de control del timer 3 (TIMER3_CR)
		@;mov r3, #0b11000001	@;bits del registro de control
		mov r1, #0xC1
		strh r1, [r0]		@;almacenar en el registro de control
		
		pop {r0,r1,pc}


@;TAREA 2Hc;
@;desactiva_timer3(); rutina para desactivar el timer 3.
	.global desactiva_timer3
desactiva_timer3:
		push {r0, r1,lr}
		
		ldr r0, =timer3_on
		mov r1, #0
		strh r1, [r0]		@;poner a 0 el timer3_on
		
		ldr r0, =0x0400010E		@;cargar registro de control del timer3
		@;mov r1, #0b01000001
		mov r1, #0x41
		strh r1, [r0]		@;desactivar los registros de control
		
		pop {r0,r1,pc}



@;TAREA 2Hd;
@;rsi_timer3(); rutina de Servicio de Interrupciones del timer 3: incrementa o
@;	decrementa el desplazamiento X del fondo 3 (sobre la variable global
@;	'offsetBG3X'), según el sentido de desplazamiento actual; cuando el
@;	desplazamiento llega a su límite, se cambia el sentido; además, se avisa
@;	a la RSI de retroceso vertical para que realice la actualización del
@;	registro de control del fondo correspondiente.
	.global rsi_timer3
rsi_timer3:
		push {r0-r5,lr}
		
		ldr r0, =sentidBG3X
		ldrh r1, [r0]		@;contenido del sentido de la variable
		
		ldr r4, =offsetBG3X
		ldrh r5, [r4]		@;fondo
		
		
		cmp r1, #0
		beq .Lincrementa
		
		sub r5, #1				@;si es 1 decrementar
		cmp r5, #0
		ble .LcambiaSentido
		b .Lcontinua
		
		.Lincrementa:
			add r5, #1		@;si es 0 incrementar
			cmp r5, #320	@;condicion de fin
			bge .LcambiaSentido
			b .Lcontinua
			
		.LcambiaSentido:
			eor r1, #1		@;si sentido == 1, entonces sentido ==> 0 (al reves igual)
			strh r1, [r0]	@;actualizar sentido
			
		.Lcontinua:
			strh r5, [r4]	@;acutalizar fondo
			
			ldr r2, =update_bg3
			mov r3, #1
			strh r3, [r2]		@;activar variable update_bg3
		
		pop {r0-r5,pc}



.end
