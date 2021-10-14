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
	while( i < longitudVectorIn){
		if(i<9){
			acumAux += vectorIn[i];
			vectorOut[i] = acumAux/(i+1);
		}
		else{
			acumAux +=(vectorIn[i]-vectorIn[i-10]);
			vectorOut[i] = acumAux/10;
	}
		i++;
}
}


void c_pack32to16 (int32_t *vectorIn, int16_t *vectorOut, uint32_t longitud){

	int32_t aux = 0;

	for( uint32_t i = 0; i<longitud; i++ ){
				 aux = vectorIn[i]/65536;
		vectorOut[i] = (int16_t) aux;
	}
}


int32_t c_max (int32_t *vectorIn, uint32_t longitud){

	int32_t max_value = 0;

	for(uint32_t i = 0; i < longitud; i++){
		if (vectorIn[i] > max_value){
			max_value = vectorIn[i];
		}
	}

	return max_value;
}


void c_downsampleM (int32_t * vectorIn, int32_t * vectorOut, uint32_t longitud, uint32_t N){

}


void c_invertir (uint16_t * vector, uint32_t longitud){
	uint16_t aux=0;

	for(uint32_t i=0; i<longitud/2; i++){
		aux = vector[i];
		vector[i] = vector[longitud-i-1];
		vector[longitud-i-1] = aux;
	}
}


void c_eco (int16_t * vectorIn, int16_t * vectorOut, uint32_t longitud){

	uint32_t desfasaje = 882;

	for (uint32_t i = 0; i < desfasaje; i++){
		vectorOut[i] = vectorIn[i];
	}

	for (uint32_t i = 882; i<longitud-1; i++){
		vectorOut[i] = vectorIn[i-desfasaje]/2 + vectorIn[i];
	}
}
