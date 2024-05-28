module Comparator(in1, in2, comparison);
  parameter WIDTH_IN1 = 6;
  parameter WIDTH_IN2 = 6;

  input [WIDTH_IN1-1:0] in1;
  input [WIDTH_IN2-1:0] in2;
  output comparison;
  reg comparison;
 
  always @ (in1 or in2)
  begin
      comparison = (in1 >= in2);
  end
endmodule