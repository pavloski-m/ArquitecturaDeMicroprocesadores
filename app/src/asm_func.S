.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zero
.global asm_prod32
.global asm_prod16
.global asm_prod12
.global asm_vent10
.global asm_pack32to16
.global asm_max
.global asm_invertir
.global asm_eco_SIMD
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void zeros (uint32_t *vector, uint32_t longitud)
@
.thumb_func
	asm_zero:
		@ Registros usados
		@ r2: valor cero
		@ r1: cantidad de valores
		@ r0: puntero al vector

		mov r2, 0;		@ constante cero
	.loop_z:
		str r2,[r0, 4]!
		subs r1,1		@ con s actualizamos los flags
		bne .loop_z

		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void c_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar)
@
.thumb_func
	asm_prod32:
		@ Registros usados
		@ r3: escalar
		@ r2: cantidad de valores
		@ r1: puntero al vector Out
		@ r0: puntero al vector In

		push {r4}

	.loop_mul32:
		ldr		r4,[r0],4	@ r4 = r0* ; r0*+4
		mul		r4,r3		@ r4 = r4 * r5
		str		r4,[r1],4	@ r1* = r4 ; r1*+4
		subs	r2,1		@ r2 = r2-1 con s actualizamos los flags
		bne		.loop_mul32	@ salta a loop c/ vez que z es 0.

		pop {r4}

		bx lr



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void c_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint16_t longitud, uint16_t escalar)
@
.thumb_func
	asm_prod16:
		@ Registros usados
		@ r3: escalar
		@ r2: cantidad de valores
		@ r1: puntero al vector Out
		@ r0: puntero al vector In

		push {r4}

	.loop_mul16:
		ldrh	r4,[r0],2	@ r4 = r0* ; r0*+2
		mul		r4,r3		@ r4 = r4 * r3
		strh	r4,[r1],2	@ r1* = r4 ; r1*+2
		subs	r2,1		@ r2 = r2-1 con s actualizamos los flags
		bne		.loop_mul16	@ salta a loop c/ vez que z es 0.

		pop {r4}

		bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint32_t longitud, uint16_t escalar);
@
.thumb_func
	asm_prod12:
		@ Registros usados
		@ r3: escalar
		@ r2: cantidad de valores
		@ r1: puntero al vector Out
		@ r0: puntero al vector In

		push {r4}

	.loop_mul12:
		ldrh	r4,[r0],2	@ r4 = r0* ; r0*+2
		mul		r4,r3		@ r4 = r4 * r3

		usat	r4,12,r4	@ r4 = r4 & 0x0FFF

		strh	r4,[r1],2	@ r1* = r4 ; r1*+2
		subs	r2,1		@ r2 = r2-1 con s actualizamos los flags
		bne		.loop_mul12	@ salta a loop c/ vez que z es 0.

		pop {r4}

		bx lr


.thumb_func
	asm_vent10:
		@ Registros usados
		@ r2: longitud del vector
		@ r1: puntero al vector Out
		@ r0: puntero al vector In
		@===============
		@ r3: acumulador
		@ r4: indice
		@ r5: auxiliar out
		@ r6: auxiliar in
		@ r7: constante 10 para dividir en bucle general

		push {r4-r7}

		mov 	r4,#0		@ r4=0
		mov		r3,#0		@ r3=0
		mov		r7,#10		@ r7=0

	.loop_init:				@ bloque de inicio
		ldrh	r6,[r0],2	@ r6 = *r0 ;  r0+=2
		add		r3,r3,r6	@ r3+=r6 sumo el valor leído al acumulador
		add		r4,1		@ incremento el indice por el que voy a dividir
		udiv	r5,r3,r4	@ r5 = r3 / r4  =>

		strh 	r5,[r1],2 	@ *r1 = r5; r1-=4 cargo al vector de salida
		cmp		r4,#10		@ condicion de salida:  i=10
		bne .loop_init

	.loop_gral:
		ldrh	r6,[r0],-20	@ r6 = *r0 ;  r0+=vuelvo 10 indices atras
		add		r3,r3,r6	@ r3+=r6 sumo el nuevo valor que entra en la ventana al acumulador
		ldrh	r6,[r0],+22	@
		sub		r3,r3,r6	@ acumulado menos el valor de la entrada que ya no entra en la ventana
		add		r4,1		@ incremento el índice
		udiv	r5, r3, r7	@ divido
		strh	r5,[r1],2	@ almaceno el valor promediado  en r5 en la memoria
		cmp		r4,r2		@ comparo si el indice llega al tamaño de la longitud del vector
		bne	.loop_gral

		pop 	{r4-r7}		@ vuelvo a cargar los registros con los valores que tenían antes de la función

		bx		lr			@ retorno de la función



