module mac #(
  parameter int A_WIDTH = 16,
  parameter int B_WIDTH = 16,
  parameter int ACCUMULATOR_WIDTH = 32,
  parameter int OUTPUT_WIDTH = 16,
  parameter int OUTPUT_SCALE = 0
  )
  (
  input logic clk,
  input logic arst_n_in, //asynchronous reset, active low

  //input interface
  input logic input_valid,
  input logic accumulate_internal, //accumulate (accumulator <= a*b + accumulator) if high (1) or restart accumulation (accumulator <= a*b+0) if low (0)
  input logic [ACCUMULATOR_WIDTH-1:0] partial_sum_in,
  input logic signed [A_WIDTH-1:0] a0,
  input logic signed [B_WIDTH-1:0] b0,
  input logic signed [A_WIDTH-1:0] a1,
  input logic signed [B_WIDTH-1:0] b1,
  input logic signed [A_WIDTH-1:0] a2,
  input logic signed [B_WIDTH-1:0] b2,

  //output
  output logic signed [OUTPUT_WIDTH-1:0] out
  );
  /*

              a0 * b0      a1 * b1     a2 -->  *  <-- b2
                 |____________|                |
                        |                      |  ____________
                        +______________________\ /          __\______
                                                +          /1___0__SEL\ <-- accumulate_internal
                                                |           |   \------------ <-- partial_sum_in
                                             ___|___________|----------> >> ---> out__
                                            |  d            q  |
                            input_valid --> |we       arst_n_in| <-- arst_n_in
                                            |___clk____________|
                                                 |
                                                clk
  */

  logic signed [ACCUMULATOR_WIDTH-1:0] product0;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul0
    (.a(a0),
     .b(b0),
     .out(product0));

  logic signed [ACCUMULATOR_WIDTH-1:0] product1;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul1
    (.a(a1),
     .b(b1),
     .out(product1));

  logic signed [ACCUMULATOR_WIDTH-1:0] product2;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul2
    (.a(a2),
     .b(b2),
     .out(product2));


  //makes register with we accumulator_value_we, qout accumulator_value, din accumulator_value_next, clk clk and arst_n_in arst_n_in
  //see register.sv
  `REG(ACCUMULATOR_WIDTH, accumulator_value);
  assign accumulator_value_we = input_valid;
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum0;
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum1;

  logic signed [ACCUMULATOR_WIDTH-1:0] sum;
  assign accumulator_value_next = sum;

  logic signed [ACCUMULATOR_WIDTH-1:0] adder_b;
  assign adder_b = accumulate_internal ? accumulator_value : partial_sum_in;

  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add0
    (.a(product0),
     .b(product1),
     .out(tempSum0));

      adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add1
    (.a(product2),
     .b(adder_b),
     .out(tempSum1));

    adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add2
    (.a(tempSum0),
     .b(tempSum1),
     .out(sum));

  assign out = accumulator_value >>> OUTPUT_SCALE;

endmodule
