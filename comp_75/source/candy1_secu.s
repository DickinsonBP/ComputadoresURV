
@;=                                                               		=
@;=== candy1_secu.s: rutinas para detectar y elimnar secuencias 	  ===
@;=                                                             	  	=
@;=== Programador tarea 1C: anna.graciac@estudiants.urv.cat				  ===
@;=== Programador tarea 1D: anna.graciac@estudiants.urv.cat				  ===
@;=                                                           		   	=



.include "../include/candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; n�mero de secuencia: se utiliza para generar n�meros de secuencia �nicos,
@;	(ver rutinas 'marcar_horizontales' y 'marcar_verticales') 
	num_sec:	.space 1



@;-- .text. c�digo de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1C;
@; hay_secuencia(*matriz): rutina para detectar si existe, por lo menos, una
@;	secuencia de tres elementos iguales consecutivos, en horizontal o en
@;	vertical, incluyendo elementos en gelatinas simples y dobles.
@;	Restricciones:
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_secuencia
hay_secuencia:
		push {r1-r7,r10, lr}
		
		mov r7, #ROWS*COLUMNS	@; dimesion
		sub r7, #3				@; ya se habr�n mirado todas las posiciones
		mov r1, #0				@; fila inicial para recorrer la matriz
		mov r2, #0				@; columna inicial para recorrer la matriz
		mov r6, #0				@; �ndice inicial
		add r4, r0, r6			@; apuntar al elemento en la posici�n (f,c)r6
		ldrb r5, [r4]			@; elemento de la posicion
		and r5, #7				@; en r5 tendremos el valor filtrado del elemento
		mov r10, r0				@; movemos de registro la direcci�n de la matriz para no perderla
		mov r0, #0 				@; partimos con r0=0 es decir que no hay secuencia
		.LWhileElemento:				@; en este while se comprueba que el elemento filtrado
			cmp r5, #6					@; sea un elemento para evitar huecos, casillas vacias,etc.
			bgt .LnextElem				@; se va avanzando en la matriz hasta el final a medida que se evitan las
			cmp r5, #0					@; posiciones invalidas y se va encontrando alguna secuencia.
			bhi .LmirarSecu
			.LnextElem:
				cmp r2, #COLUMNS-1					
				beq .LnextFila				@; si ya hemos llegado a la columa 8 toca avanzar a la siguiente fila
				.LnextCol:
					add r2, #1
					add r6, #1
					cmp r6, r7				@; comprobamos que no se haya terminado la matriz en la posici�n rows*columns-3 se puede salir porque seguir
					bhi .Lfin				@; mirando los elementos y secuencias ser�a innecesario porque ya habr�an sido mirados antes.
					add r4, r10, r6			
					ldrb r5, [r4]			
					and r5, #7
					b .LWhileElemento
				.LnextFila:
					mov r2, #0				@; para pasar a la siguiente fila nos colocamos en c=0 y fila++;
					add r1, #1
					add r6, #1	
					cmp r6, r7				@; comprobamos no haber terminado la matriz
					beq .Lfin
					add r4, r10, r6			
					ldrb r5, [r4]			
					and r5, #7
					b .LWhileElemento
		.LmirarSecu:
			cmp r1, #ROWS-3					@; si la fila es menor o igual que rows-3 como m�nimo tendremos que mirar hacia el sur
			bhi .Leste
			.Lsur:
				mov r3, #1				@; r3 orientaci�n a mirar (sur=1)
				mov r0, r10				@;le pasamos por r0 la matriz a cuenta_repeticiones
				bl cuenta_repeticiones	@; comprobamos el valor de c para ver si hay que mirar a m�s direcciones
				cmp r0, #3				@; comprobar si hay secuencia
				bhs .LhaySecu
				mov r0, #0
				cmp r2, #COLUMNS-3
				bls .Leste				@; si c es menor que seis tambi�n hay que mirar al este
				bgt .LnextElem
				
			.Leste:
				mov r3, #0 				@;orientaci�n al este (este=0)
				mov r0, r10				@;le pasamos por r0 la matriz a cuenta_repeticiones
				bl cuenta_repeticiones
				cmp r0, #3				@; comprobar si hay secuencia
				bhs .LhaySecu
				mov r0, #0
				blo .LnextElem		@; si es menor que tres mirar el siguiente elemento
			.LhaySecu:
				mov r0, #1 					@;si hay secuencia devolvemos r0=1
		.Lfin:

		pop {r1-r7,r10, pc}



