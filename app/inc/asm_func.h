#pragma once

#include <stdint.h>


extern uint32_t asm_sum (uint32_t firstOperand, uint32_t secondOperand);
extern void asm_svc (void);
extern void asm_zero (uint32_t *vector, uint32_t longitud);
