module mac3 #(
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
  input logic [ACCUMULATOR_WIDTH-1:0] partial_sum_in,   
  input logic signed [A_WIDTH-1:0] a0,
  input logic signed [B_WIDTH-1:0] b0,
  input logic signed [A_WIDTH-1:0] a1,
  input logic signed [B_WIDTH-1:0] b1,
  input logic signed [A_WIDTH-1:0] a2,
  input logic signed [B_WIDTH-1:0] b2,
  
  input logic signed [A_WIDTH-1:0] a3,
  input logic signed [B_WIDTH-1:0] b3,
  input logic signed [A_WIDTH-1:0] a4,
  input logic signed [B_WIDTH-1:0] b4,
  input logic signed [A_WIDTH-1:0] a5,
  input logic signed [B_WIDTH-1:0] b5,
  
  input logic signed [A_WIDTH-1:0] a6,
  input logic signed [B_WIDTH-1:0] b6,
  input logic signed [A_WIDTH-1:0] a7,
  input logic signed [B_WIDTH-1:0] b7,
  input logic signed [A_WIDTH-1:0] a8,
  input logic signed [B_WIDTH-1:0] b8,
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
 `REG(ACCUMULATOR_WIDTH, product0_1);
  assign product0_1_we   = input_valid; 
  assign product0_1_next = product0;   

  logic signed [ACCUMULATOR_WIDTH-1:0] product1;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul1
    (.a(a1),
     .b(b1),
     .out(product1));
 `REG(ACCUMULATOR_WIDTH, product1_1);
  assign product1_1_we   = input_valid; 
  assign product1_1_next = product1;

  logic signed [ACCUMULATOR_WIDTH-1:0] product2;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul2
    (.a(a2),
     .b(b2),
     .out(product2));
 `REG(ACCUMULATOR_WIDTH, product2_1);
  assign product2_1_we   = input_valid; 
  assign product2_1_next = product2;

  logic signed [ACCUMULATOR_WIDTH-1:0] product3;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul3
    (.a(a3),
     .b(b3),
     .out(product3));
 `REG(ACCUMULATOR_WIDTH, product3_1);
  assign product3_1_we   = input_valid; 
  assign product3_1_next = product3;
  logic signed [ACCUMULATOR_WIDTH-1:0] product4;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul4
    (.a(a4),
     .b(b4),
     .out(product4));
 `REG(ACCUMULATOR_WIDTH, product4_1);
  assign product4_1_we   = input_valid; 
  assign product4_1_next = product4;
 `REG(ACCUMULATOR_WIDTH, partial_sum_in_1);
  assign partial_sum_in_1_we   = input_valid; 
  assign partial_sum_in_1_next = partial_sum_in;
//END OF STAGE 1

  logic signed [ACCUMULATOR_WIDTH-1:0] product5;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul5
    (.a(a5),
     .b(b5),
     .out(product5));
 `REG(ACCUMULATOR_WIDTH, product5_2);
  assign product5_2_we   = 1; 
  assign product5_2_next = product5;   

  logic signed [ACCUMULATOR_WIDTH-1:0] product6;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul6
    (.a(a6),
     .b(b6),
     .out(product6));
 `REG(ACCUMULATOR_WIDTH, product6_2);
  assign product6_2_we   = 1; 
  assign product6_2_next = product6;

  logic signed [ACCUMULATOR_WIDTH-1:0] product7;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul7
    (.a(a7),
     .b(b7),
     .out(product7));
 `REG(ACCUMULATOR_WIDTH, product7_2);
  assign product7_2_we   = 1; 
  assign product7_2_next = product7;

  logic signed [ACCUMULATOR_WIDTH-1:0] product8;
  multiplier #( .A_WIDTH(A_WIDTH),
                .B_WIDTH(B_WIDTH),
                .OUT_WIDTH(ACCUMULATOR_WIDTH),
                .OUT_SCALE(0))
    mul8
    (.a(a8),
     .b(b8),
     .out(product8));
 `REG(ACCUMULATOR_WIDTH, product8_2);
  assign product8_2_we   = 1; 
  assign product8_2_next = product8;
  
  
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum0;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add0
    (.a(product0_1),
     .b(product1_1),
     .out(tempSum0));
  `REG(ACCUMULATOR_WIDTH, tempSum0_2);
   assign tempSum0_2_we   = 1; 
   assign tempSum0_2_next = tempSum0;
   
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum1;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add1
    (.a(product2_1),
     .b(product3_1),
     .out(tempSum1));
  `REG(ACCUMULATOR_WIDTH, tempSum1_2);
   assign tempSum1_2_we   = 1; 
   assign tempSum1_2_next = tempSum1;
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum2;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add2
    (.a(product4_1),
     .b(partial_sum_in_1),
     .out(tempSum2));
  `REG(ACCUMULATOR_WIDTH, tempSum2_2);
   assign tempSum2_2_we   = 1; 
   assign tempSum2_2_next = tempSum2;
// END OF THE SECOND STAGE



  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum3;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add3
    (.a(tempSum0_2),
     .b(tempSum1_2),
     .out(tempSum3));
  `REG(ACCUMULATOR_WIDTH, tempSum3_3);
   assign tempSum3_3_we   = 1; 
   assign tempSum3_3_next = tempSum3;
   
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum4;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add4
    (.a(tempSum2_2),
     .b(product5_2),
     .out(tempSum4));
  `REG(ACCUMULATOR_WIDTH, tempSum4_3);
   assign tempSum4_3_we   = 1; 
   assign tempSum4_3_next = tempSum4;
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum5;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add5
    (.a(product6_2),
     .b(product7_2),
     .out(tempSum5));
  `REG(ACCUMULATOR_WIDTH, tempSum5_3);
   assign tempSum5_3_we   = 1; 
   assign tempSum5_3_next = tempSum5;
   
  `REG(ACCUMULATOR_WIDTH, product8_3);
   assign product8_3_we   = 1; 
   assign product8_3_next = product8_2;
// END OF STAGE 3

  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum6;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add6
    (.a(tempSum3_3),
     .b(tempSum4_3),
     .out(tempSum6));
  `REG(ACCUMULATOR_WIDTH, tempSum6_4);
   assign tempSum6_4_we   = 1; 
   assign tempSum6_4_next = tempSum6;
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum7;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add7
    (.a(tempSum5_3),
     .b(product8_3),
     .out(tempSum7));
  `REG(ACCUMULATOR_WIDTH, tempSum7_4);
   assign tempSum7_4_we   = 1; 
   assign tempSum7_4_next = tempSum7;
// END OF STAGE 4
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum8;
  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add8
    (.a(tempSum6_4),
     .b(tempSum7_4),
     .out(tempSum8));
  `REG(ACCUMULATOR_WIDTH, tempSum8_5);
   assign tempSum8_5_we   = 1; 
   assign tempSum8_5_next = tempSum8;
// END OF STAGE 5
   assign out = tempSum8_5 >>> OUTPUT_SCALE;   
   covergroup cg1@(posedge clk);
       c1: coverpoint out;
       c2: cross a1,b1; 	   
   endgroup 
   
   cg1 cg_inst = new;
endmodule



