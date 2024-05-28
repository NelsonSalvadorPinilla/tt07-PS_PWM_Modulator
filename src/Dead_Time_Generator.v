`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: POWERLAB, DEPARTAMENTO DE ELECTRONICA, UTFSM
// Engineer: GONZALO CARRASCO REYES
//
// Create Date:    12:24:55 10/09/2007
// Design Name:
// Module Name:    Dead_Time_Geneartr
// Project Name:
// Target Devices:
// Tool versions:
// Description:	El modulo recibe una senal digital de 1 bit, y entrega la misma
//						senal de entrada con un retardo en el canto de subida. Este
//						retardo llamado tiempo muerto, es configurable con una palabra
//						de 10 bits, que permite fijar tiempos en pasos de un periodo del 
//						reloj del reloj de 150MHz, que tambien debe recibir.
//
// Dependencies:	Depende de una senal de reloj, la configuracion del tiempo
//						muerto y de la senal de entrada.
//							clk	- Entrada de 150MHz
//							dt		- Tiempo muerto
//							gi		- Senal de entrada
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module Dead_Time_Generator(clk, dt, gi, go);

	(* clock_signal = "yes" *)
	input               	clk;        //Reloj principal de 150MHz
	input   	[4:0]   	dt;         //Configuracion de tiempos muertos
	input               	gi;         //Senal a retardar (tiempo muerto)
	output reg          	go;         //Senal retardada (tiempo muerto)
	//----------------------------------------------------------------------------
	//Variables internas
	wire             		dt_end;    	//Senal de fin del tiempo muerto
	reg     [4:0]       	count_dt;   //Contador para el tiempo  muerto
	///////////////////////////////////////////////////////////////////////////////
	
	//Comparacion asincronica de el contador de tiempo muerto
	assign dt_end = ( count_dt >= dt ) ? 1 : 0;
	
	//Conteo para retardar el canto de subida, tiempo muerto
	always @(posedge clk) begin
	  if (gi == 0)
			count_dt = 0;
	  else
			if (!dt_end)
				 count_dt = count_dt + 1;
	end
	
	//----------------------------------------------------------------------------
	//Generacion de senal de salida
	always @(posedge clk)begin
	  if (gi == 0)
			go = 0;
	  else
			if (dt_end)
				 go = 1;
			else
				 go = 0;
	end
	///////////////////////////////////////////////////////////////////////////////
endmodule