@;TAREA 1D;
@; elimina_secuencias(*matriz, *marcas): rutina para eliminar todas las
@;	secuencias de 3 o m�s elementos repetidos consecutivamente en horizontal,
@;	vertical o combinaciones, as� como de reducir el nivel de gelatina en caso
@;	de que alguna casilla se encuentre en dicho modo; 
@;	adem�s, la rutina marca todos los conjuntos de secuencias sobre una matriz
@;	de marcas que se pasa por referencia, utilizando un identificador �nico para
@;	cada conjunto de secuencias (el resto de las posiciones se inicializan a 0). 
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
	.global elimina_secuencias
elimina_secuencias:
		elimina_secuencias:
		push {r2-r9, lr}
		
		mov r6, #0
		mov r8, #0				@;R8 es desplazamiento posiciones matriz
	.Lelisec_for0:
		strb r6, [r1, r8]		@; bucle para poner matriz de marcas a cero
		add r8, #1
		cmp r8, #ROWS*COLUMNS
		blo .Lelisec_for0
		
		bl marcar_horizontales
		bl marcar_verticales	@; despu�s de llamar a estas dos funciones la matriz de marcas estar� marcada completamente
		
		mov r6, #0
		mov r2, #0				@;fila
		mov r3, #0				@;col
		
		add r4, r1, r6			@; apuntar al elemento en la posici�n (f,c)r6
		ldrb r5, [r4]			@; elemento de la posicion
		.LBuscarMarcas:
			cmp r5, #0
			bne .Lmarcado
			.LnextEl:	
				add r3, #1
				cmp r3, #COLUMNS
				moveq r3, #0
				addeq r2, #1
				add r6, #1
				cmp r6, #ROWS*COLUMNS
				bhs .Lend
				add r4, r1, r6			@; apuntar al elemento en la posici�n (f,c)r6
				ldrb r5, [r4]			@; elemento de la posicion
				b .LBuscarMarcas
			.Lmarcado:
				add r9, r0, r6					@; apuntar al elemento en la posici�n (f,c)r6
				ldrb r7, [r9]					@; elemento de la posicion
				cmp r7, #17
				bhs .LPoner8
				blo .LPoner0
				.LPoner8:
					mov r8, #8
					strb r8, [r0, r6]
					mov r10, r0
					mov r11, r1
					mov r0, r2
					mov r1, r3
					bl elimina_gelatina
					mov r0, r10
					mov r1, r11
				b .LnextEl
				.LPoner0:
					mov r8, #0
					strb r8, [r0, r6]
					mov r10, r0
					mov r11, r1
					mov r0, r2
					mov r1, r3
					bl elimina_elemento
					mov r0, r10
					mov r1, r11
				b .LnextEl
		.Lend:
		
		pop {r2-r9, pc}

	
@;:::RUTINAS DE SOPORTE:::



