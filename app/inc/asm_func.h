#pragma once

#include <stdint.h>


extern uint32_t asm_sum (uint32_t firstOperand, uint32_t secondOperand);
extern void asm_svc (void);
extern void asm_zero (uint32_t *vector, uint32_t longitud);
extern void asm_prod32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar);
