#include "board.h"
#include "c_func.h"
#include "asm_func.h"

#include <stdlib.h>
#include <stdnoreturn.h>

#define DWT_CONTROL             (*((volatile uint32_t*)0xE0001000))
#define DWT_CYCCNT              (*((volatile uint32_t*)0xE0001004))
#define DWT_CYCCNTENA_BIT       (1<<0)

#define EnableCycleCounter()    DWT_CONTROL |= DWT_CYCCNTENA_BIT
#define GetCycleCounter()       DWT_CYCCNT
#define ResetCycleCounter()     DWT_CYCCNT = 0
#define DisableCycleCounter()   DWT_CONTROL &= ~DWT_CYCCNTENA_BIT

// Variable que se incrementa cada vez que se llama al handler de interrupcion
// del SYSTICK.
static volatile uint32_t s_ticks = 0;


// Inicia soporte de la placa y periodo de la interrupcion del SYSTICK
// cada 1 milisegundo.
static void Inicio (void)
{
    Board_Init ();
    SystemCoreClockUpdate ();
    SysTick_Config (SystemCoreClock / 1000);
}


// Segun la configuracion realizada en Inicio(), este handler de interrupcion
// se ejecutara cada 1 milisegundo.
void SysTick_Handler (void)
{
    ++ s_ticks;
}


static void Suma (void)
{
    const uint32_t A = 20;
    const uint32_t B = 30;

    const uint32_t SumResult_C = c_sum (A, B);
    const uint32_t SumResult_Asm = asm_sum (A, B);

    // Actividad de debug: SumResult_C y SumResult_Asm deberian contener el
    // mismo valor.
    __BKPT (0);

    (void) SumResult_C;
    (void) SumResult_Asm;
}



static void Zeros (void){
	uint32_t vectorEj1 [8] = {(uint32_t)-1,(uint32_t)-2,(uint32_t)-3,
							  (uint32_t)-4,(uint32_t)-5,(uint32_t)-6,
							  (uint32_t)-7,(uint32_t)-8};

	c_zeros(vectorEj1, 8);

	asm_zero(vectorEj1, 8);
}


static void prodEscalar32 (void)
{
	uint32_t vectorInEj2 [8] = { 5, 10, 15, 20, 25, 30, 35, 40};
	uint32_t escalar = 50;
	uint32_t vectorOutEj2 [8] = { 0, 0, 0, 0, 0, 0, 0, 0};
	uint32_t longitud = sizeof(vectorInEj2) / sizeof(typeof(vectorInEj2[0]));

	//c_productoEscalar32(vectorInEj2, vectorOutEj2, longitud, escalar);

	asm_prod32(vectorInEj2, vectorOutEj2, longitud, escalar);
}

static void prodEscalar16 (void)
{	uint32_t cycCountC;
	uint32_t cycCountASM;

	uint16_t vectorInEj3 [1000];
	uint32_t escalar = 20;
	uint16_t vectorOutEj3 [1000];

	uint16_t longitud = sizeof(vectorInEj3) / sizeof(typeof(vectorInEj3[0]));

	EnableCycleCounter();
	ResetCycleCounter();

	asm_prod16(vectorInEj3, vectorOutEj3, longitud, escalar);
	cycCountASM = GetCycleCounter(); // da 9023 ciclos

	ResetCycleCounter();

	c_productoEscalar16 (vectorInEj3, vectorOutEj3, longitud, escalar);
	cycCountC = GetCycleCounter(); // da 32079 ciclos

	ResetCycleCounter();
	DisableCycleCounter();

}

