`timescale 1ns / 1ps

module Shift_Register(
  input wire CLK_SR,
  input wire RST,
  input wire data_in,
  output wire [10:0] data_out
);

  reg [10:0] internal_data [0:10];
  reg [3:0] shift_state;
  integer i;
  
  always @(posedge CLK_SR or posedge RST) begin
    if (RST) begin
      // Reiniciar todas las variables internas a 0 cuando se activa el reset
      for (i = 0; i < 5'd11; i = i + 1) begin
        internal_data[i] <= 0;
      end
      shift_state <= 0;
    end else 
        if (shift_state < 5'd11) begin
          // Almacenar el valor de entrada en la variable interna correspondiente
          internal_data[shift_state] <= data_in;
          // Cambiar al siguiente estado del registro
          shift_state <= shift_state + 1;
        end
end
assign data_out[0] = internal_data[0]; // dt[0]
assign data_out[1] = internal_data[1]; // dt[1]
assign data_out[2] = internal_data[2]; // dt[2]
assign data_out[3] = internal_data[3]; // dt[3] 
assign data_out[4] = internal_data[4]; // dt[4] 
assign data_out[5] = internal_data[5]; // SELECTOR_SIGNAL_GENERATOR_1[0]
assign data_out[6] = internal_data[6]; // SELECTOR_SIGNAL_GENERATOR_1[1]
assign data_out[7] = internal_data[7]; // SELECTOR_SIGNAL_GENERATOR_2[0]
assign data_out[8] = internal_data[8]; // SELECTOR_SIGNAL_GENERATOR_2[1]
assign data_out[9] = internal_data[9]; // OUTPUT_SELECTOR_EXTERNAL[0]
assign data_out[10] = internal_data[10]; // OUTPUT_SELECTOR_EXTERNAL[1]

 


endmodule