@; marcar_horizontales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en horizontal, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que empezar� siempre por 1 y se ir�
@;	incrementando para cada nueva secuencia, y cuyo �ltimo valor se guardar� en
@;	la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia).
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� toda a ceros
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_horizontales:
		push {r2-r12, lr}
		
		mov r9, #ROWS*COLUMNS
		sub r9, #3
		mov r8, #0				@; num_sec
		mov r10, r0				@; movemos de registro la direcci�n de la matriz de juego para no perderla
		mov r11, r1				@; movemos de registro la direcci�n de la matriz de marcas para no perderla
		mov r1, #0				@; fila inicial para recorrer la matriz
		mov r2, #0				@; columna inicial para recorrer la matriz
		mov r7, #COLUMNS		@; dim
		mla r6, r1, r7, r2		@; f*dim+c = indice de la matriz
		add r4, r0, r6			@; apuntar al elemento en la posici�n (f,c)r6
		ldrb r5, [r4]			@; elemento de la posicion
		and r5, #7				@; en r5 tendremos el valor filtrado del elemento
		.LWhileElem:					@; en este while se comprueba que el elemento filtrado
			cmp r5, #6					@; sea un elemento para evitar huecos, casillas vacias,etc.
			bgt .LsigElem				@; se va avanzando en la matriz hasta el final a medida que se evitan las
			cmp r5, #0					@; posiciones invalidas y se va encontrando alguna secuencia.
			beq .LsigElem
			bhi .LcompSecu
			.LsigElem:
				cmp r2, #6					@; para una fila se miran los elementos hasta la columna 6 ya que estamos mirando hacia el este y si en la
				blo .LsigCol				@; columna 6 no se ha encontrado elemento en esa fila ya no hay combinaci�n hacia el este
				bhs .LsigFila				@; si ya hemos llegado a la columa 6 toca avanzar a la siguiente fila
				.LsigCol:
					add r2, #1
					mla r6, r1, r7, r2		@; cuando lleguemos a f=8 y c=6 ya se habr�n comprobado si hay combinaciones para toda la matriz
					cmp r6, r9          	@; comprobamos que no se haya terminado la matriz en la posici�n 78 se puede salir porque seguir
					bhi .Lfi				@; mirando los elementos y secuencias ser�a innecesario porque ya habr�an sido mirados antes.
					add r4, r10, r6			
					ldrb r5, [r4]			
					and r5, #7
					b .LWhileElem
				.LsigFila:
					mov r2, #0				@; para pasar a la siguiente fila nos colocamos en c=0 y fila++;
					add r1, #1
					mla r6, r1, r7, r2	
					cmp r6, r9				@; comprobamos no haber terminado la matriz
					bhi .Lfi
					add r4, r10, r6			
					ldrb r5, [r4]			
					and r5, #7
					b .LWhileElem
		.LcompSecu:
			mov r0, r10
			mov r3, #0 						@;orientaci�n al este (este=0)
			bl cuenta_repeticiones
			cmp r0, #3
			blo .LsigElem
			add r8, #1						@; num_sec se a�ade 1 cada vez que hay una secuencia que marcar
			.Lmarcar:
				strb r8, [r11, r6]			@; marcar a con id en la matriz de marcas
				sub r0, #1					@; es decir hasta que el numero de lementos consecutivos iguales sea 0, toda la secuencia con su id
				cmp r0, #0					@; cuando sea 0 se habr� acabado de marcar
				beq .LsigElem
				add r2, #1					@; avanzamos una columna a marcar hasta que r0 sea 0, estamos marcando hasta que la secuencia se acabe
				mla r6, r1, r7, r2			@; f*dim+c = indice de la matriz
				b .Lmarcar
		.Lfi:
		mov r0, r10
		mov r1, r11
		ldrb r12, =num_sec					@; guardar en num_sec el �ltimo id utilizado
		strb r8, [r12]
		
		pop {r2-r12, pc}