static void prodEscalar12 (void)
{	volatile uint32_t cycCountC;
	volatile uint32_t cycCountASM;

	uint16_t vectorInEj4 [1000];
	for (int i=0; i<1000; i++){
		vectorInEj4[i] = 0xFF00;
	}
	uint32_t escalar = 0xFFFF;
	uint16_t vectorOutEj4 [1000] = {0};


	uint16_t longitud = sizeof(vectorInEj4) / sizeof(typeof(vectorInEj4[0]));

	EnableCycleCounter();
	ResetCycleCounter();

	asm_prod12(vectorInEj4, vectorOutEj4, longitud, escalar);
	cycCountASM = GetCycleCounter(); // da 9023 ciclos

	ResetCycleCounter();

	c_productoEscalar12 (vectorInEj4, vectorOutEj4, longitud, escalar);
	cycCountC = GetCycleCounter(); // da 32079 ciclos

	ResetCycleCounter();
	DisableCycleCounter();

}

static void filtroVentana10 (void){

	uint16_t vectorInEj5 [1000];

	for (int i=0; i<1000; i++){
		vectorInEj5[i] = i%20;
	}

	uint16_t vectorOutEj5 [1000] = {0};

	uint16_t longitud = sizeof(vectorInEj5) / sizeof(typeof(vectorInEj5[0]));

	c_filtroVentana10 (vectorInEj5, vectorOutEj5, longitud);

	//asm_vent10 (vectorInEj5, vectorOutEj5, longitud);


}


static void pack32to16(void){

	int32_t vectorInEj6 [1000];

	for (int i=0; i<1000; i++){
		vectorInEj6[i] = 0xFF00;
	}

	int16_t vectorOutEj6 [1000] = {0};

	uint32_t longitud = sizeof(vectorInEj6) / sizeof(typeof(vectorInEj6[0]));

	c_pack32to16 (vectorInEj6, vectorOutEj6, longitud);

	asm_pack32to16 (vectorInEj6, vectorOutEj6, longitud);

}


static void max(void){
	int32_t vectorInEj7 [1000];

	for (int i=0; i<1000; i++){
		vectorInEj7[i] = 0xFF00;
	}

	uint32_t longitud = sizeof(vectorInEj7) / sizeof(typeof(vectorInEj7[0]));

	c_max (vectorInEj7, longitud);

	asm_max (vectorInEj7, longitud);

}


static void downsampleM(void){

}


static void invertir(void){
	uint16_t vectorInEj9 [1000];

	for (int i=0; i<1000; i++){
		vectorInEj9[i] = 0xFF00;
	}

	uint32_t longitud = sizeof(vectorInEj9) / sizeof(typeof(vectorInEj9[0]));

	c_invertir (vectorInEj9, longitud);

	asm_invertir (vectorInEj9, longitud);

}

static void eco (void){

}

static void LlamandoAMalloc (void)
{
    // De donde saca memoria malloc?
    // (se vera en clase)
    void * ptr = malloc (2048);

    (void) ptr;
}

static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo suma.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}


// Handler de la interrupcion "SVC" (Supervisor Call).
// Usado por el ejemplo "EjemploPrivilegiosSVC".
void SVC_Handler (void)
{
    // Se obtiene el valor del registro "control". El bit 0 indica el nivel
    // de privilegio en modo "Thread". Deberia ser 1: No privilegiado.
    uint32_t x = __get_CONTROL ();

    // Borra el bit 0. Nuevo valor 0: privilegiado.
    x &= ~1u;

    // Asigna el nuevo valor al registro "control". Esta operacion deberia
    // ejecutarse ya que todo manejador de interrupciones se ejecuta en modo
    // "Handler" con total privilegio.
    __set_CONTROL (x);
}


noreturn void LoopInfinito (void)
{
    while (1)
    {
        // Procesador en modo espera hasta que ocurra una interrupcion
        // (Bajo consumo)
        __WFI();
    }
}


int main (void)
{
    Inicio ();

    // Suma ();

    // Zeros();

    // prodEscalar32();

    //prodEscalar16();

    //prodEscalar12();

    filtroVentana10();

    //pack32to16();

	//max();

	//downsampleM();

	//invertir();

    // eco();

	PrivilegiosSVC ();

    LlamandoAMalloc ();

    LoopInfinito ();
}
