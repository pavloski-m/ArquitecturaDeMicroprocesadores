#pragma once

#include <stdint.h>


extern uint32_t asm_sum (uint32_t firstOperand, uint32_t secondOperand);
extern void asm_svc (void);
extern void asm_zero (uint32_t *vector, uint32_t longitud);
extern void asm_prod32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
extern void asm_prod16 (uint16_t * vectorIn, uint16_t * vectorOut, uint16_t longitud, uint32_t escalar);
extern void asm_prod12 (uint16_t * vectorIn, uint16_t * vectorOut, uint16_t longitud, uint32_t escalar);
extern void asm_vent10 (uint16_t* vectorIn, uint16_t* vectorOut, uint32_t longitudVectorIn);
extern void asm_pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud);
extern int32_t asm_max (int32_t * vectorIn, uint32_t longitud);
extern void asm_invertir (uint16_t * vector, uint32_t longitud);
extern void asm_eco_SIMD (int16_t * vectorIn, int16_t * vectorOut, uint32_t longitud);
