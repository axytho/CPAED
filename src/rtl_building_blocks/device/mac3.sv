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
  input logic out_written_to_mem,
  input logic accumulate_internal, //accumulate (accumulator <= a*b + accumulator) if high (1) or restart accumulation (accumulator <= a*b+0) if low (0)
  input logic [ACCUMULATOR_WIDTH-1:0] partial_sum_in,
  input logic [31:0] ch_out_in,    
  input logic signed [A_WIDTH-1:0] a0,
  input logic signed [B_WIDTH-1:0] b0,
  input logic signed [A_WIDTH-1:0] a1,
  input logic signed [B_WIDTH-1:0] b1,
  input logic signed [A_WIDTH-1:0] a2,
  input logic signed [B_WIDTH-1:0] b2,

  //output
  output logic signed [OUTPUT_WIDTH-1:0] out
  output logic [31:0] ch_out
  output logic  out_written_to_mem_out
  
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
	 
   REG(ACCUMULATOR_WIDTH, product0_pl_stage1);
   assign product0_pl_stage1_we = input_valid;
   assign product0_pl_stage1_next = product0;
   REG(ACCUMULATOR_WIDTH, product1_pl_stage1);
   assign product1_pl_stage1_we = input_valid;
   assign product1_pl_stage1_next = product1;
   REG(ACCUMULATOR_WIDTH, product2_pl_stage1);
   assign product2_pl_stage1_we = input_valid;
   assign product2_pl_stage1_next = product2;
   REG(ACCUMULATOR_WIDTH, partial_sum_in_pl_stage1);
   assign partial_sum_in_pl_stage1_we = input_valid;
   assign partial_sum_in_pl_stage1_next = partial_sum_in;
   REG(32, ch_out_pl_stage1);
   assign ch_out_pl_stage1_we = input_valid;
   assign ch_out_pl_stage1_next = ch_out_in;
   REG(1, accumulate_internal_pl_stage1);
   assign accumulate_internal_pl_stage1_we = input_valid;
   assign accumulate_internal_pl_stage1_next = accumulate_internal;
   REG(1, out_written_to_mem_pl_stage1);
   assign out_written_to_mem_pl_stage1_we = input_valid;
   assign out_written_to_mem_pl_stage1_next = out_written_to_mem;
   

   
  //makes register with we accumulator_value_we, qout accumulator_value, din accumulator_value_next, clk clk and arst_n_in arst_n_in
  //see register.sv 
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum0;
  logic signed [ACCUMULATOR_WIDTH-1:0] tempSum1;
  logic signed [ACCUMULATOR_WIDTH-1:0] sum;

  

  adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add0
    (.a(product0_pl_stage1),
     .b(product1_pl_stage1),
     .out(tempSum0));
	 
   REG(ACCUMULATOR_WIDTH, tempSum0_pl_stage2);
   assign tempSum0_pl_stage2_we = input_valid;
   assign tempSum0_pl_stage2_next = tempSum0;
   REG(ACCUMULATOR_WIDTH, product2_pl_stage2);
   assign product2_pl_stage2_we = input_valid;
   assign product2_pl_stage2_next = product2_pl_stage1;
   REG(ACCUMULATOR_WIDTH, partial_sum_in_pl_stage2);
   assign partial_sum_in_pl_stage2_we = input_valid;
   assign partial_sum_in_pl_stage2_next = partial_sum_in_pl_stage1;
   REG(32, ch_out_pl_stage2);
   assign ch_out_pl_stage2_we = input_valid;
   assign ch_out_pl_stage2_next = ch_out_pl_stage1;
   REG(1, accumulate_internal_pl_stage2);
   assign accumulate_internal_pl_stage2_we = input_valid;
   assign accumulate_internal_pl_stage2_next = accumulate_internal_pl_stage1;
   REG(1, out_written_to_mem_pl_stage2);
   assign out_written_to_mem_pl_stage2_we = input_valid;
   assign out_written_to_mem_pl_stage2_next = out_written_to_mem_pl_stage1;	

      adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add1
    (.a(product2),
     .b(tempSum0_pl_stage2),
     .out(tempSum1));
	 
	 
   REG(ACCUMULATOR_WIDTH, tempSum1_pl_stage3);
   assign tempSum1_pl_stage3_we = input_valid;
   assign tempSum1_pl_stage3_next = tempSum1;
   REG(ACCUMULATOR_WIDTH, partial_sum_in_pl_stage3);
   assign partial_sum_in_pl_stage3_we = input_valid;
   assign partial_sum_in_pl_stage3_next = partial_sum_in_pl_stage2;
   REG(32, ch_out_pl_stage3);
   assign ch_out_pl_stage3_we = input_valid;
   assign ch_out_pl_stage3_next = ch_out_pl_stage2;
   REG(1, accumulate_internal_pl_stage3);
   assign accumulate_internal_pl_stage3_we = input_valid;
   assign accumulate_internal_pl_stage3_next = accumulate_internal_pl_stage2;
   REG(1, out_written_to_mem_pl_stage3);
   assign out_written_to_mem_pl_stage3_we = input_valid;
   assign out_written_to_mem_pl_stage3_next = out_written_to_mem_pl_stage2;		 
   
   logic signed [ACCUMULATOR_WIDTH-1:0] adder_b;
   assign adder_b = accumulate_internal_pl_stage3 ? accumulator_value_pl_stage4 : partial_sum_in_pl_stage3;
	 

    adder #( .A_WIDTH(ACCUMULATOR_WIDTH),
           .B_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_WIDTH(ACCUMULATOR_WIDTH),
           .OUT_SCALE(0))
    add2
    (.a(adder_b),
     .b(tempSum1_pl_stage3),
     .out(sum));

   REG(ACCUMULATOR_WIDTH, accumulator_value_pl_stage4);
   assign accumulator_pl_stage4_we = input_valid;
   assign accumulator_pl_stage4_next = sum;
   REG(32, ch_out_pl_stage4);
   assign ch_out_pl_stage4_we = input_valid;
   assign ch_out_pl_stage4_next = ch_out_pl_stage3;
   REG(1, out_written_to_mem_pl_stage4);
   assign out_written_to_mem_pl_stage4_we = input_valid;
   assign out_written_to_mem_pl_stage4_next = out_written_to_mem_pl_stage4;	

  assign out = accumulator_value_pl_stage4 >>> OUTPUT_SCALE;
  assign ch_out = ch_out_pl_stage4;
  assign out_written_to_mem_out = out_written_to_mem_pl_stage4;

endmodule
