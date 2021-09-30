.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zero
.global asm_prod32
.global asm_prod16

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
		str		r4,[r1],4	@ r1* = r6 ; r1*+4
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
		ldrh	r4,[r0],2	@ r4 = r0* ; r0*+4
		mul		r4,r3	@ r4 = r4 * r5
		str		r4,[r1],2	@ r1* = r6 ; r1*+4
		subs	r2,1		@ r2 = r2-1 con s actualizamos los flags
		bne		.loop_mul16	@ salta a loop c/ vez que z es 0.

		pop {r4}

		bx lr