@; marcar_verticales(mat): rutina para marcar todas las secuencias de 3 o m�s
@;	elementos repetidos consecutivamente en vertical, con un n�mero identifi-
@;	cativo diferente para cada secuencia, que seguir� al �ltimo valor almacenado
@;	en la variable global 'num_sec'; las marcas se guardar�n en la matriz que se
@;	pasa por par�metro 'mat' (por referencia);
@;	sin embargo, habr� que preservar los identificadores de las secuencias
@;	horizontales que intersecten con las secuencias verticales, que se habr�n
@;	almacenado en en la matriz de referencia con la rutina anterior.
@;	Restricciones:
@;		* se supone que la matriz 'mat' est� marcada con los identificadores
@;			de las secuencias horizontales
@;		* la variable 'num_sec' contendr� el siguiente indentificador (>1)
@;		* para detectar secuencias se invocar� la rutina 'cuenta_repeticiones'
@;			(ver fichero "candy1_move.s")
@;	Par�metros:
@;		R0 = direcci�n base de la matriz de juego
@;		R1 = direcci�n de la matriz de marcas
marcar_verticales:
		push {r2-r12, lr}
		
		ldrb r8, =num_sec		@; en r8 tendremos el valor del �ltimo id de horizontales
		ldrb r8, [r8]
		mov r10, r0				@; movemos de registro la direcci�n de la matriz de juego para no perderla
		mov r11, r1				@; movemos de registro la direcci�n de la matriz de marcas para no perderla
		mov r1, #0				@; fila inicial para recorrer la matriz
		mov r2, #0				@; columna inicial para recorrer la matriz
		mov r7, #COLUMNS		@; dim
		mla r6, r1, r7, r2		@; f*dim+c = indice de la matriz
		add r4, r0, r6			@; apuntar al elemento en la posici�n (f,c)r6
		ldrb r5, [r4]			@; elemento de la posicion
		and r5, #7				@; en r5 tendremos el valor filtrado del elemento
		.LwhileElem:					@; en este while se comprueba que el elemento filtrado
			cmp r5, #6			@; sea un elemento para evitar huecos, casillas vacias,etc.
			bgt .LSigElem				@; se va avanzando en la matriz hasta el final a medida que se evitan las
			cmp r5, #0					@; posiciones invalidas y se va encontrando alguna secuencia.
			beq .LSigElem
			bhi .LCompSecu				@; si es elemento simple comprobamos la secuencia
			.LSigElem:
				cmp r1, #ROWS-3					@; para una columna se miran los elementos hasta la fila 6 ya que estamos mirando hacia el sur y si en la
				blo .LSigFila				@; fila 6 no se ha encontrado elemento en esa columna ya no hay combinaci�n hacia el sur
				bhs .LSigCol				@; si ya hemos llegado a la fila 6 toca avanzar a la siguiente fila
				.LSigCol:
					cmp r2, #COLUMNS-1
					beq .Lfinal
					mov r1, #0				@; para pasar a la siguiente columna nos colocamos en fila=0 y c++;
					add r2, #1
					mla r6, r1, r7, r2		@; cuando lleguemos a f=6 y c=8 ya se habr�n comprobado si hay combinaciones para toda la matriz
					cmp r6, #31				@; comprobamos que no se haya terminado la matriz en la posici�n 78 se puede salir porque seguir
					bhi .Lfinal				@; mirando los elementos y secuencias ser�a innecesario porque ya habr�an sido mirados antes.
					add r4, r10, r6			
					ldrb r5, [r4]			
					and r5, #7
					b .LwhileElem
				.LSigFila:
					add r1, #1				@; se a�ade 1 a la fila y se calcula el indice, se coge el valor del elemento y volvemos al bucle
					mla r6, r1, r7, r2		@; que comprueba si es un elemento v�lido
					cmp r6, #31				@; comprobamos no haber terminado la matriz, si es el caso salir de la funci�n
					bhi .Lfinal
					add r4, r10, r6			
					ldrb r5, [r4]			
					and r5, #7
					b .LwhileElem
		.LCompSecu:
			mov r0, r10						@; colocamos los valores necesarios para pasarle a cuenta_repeticiones
			mov r3, #1 						@;orientaci�n al sur (sur=1)
			bl cuenta_repeticiones
			cmp r0, #3						@; si es menor que tres saltamos al bucle de buscar un elemento v�lido
			blo .LSigElem
			mov r9, r0         				@; no perder el valor de cuenta repeticiones
			mov r12, r1						@; no perder el valor de la fila ya que cuando miremos si hay id nos moveremos de fila
			.LmirarID:						@; como hay secuencia miramos si hay id
				sub r0, #1					@; vamos a ir mirando las posiciones dependiendo del la medida de la secuencia
				add r4, r11, r6				@; mirar en la matriz de marcas lo que hay en la posici�n de r6	
				ldrb r5, [r4]
				mov r3, r5					@; guardamos en r3 el valor del id, para el caso queen una secu hubiese m�s de un id
				cmp r5, #0
				bne .LIDhor					@; si la posici�n es distinta de 0 es que ya hay id de una secu horizontal y vamos a mirar si hay m�s o marcar directamente con ese id
				cmp r0, #0
				beq .LIDnuevo				@; si llegamos a r0=0 sin encontrar ninguna posic�n con un id marcamos con un id nuevo
				add r1, #1					@; si a�n no hemos mirado en toda la secuencia a�adimos una fila para mirar el id en esa posici�n(r=!=0 y r5=0)
				mla r6, r1, r7, r2			@; f*dim+c
				b .LmirarID
			.LIDhor:
				cmp r0, #0
				beq .LmarcarIDhor1			@; si se acaba de mirar la secuencia y no hay m�s id se salta a marcar con el id primero que hemos encontrado
				sub r0, #1					@; vamos a ir mirando las posiciones dependiendo del la medida de la secuencia
				add r1, #1					@; si a�n no hemos mirado en toda la secuencia a�adimos una fila para mirar el id en esa posici�n
				mla r6, r1, r7, r2			@; f*dim+c
				add r4, r11, r6				@; mirar en la matriz de marcas lo que hay en la posici�n de r6	
				ldrb r5, [r4]
				cmp r5, #0					@; mirar si hay id
				bne .LmarcarHayOtroID		@; si la posici�n es distinta de 0 es que ya hay otra posici�n marcada con id
				beq .LIDhor
			.LmarcarHayOtroID:
				mov r5, r3					@; nos quedamos con id de la primera secuencia horizontal que intersecta
				bl remarcarHor
				cmp r0, #0
				bne .LIDhor
			.LmarcarIDhor1:
				mov r1, r12					@;recuperamos valor inicial de la fila para empezar a marcar
				mov r0, r9					@;recuperamos valor de cuenta repeticiones
				mov r5, r3					@; recuperamos id con el que marcar
			.LmarcarIDhor2:
				sub r0, #1					@; es decir hasta que el numero de lementos consecutivos iguales sea 0, toda la secuencia con su id
				mla r6, r1, r7, r2			@; f*dim+c = indice de la matriz en el que marcar			
				strb r5, [r11, r6]			@; marcar con el valor del ID de la horizontal en la matriz de marcas
				cmp r0, #0					@; cuando sea 0 se habr� acabado de marcar
				beq .LSigElem
				add r1, #1					@; avanzamos una fila a marcar hasta que r0 sea 0
				b .LmarcarIDhor2
			.LIDnuevo:
				add r8, #1					@; nuevo id para marcar
				mov r1, r12					@;recuperamos valor inicial de la fila para empezar a marcar
				mov r0, r9					@;recuperamos valor de cuenta repeticiones
			.LmarcarIDnuevo:
				mla r6, r1, r7, r2			@; f*dim+c = indice de la matriz en el que marcar
				strb r8, [r11, r6]			@; marcar con el valor del ID nuevo en la matriz de marcas
				sub r0, #1					@; es decir hasta que el numero de lementos consecutivos iguales sea 0, toda la secuencia con su id
				cmp r0, #0					@; cuando sea 0 se habr� acabado de marcar
				beq .LSigElem
				add r1, #1					@; avanzamos una fila a marcar hasta que r0 sea 0
				b .LmarcarIDnuevo
		.Lfinal:		
		mov r1, r11							@; recolocar valores
		mov r0, r10							@; recuperamos valores y actualizamos num_sec
		
		pop {r2-r12, pc}

