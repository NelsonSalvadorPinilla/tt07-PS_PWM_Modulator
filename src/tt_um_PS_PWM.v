`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Top 
// Module Name: Top
// Project Name: TT05 Modulacion PS-PWM para 3L-FCC
//////////////////////////////////////////////////////////////////////////////////


module tt_um_PS_PWM(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    
    assign uio_oe = 8'b00000000; //todos input
    assign uio_out = 8'b00000000;

/**************** Conexiones ****************/   

    wire RST;
    assign RST= ~rst_n;

    wire [5:0] d1;
    wire [5:0] d2;
    assign d1 = ui_in[5:0];
    assign d2 = {ui_in[7:6], uio_in[3:0]};

    wire CLK_SR;
    wire Data_SR;
    assign CLK_SR = uio_in[4];
    assign Data_SR = uio_in[5];

    wire CLK_INT;
    wire CLK_EXT;
    assign CLK_INT= clk;
    assign CLK_EXT= uio_in[6];

    wire PMOS1;      // Senal de control del transistor PMOS 1 
    wire NMOS2;      // Senal de control del transistor NMOS 2 
    wire PMOS2;     // Senal de control del transistor PMOS 2 
    wire NMOS1;      // Senal de control del transistor NMOS 1 
    wire CLK_OUTPUT;

    
/**************** ETAPA DE SHIFT REGISTER ****************/
wire CLK_SELECTOR;
wire [4:0] dt;
wire [1:0] SELECTOR_SIGNAL_GENERATOR_1; // escoge el desfase que tendra la triangular 1
wire [1:0] SELECTOR_SIGNAL_GENERATOR_2; // escoge el desfase que tendra la triangular 2
wire ENABLE_OUTPUT;

Shift_Register Shift_Register_Inst(
    CLK_SR,
    RST,
    Data_SR,
    {ENABLE_OUTPUT, CLK_SELECTOR, SELECTOR_SIGNAL_GENERATOR_2[1],SELECTOR_SIGNAL_GENERATOR_2[0],SELECTOR_SIGNAL_GENERATOR_1[1],SELECTOR_SIGNAL_GENERATOR_1[0], dt[4], dt[3], dt[2], dt[1], dt[0]}
);

// El orden para meter los datos es (de primero a ultimo): 
// dt[0]
// dt[1]
// dt[2]
// dt[3]
// dt[4]
// SELECTOR_SIGNAL_GENERATOR_1[0]
// SELECTOR_SIGNAL_GENERATOR_1[1]
// SELECTOR_SIGNAL_GENERATOR_2[0]
// SELECTOR_SIGNAL_GENERATOR_2[1]
// CLK_SELECTOR
// ENABLE_OUTPUT

/**************** ETAPA DE MUX CLK ****************/

wire clk_in;

// Si CLK_SELECTOR es 0 -> se usa clk del PLL, si es 1 -> se usa el clk del pin externo
assign clk_in = CLK_SELECTOR ? CLK_EXT : CLK_INT;
assign CLK_OUTPUT= clk;

/**************** ETAPA DE TRIANGULARES ****************/

// Fases de la triangular 1
wire [5:0] triangular_1_0;
Signal_Generator_0phase Signal_Generator_1_0phase_inst(
    clk_in,
    RST,
    triangular_1_0
);

wire [5:0] triangular_1_90;
Signal_Generator_90phase Signal_Generator_1_90phase_inst(
    clk_in,
    RST,
    triangular_1_90
);

wire [5:0] triangular_1_180;
Signal_Generator_180phase Signal_Generator_1_180phase_inst(
    clk_in,
    RST,
    triangular_1_180
);

wire [5:0] triangular_1_270;
Signal_Generator_270phase Signal_Generator_1_270phase_inst(
    clk_in,
    RST,
    triangular_1_270
);

// Fases de la triangular 2
wire [5:0] triangular_2_0;
Signal_Generator_0phase Signal_Generator_2_0phase_inst(
    clk_in,
    RST,
    triangular_2_0
);

wire [5:0] triangular_2_90;
Signal_Generator_90phase Signal_Generator_2_90phase_inst(
    clk_in,
    RST,
    triangular_2_90
);

wire [5:0] triangular_2_180;
Signal_Generator_180phase Signal_Generator_2_180phase_inst(
    clk_in,
    RST,
    triangular_2_180
);

wire [5:0] triangular_2_270;
Signal_Generator_270phase Signal_Generator_2_270phase_inst(
    clk_in,
    RST,
    triangular_2_270
);

/**************** ETAPA DE MUX Triangulares ****************/

// Triangular 1
reg [5:0] triangular_1;
always @(*) begin

    // SELECTOR_SIGNAL_GENERATOR_2 selecciona la fase de la triangular_1
    case(SELECTOR_SIGNAL_GENERATOR_1)           
           2'd0  : triangular_1 = triangular_1_0;
           2'd1  : triangular_1 = triangular_1_90;
           2'd2  : triangular_1 = triangular_1_180;
           2'd3  : triangular_1 = triangular_1_270;
           default : triangular_1 = 0;
       endcase

end

// Triangular 2
reg [5:0] triangular_2;
always @(*) begin

    // SELECTOR_SIGNAL_GENERATOR_2 selecciona la fase de la triangular_2
    case(SELECTOR_SIGNAL_GENERATOR_2)           
           2'd0  : triangular_2 = triangular_2_0;
           2'd1  : triangular_2 = triangular_2_90;
           2'd2  : triangular_2 = triangular_2_180;
           2'd3  : triangular_2 = triangular_2_270;
           default : triangular_2 = 0;
       endcase

end

/**************** ETAPA DE COMPARACION ****************/

wire Output_Comparison_1;
Comparator Comparator_Inst_1(
    d1,
    triangular_1,
    Output_Comparison_1
);

wire Output_Comparison_2;
Comparator Comparator_Inst_2(
    d2,
    triangular_2,
    Output_Comparison_2
);

/**************** ETAPA DE DEAD-TIME GENERATOR ****************/

wire pmos1_int; 
Dead_Time_Generator Dead_Time_Generator_inst_1(
    clk_in,
    dt,
    Output_Comparison_1,
    pmos1_int
);

wire Not_Output_Comparison_1;
wire nmos2_int;
assign Not_Output_Comparison_1 = ~Output_Comparison_1;
Dead_Time_Generator Dead_Time_Generator_inst_2(
    clk_in,
    dt,
    Not_Output_Comparison_1,
    nmos2_int
);

wire pmos2_int;
Dead_Time_Generator Dead_Time_Generator_inst_3(
    clk_in,
    dt,
    Output_Comparison_2,
    pmos2_int
);

wire Not_Output_Comparison_2;
wire nmos1_int;
assign Not_Output_Comparison_2 = ~Output_Comparison_2;
Dead_Time_Generator Dead_Time_Generator_inst_4(
    clk_in,
    dt,
    Not_Output_Comparison_2,
    nmos1_int
);

/**************** ETAPA DE MUX OUTPUT INTERNA ****************/

wire PMOS1_prev, NMOS2_prev, PMOS2_prev, NMOS1_prev;

// Si OUTPUT_SELECTOR_INTERNAL es 0 -> salidas vienen del modulador , si es 1 -> vienen offchip
assign PMOS1_prev = ~pmos1_int; // TIENE EL NEGADOR POR EL PMOS
assign NMOS2_prev = nmos2_int;
assign PMOS2_prev = ~pmos2_int; // TIENE EL NEGADOR POR EL PMOS
assign NMOS1_prev = nmos1_int;

/**************** ETAPA ENABLE OUTPUTs ****************/

// Si ENABLE_OUTPUT es 0 -> los 4 transistores cmos estan en corte, si es 1 -> las salidas de los 4 cmos viene dada segun su logica previa, 
assign PMOS1 = ENABLE_OUTPUT ? PMOS1_prev : 1; 
assign NMOS2 = ENABLE_OUTPUT ? NMOS2_prev : 0;
assign PMOS2 = ENABLE_OUTPUT ? PMOS2_prev : 1;
assign NMOS1 = ENABLE_OUTPUT ? NMOS1_prev : 0;

    assign uo_out[0]= PMOS1;
    assign uo_out[1]= NMOS2;
    assign uo_out[2]= PMOS2;
    assign uo_out[3]= NMOS1;
    assign uo_out[4]= clk_in;
    assign uo_out[7:5]= 3'b000;

endmodule