.thumb_func
	asm_pack32to16:
		@ Registros usados
		@ r2: longitud del vector
		@ r1: puntero al vector Out
		@ r0: puntero al vector In
		@===============

		mov		r3,#00
		add		r0,2		@ hago un desfasaje del vector

	.loop_32to16:
		ldrh	r2,[r0],4
		strh	r2,[r1],2
		add		r3,1
		cmp		r3,r2		@ comparo si el indice llega al tamaño de la longitud del vector
		bne	.loop_32to16

		bx		lr



.thumb_func
	asm_max:
		@ Registros usados
		@ r1: longitud del vector
		@ r0: puntero al vector In
		@===============
		@ r2: almaceno max value
		@ r3: variable auxiliar

		mov		r2,#00
	.loop_max:
		ldr		r3,[r0],4
		cmp		r2,r3
		bge		.loop_notmax
		mov		r2,r3
	.loop_notmax:
		subs	r1,#1
		bne		.loop_max

		mov		r0,r2
		bx		lr



.thumb_func
	asm_invertir:
		@ Registros usados
		@ r1: longitud del vector
		@ r0: puntero al vector
		@===============
		@ r2: auxiliar
		@ r3: indice para salir de bucle
		@ r4: auxiliar2

		push 	{r4}


		mov 	r3,r1		@ guardo la longitud para poder usar en el bucle de salida
		sub		r3,#01		@ resto un valor para poder usar la comparación pl al final del ciclo
		mov 	r2,#00		@ inicializo el auxiliar en 0
		sub 	r1,#01		@ decremento la longitud para el primer salto a [longitud-1]

	.loop_vector:
		ldrh	r2,[r0]		@ almaceno el valor del vector en el auxiliar
		add		r0,r1		@ sumo la long restante
		add 	r0,r1		@PROVISORIO
		ldrh	r4,[r0]		@ almaceno el valor final del vector en aux2

		strh	r2,[r0]		@ almaceno desde el final
		sub 	r0,r1		@ vuelvo con el puntero al principio
		sub		r0,r1		@provisorio
		strh	r4,[r0],2	@ almaceno aux2 al principio e incremento el puntero

		sub		r1,#02		@ resto la long del vetor para el salto. 4 porque me acerco 2 valores

		subs 	r3,#02		@ resto el indice en 2 ya que se modificaron 2 valores.
		bpl	.loop_vector	@ si es positivo o cero salto vuelvo al loop

		pop 	{r4}		@ devuelvo el contexto

		bx		lr			@ salgo de la función


.thumb_func
	asm_eco_SIMD:
		@ Registros usados
		@ r1: puntero al vector de salida
		@ r0: puntero al vector entrada
		@ r2: longitud del vector
		@===============
		@ r3: aux puntero 1
		@ r4: constante de desfasaje de tiempo
		@ r5: constante con valor 0 - para la división con SIMD
		@ r6: aux puntero 2

		push    {r4-r6}

		mov		r4,#441  	@ cargo el tamaño del tramo sin eco (20 ms = 882 muestras) , como se lee de a 2 se pone la mitad
		mov		r5,#0

	.loop_init10:
		ldr  	r3,[r0],4	@ cargo en aux el valor de la lectura
		str		r3,[r1],4		@ paso los primeros valores de que no tienen eco
		subs	r4,1		@ decremento para ver si termino el espacio sin eco
		bne		.loop_init10

		mov		r4,#1760	@ vuelvo a cargar para el desfasaje esta vez en catidad de bytes 2 bytes x 882datos
		sub		r0,#1764	@ le resto al puntero la cantidad de bytes que se movió
		sub		r2,#882		@ le resto a la long de salida los valores ya procesados.

	.loop_eco:
		ldr		r3,[r0],4	@ cargo el valor siguiente del vector en aux
		shadd16	r3,r3,r5	@ sumo con halving con SIMD un registro en 0 para dividir
		ldr		r6,[r0,r4]	@ leo el valor en r0+882 datos sin guardar el valor del puntero
		sadd16	r3,r3,r6	@ sumo el 1/2 del valor eco con el valor actual
		str		r3,[r1],4	@ lo guardo en el vector de salida
		subs	r2,#2		@ proceso de a dos valores
		bne 	.loop_eco

		pop     {r4-r6}		@ devuelvo el contexto

		bx		lr