@; rutina para remarcar la secuencia horizontal para que el m�ltiple cruce tenga la misma secuencia
@; r1=fila r2= col donde se encuentra el conflicto
@; r5=id con el que marcar
@; r10=tablero juego r11=tablero marcas
remarcarHor:
		push {r0-r9, lr}
		
		mov r8, r5	
		mov r7, #COLUMNS
		mov r0, r10
		mov r3, #0						@;mirar hacie el este si est� la secuencia
		bl cuenta_repeticiones
		cmp r0, #3
		bhs .LsecuE
		blo .LsecuO
		.LsecuE:
			mla r6, r1, r7, r2			@; f*dim+c = indice de la matriz
			strb r8, [r11, r6]			@; marcar id en la matriz de marcas
			add r2, #1					@; avanzamos una columna a marcar hasta que r0 sea 0,
			sub r0, #1					@; es decir hasta que el numero de lementos consecutivos iguales sea 0, toda la secuencia con su id
			cmp r0, #0					@; cuando sea 0 se habr� acabado de marcar
			beq .Lsalir
			b .LsecuE
		.LsecuO:
			sub r0, #1					@; le quitamos a r0 1 porque son las posiciones que nos queremos mover sin contar la que ya estamos
			add r2, r0					@; si hacia el este no ha encontrado secuencia nos movemos r0 columnas  miramos hacia el oeste para asegurarnos de marcar la secuencia entera
			mov r0, r10
			mov r3, #2
			bl cuenta_repeticiones		@; miramos hacia el oeste
			.LmarcarO:
				sub r0, #1				@; hasta que el numero de lementos consecutivos iguales sea 0, toda la secuencia con su id
				mla r6, r1, r7, r2		@; f*dim+c = indice de la matriz
				strb r8, [r11, r6]		@; marcar id en la matriz de marcas
				sub r2, #1				@; retrocedemos una columna a marcar hasta que r0 sea 0,
				cmp r0, #0				@; cuando sea 0 se habr� acabado de marcar
				beq .Lsalir
				b .LmarcarO
		.Lsalir:
		pop {r0-r9, pc}
.end
