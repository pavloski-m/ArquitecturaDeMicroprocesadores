#include "c_func.h"


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand)
{
    return (firstOperand + secondOperand);
}

void c_zeros (uint32_t *vector, uint32_t longitud){

	for(uint32_t i=0; i<longitud; i++){
		vector[i]=0;
	}
}

void c_productoEscalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t longitud, uint32_t escalar){

	for(uint32_t i=0; i<longitud; i++){
		vectorOut[i] = escalar * vectorIn[i];
	}
}

void c_productoEscalar16 (uint16_t * vectorIn, uint16_t * vectorOut, uint16_t longitud, uint32_t escalar){

	for(uint32_t i=0; i<longitud; i++){
		vectorOut[i] = escalar * vectorIn[i];
	}
}

void c_productoEscalar12 (uint16_t * vectorIn, uint16_t * vectorOut, uint16_t longitud, uint32_t escalar){
	for(uint32_t i=0; i<longitud; i++){
			vectorOut[i] = escalar * vectorIn[i];
			if (vectorOut[i] > 0xFFF){
				vectorOut[i] = 0xFFF;
			}
		}
}

void c_filtroVentana10 (uint16_t* vectorIn, uint16_t* vectorOut, uint32_t longitudVectorIn){
	uint32_t acumAux = 0;
	uint32_t i=0;
	while( i < longitudVectorIn + 9){
		if(i<9){
			acumAux += vectorIn[i];
			vectorOut[i] = acumAux/(i+1);
		}
		else{
			acumAux +=vectorIn[i]-vectorIn[i-10];
			vectorOut[i] = acumAux/10;
	}
		i++;
}
}
