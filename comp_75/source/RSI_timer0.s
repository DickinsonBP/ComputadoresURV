@;=                                                          	     	=
@;=== RSI_timer0.s: rutinas para mover los elementos (sprites)		  ===
@;=                                                           	    	=
@;=== Programador tarea 2E: xxx.xxx@estudiants.urv.cat				  ===
@;=== Programador tarea 2G: yyy.yyy@estudiants.urv.cat				  ===
@;=== Programador tarea 2H: dickinson.bedoya@estudiants.urv.cat				  ===
@;=                                                       	        	=

.include "../include/candy2_incl.i"


@;-- .data. variables (globales) inicializadas ---
.data
		.align 2
		.global update_spr
	update_spr:	.hword	0			@;1 -> actualizar sprites
		.global timer0_on
	timer0_on:	.hword	0 			@;1 -> timer0 en marcha, 0 -> apagado
	divFreq0: .hword	5820			@;divisor de frecuencia inicial para timer 0


@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
	divF0: .space	2				@;divisor de frecuencia actual


@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm

@;TAREAS 2Ea,2Ga,2Ha;
@;rsi_vblank(void); Rutina de Servicio de Interrupciones del retrazado vertical;
@;Tareas 2E,2F: actualiza la posición y forma de todos los sprites
@;Tarea 2G: actualiza las metabaldosas de todas las gelatinas
@;Tarea 2H: actualiza el desplazamiento del fondo 3
	.global rsi_vblank
rsi_vblank:
		push {r0-r12,lr}
		
@;Tareas 2Ea
        ldr r2, =update_spr
        ldrh r3, [r2]
        cmp r3, #1
        bne .Lsiguiente
		
        mov r0, #0x07000000
        ldr r2, =n_sprites
        ldr r1, [r2]
        bl SPR_actualizarSprites
		
        ldr r2, =update_spr
        mov r3, #0
        strh r3, [r2]

    .Lsiguiente:


