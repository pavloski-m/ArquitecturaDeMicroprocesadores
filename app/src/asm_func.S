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

		mov 	r4,#00		@ r4=0
		mov		r3,#00		@ r3=0

	.loop_init:				@ bloque de inicio
		ldrh	r6,[r0],2	@ r6 = *r0 ;  r0+=2

		add		r3,r3,r6	@ r3+=r6 sumo el valor leído al acumulador

		add		r4,1		@ incremento el indice por el que voy a dividir

		sdiv	r5,r3,r4	@ r5 = r3 / r4  =>

		strh 	r5,[r1],2 // *r1 = r0; r1-=4 cargo al vector de salida

		cmp		r4,#10		@ condicion de salida:  i=10
		bne .loop_init

	.loop_gral:

		ldrh	r6,[r0],-20	@ r6 = *r0 ;  r0+=vuelvo 10 indices atras

		add		r3,r3,r6	@ r3+=r6 sumo el nuevo valor que entra en la ventana al acumulador

		ldr		r6,[r0],+22	@

		sub		r3,r3,r6	@ acumulado menos el valor de la entrada que ya no entra en la ventana

		add		r4,1		@ incremento el índice

		sdiv	r5, r3, r7	@ divido

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








