module top_chip #(
    parameter int IO_DATA_WIDTH = 16,
    parameter int ACCUMULATION_WIDTH = 32,
    parameter int EXT_MEM_HEIGHT = 1<<20,
    parameter int EXT_MEM_WIDTH = ACCUMULATION_WIDTH,
    parameter int FEATURE_MAP_WIDTH = 1024,
    parameter int FEATURE_MAP_HEIGHT = 1024,
    parameter int INPUT_NB_CHANNELS = 64,
    parameter int OUTPUT_NB_CHANNELS = 64,
    parameter int KERNEL_SIZE = 3
  )
  (input logic clk,
   input logic arst_n_in,  //asynchronous reset, active low

   //external_memory
   //read port
   output logic unsigned[$clog2(EXT_MEM_HEIGHT)-1:0] ext_mem_read_addr,
   input logic[EXT_MEM_WIDTH-1:0] ext_mem_qout,

   //write port
   output logic unsigned[$clog2(EXT_MEM_HEIGHT)-1:0] ext_mem_write_addr,
   output logic [EXT_MEM_WIDTH-1:0] ext_mem_din,
   output logic ext_mem_write_en,

   //system inputs and outputs
   input logic [IO_DATA_WIDTH-1:0] input0,
   input logic [IO_DATA_WIDTH-1:0] input1,
   input logic [IO_DATA_WIDTH-1:0] input2,
   input logic  valid,
   output logic ready,
   input logic [IO_DATA_WIDTH-1:0] input3,
   input logic [IO_DATA_WIDTH-1:0] input4,

   //output
   output logic signed [IO_DATA_WIDTH-1:0] out,
   output logic output_valid,
   output logic [$clog2(FEATURE_MAP_WIDTH)-1:0] output_x,
   output logic [$clog2(FEATURE_MAP_HEIGHT)-1:0] output_y,
   output logic [$clog2(OUTPUT_NB_CHANNELS)-1:0] output_ch,


   input logic start,
   output logic running
  );


  logic write_af;
  logic write_bf;
  logic write_as;
  logic write_bs;
  
  `REG(IO_DATA_WIDTH, a0);
  `REG(IO_DATA_WIDTH, a1);
  `REG(IO_DATA_WIDTH, a2);
  `REG(IO_DATA_WIDTH, a3);
  `REG(IO_DATA_WIDTH, a4);
  `REG(IO_DATA_WIDTH, a5);  
  `REG(IO_DATA_WIDTH, a6);
  `REG(IO_DATA_WIDTH, a7);
  `REG(IO_DATA_WIDTH, a8);  
  `REG(IO_DATA_WIDTH, b0);
  `REG(IO_DATA_WIDTH, b1);
  `REG(IO_DATA_WIDTH, b2);
  `REG(IO_DATA_WIDTH, b3);
  `REG(IO_DATA_WIDTH, b4);
  `REG(IO_DATA_WIDTH, b5);  
  `REG(IO_DATA_WIDTH, b6);
  `REG(IO_DATA_WIDTH, b7);
  `REG(IO_DATA_WIDTH, b8); 
  assign a0_next = input0;
  assign a1_next = input1;
  assign a2_next = input2;
  assign a3_next = input3;
  assign a4_next = input4;
  assign a5_next = input0;
  assign a6_next = input1;
  assign a7_next = input2;
  assign a8_next = input3;
  assign b0_next = input0;
  assign b1_next = input1;
  assign b2_next = input2;
  assign b3_next = input3;
  assign b4_next = input4;
  assign b5_next = input0;
  assign b6_next = input1;
  assign b7_next = input2;
  assign b8_next = input3;
  assign a0_we = write_af;
  assign b0_we = write_bf;
  assign a1_we = write_af;
  assign b1_we = write_bf;
  assign a2_we = write_af;
  assign b2_we = write_bf;
  assign a3_we = write_af;
  assign b3_we = write_bf;
  assign a4_we = write_af;
  assign b4_we = write_bf;
  assign a5_we = write_as;
  assign b5_we = write_bs;
  assign a6_we = write_as;
  assign b6_we = write_bs;
  assign a7_we = write_as;
  assign b7_we = write_bs;
  assign a8_we = write_as;
  assign b8_we = write_bs;
  
  logic mac_valid;
  logic mac_accumulate_with_0;


  controller_fsm #(
  .LOG2_OF_MEM_HEIGHT($clog2(EXT_MEM_HEIGHT)),
  .FEATURE_MAP_WIDTH(FEATURE_MAP_WIDTH),
  .FEATURE_MAP_HEIGHT(FEATURE_MAP_HEIGHT),
  .INPUT_NB_CHANNELS(INPUT_NB_CHANNELS),
  .OUTPUT_NB_CHANNELS(OUTPUT_NB_CHANNELS),
  .KERNEL_SIZE(KERNEL_SIZE)
  )
  controller
  (.clk(clk),
  .arst_n_in(arst_n_in),
  .start(start),
  .running(running),

  .mem_we(ext_mem_write_en),
  .mem_write_addr(ext_mem_write_addr),
  .mem_re(ext_mem_read_en),
  .mem_read_addr(ext_mem_read_addr),

  .valid (valid),
  .ready (ready),
  .write_af (write_af),
  .write_bf (write_bf),
  .write_as (write_as),
  .write_bs (write_bs),
  .mac_valid,
  .mac_accumulate_with_0,

  .output_valid(output_valid),
  .output_x(output_x),
  .output_y(output_y),
  .output_ch(output_ch)

  );



  logic signed [ACCUMULATION_WIDTH-1:0] mac_partial_sum;
  assign mac_partial_sum = mac_accumulate_with_0 ? 0 : ext_mem_qout;

  logic signed [ACCUMULATION_WIDTH-1:0] mac_out;
  assign ext_mem_dout = mac_out;

  mac3 #(
    .A_WIDTH(IO_DATA_WIDTH),
    .B_WIDTH(IO_DATA_WIDTH),
    .ACCUMULATOR_WIDTH(ACCUMULATION_WIDTH),
    .OUTPUT_WIDTH(ACCUMULATION_WIDTH),
    .OUTPUT_SCALE(0)
  )
  mac_unit
  (.clk(clk),
   .arst_n_in(arst_n_in),

   .input_valid(mac_valid),
   .partial_sum_in(mac_partial_sum),
   .a0(a0),
   .b0(b0),
   .a1(a1),
   .b1(b1),
   .a2(a2),
   .b2(b2),
  
   .a3(a3),
   .b3(b3),
   .a4(a4),
   .b4(b4),
   .a5(a5),
   .b5(b5),
  
   .a6(a6),
   .b6(b6),
   .a7(a7),
   .b7(b7),
   .a8(a8),
   .b8(b8),
   .out(mac_out));

  assign out = mac_out;
  assign ext_mem_din = mac_out;
  
  
  
   covergroup cg3@(posedge clk);
       c: cross out, ext_mem_write_en; 	   
   endgroup 
   
   cg3 inst = new;

endmodule