@;Tarea 2Ga
		ldr r4, =update_gel
        ldrb r5, [r4]
        cmp r5, #0
        beq .Lsiguiente_tarea            @;si update_gel = 0, acabar
        mov r6, #ROWS-1            @;para el bucle de la matriz
        mov r7, #COLUMNS-1        @;para el bucle de la matriz
        mov r9, #COLUMNS
        mov r1, #0                @;indice filas
        mov r2, #0                @;indice columnas
    .Lbucle:
        ldr r8, =mat_gel        @; r8 = mat_gel
        mul r3, r1, r9            @; r3 = fila * COLUMNS
        add r5, r3, r2            @; r5 = fila * COLUMNS + columna
        mov r3, #GEL_TAM
        mul r0, r5, r3            @; r0 = (fila * COLUMNS + columna) * GEL_TAM
        add r8, r0
        ldrb r3, [r8, #GEL_II]    @; r3 = mat_gel[fil][col].ii
        cmp r3, #0
        bne .Lnextcol
		
        ldrb r3, [r8, #GEL_IM]    @; r3 = mat_gel[fil][col].im
        mov r0, #0x06000000
		
        bl fijar_metabaldosa
		
        mov r3, #10
        strb r3, [r8, #GEL_II]    @; mat_gel[fil][col].ii = 10

    .Lnextcol:
        add r2, #1
		
        cmp r2, r7                @; Si estamos en la ultima columna pasamos a siguiente fila 
        bls .Lbucle

    .Lnextfila:
        mov r2, #0
        add r1, #1                @; Cambiamos de fila i ponemos columnas a 0
		
        cmp r1, r6
        bls .Lbucle                @; Si hemos acabado de recorrer la matriz paramos
        mov r5, #0                @; Ponemos update_gel = 0
        strb r5, [r4]

    .Lsiguiente_tarea:

@;Tarea 2Ha
	ldr r3, =update_bg3
	ldrh r4, [r3]		@;cargar valor de la variable update_bg3
	cmp r4, #0			@;comparar con 0
	beq .Lfinal			@;si es igual, saltar al final
	
	ldr r5, =offsetBG3X
	ldrh r6, [r5]		@;cargar el valor de la variable offsetBG3X
	
	mov r6, r6, lsl #8
	@;bic r6, #0xFF		@;poner a 0 los 8 bits de menos peso
	
	ldr r5, =0x04000038		@;cargar registro de desplazamiento REG_BG3X
	str r6, [r5]		@;guardar el valor de offset en el registro
	
	mov r4, #0
	strh r4, [r3]		@;desactivar la variale update_bg3
	
	.Lfinal:
		pop {r0-r12,pc}

@;TAREA 2Eb;
@;activa_timer0(init); rutina para activar el timer 0, inicializando o no el
@;	divisor de frecuencia según el parámetro init.
@;	Parámetros:
@;		R0 = init; si 1, restablecer divisor de frecuencia original divFreq0
	.global activa_timer0
activa_timer0:
		push {r0-r2,lr}
		
        cmp r0, #0
        beq .Les_0
		
        @; no es 0
        ldr r0, =divFreq0
        ldrh r2, [r0]
		rsb r2, r2, #0
        ldr r1, =divF0
        strh r2, [r1]
		
        ldr r1, =0x04000100
        strh r2, [r1]
		
    .Les_0:
        ldr r0, =timer0_on
        mov r1, #1
        strh r1, [r0]
		
        ldr r0, =0x04000102
        mov r1, #0xC2
        strh r1, [r0]
		
        pop {r0-r2,pc}

@;TAREA 2Ec;
@;desactiva_timer0(); rutina para desactivar el timer 0.
	.global desactiva_timer0
desactiva_timer0:
		push {r0-r1,lr}
		
        ldr r0, =timer0_on
        mov r1, #0
        strh r1, [r0]
		
		
        ldr r0, =0x04000102
        mov r1, #0x42
        strh r1, [r0]
		
        pop {r0-r1,pc}

@;TAREA 2Ed;
@;rsi_timer0(); rutina de Servicio de Interrupciones del timer 0: recorre todas
@;	las posiciones del vector vect_elem y, en el caso que el código de
@;	activación (ii) sea mayor o igual a 0, decrementa dicho código y actualiza
@;	la posición del elemento (px, py) de acuerdo con su velocidad (vx,vy),
@;	además de mover el sprite correspondiente a las nuevas coordenadas.
@;	Si no se ha movido ningún elemento, se desactivará el timer 0. En caso
@;	contrario, el valor del divisor de frecuencia se reducirá para simular
@;  el efecto de aceleración (con un límite).
	.global rsi_timer0
rsi_timer0:
		push {r0-r7, r12, lr} 
		
		ldr r7,=n_sprites
		ldr r7,[r7]
        mov r12, #0                    @; para comprobar si ha habido movimiento
        mov r6, #ELE_TAM
        mov r0, #0                    @;indice del vector
    .Lfor:
        mul r4, r0, r6            @; i * ELE_TAM
        ldr r5, =vect_elem
		add r5, r4
        ldrh r1, [r5, #ELE_II]
		
        cmp r1, #0                @; si es  0  o -1 no hacer nada
        beq .Lnoproceso
        cmp r1, #0xff
        beq .Lnoproceso
		
        mov r12, #1                @; comprobar que ha habido movimiento 
		
        sub r1, #1
        strh r1, [r5, #ELE_II]
		
        @; actualizar posiciones x e y 
        ldrh r3, [r5, #ELE_VX]
        ldrh r1, [r5, #ELE_PX]
        add r1, r3
        strh r1, [r5, #ELE_PX]
		
        ldrh r4, [r5, #ELE_VY]
        ldrh r2, [r5, #ELE_PY]
        add r2, r4
        strh r2, [r5, #ELE_PY]
		
        @; llamar SPR_moverSprite()
        @;    r0 indice del sprite a mover, r1 nueva px, r2 nueva py

		bl SPR_moverSprite

    .Lnoproceso:
        add r0,#1
        cmp r0,r7
        blo .Lfor
		
        cmp r12, #1
        beq .Lmovimiento

        bl desactiva_timer0
		b .Lfi
	
    .Lmovimiento:
        ldr r0, =update_spr
        strh r12, [r0]
		
        ldr r0, =divF0
        ldrh r12, [r0]
        sub r12, #50
        strh r12, [r0]
	.Lfi:
	.Lfi:
		pop {r0-r7, r12, pc}


.end

