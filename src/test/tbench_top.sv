
module tbench_top;
  localparam int DATA_WIDTH         = 16;
  localparam int ACCUMULATION_WIDTH = 32;
  localparam int EXT_MEM_HEIGHT     = 1<<20;
  localparam int EXT_MEM_WIDTH      = ACCUMULATION_WIDTH;
  localparam int FEATURE_MAP_WIDTH  = 64;
  localparam int FEATURE_MAP_HEIGHT = 64;
  localparam int INPUT_NB_CHANNELS  = 4;
  localparam int OUTPUT_NB_CHANNELS = 32;
  localparam int KERNEL_SIZE        = 3;

  // initialize config_t structure, which is used to parameterize all other classes of the testbench
  localparam config_t cfg= '{
    DATA_WIDTH        ,
    ACCUMULATION_WIDTH,
    EXT_MEM_HEIGHT    ,
    EXT_MEM_WIDTH     ,
    FEATURE_MAP_WIDTH ,
    FEATURE_MAP_HEIGHT,
    INPUT_NB_CHANNELS ,
    OUTPUT_NB_CHANNELS,
    KERNEL_SIZE       
  };

  //clock
  bit clk;
  always #5 clk = !clk;

  //interface
  intf #(cfg) intf_i (clk);

  testprogram #(cfg) t1(intf_i.tb);

  //DUT
  top_system #(
  .IO_DATA_WIDTH     (DATA_WIDTH),
  .ACCUMULATION_WIDTH(ACCUMULATION_WIDTH),
  .EXT_MEM_HEIGHT    (EXT_MEM_HEIGHT),
  .EXT_MEM_WIDTH     (EXT_MEM_WIDTH),
  .FEATURE_MAP_WIDTH (FEATURE_MAP_WIDTH),
  .FEATURE_MAP_HEIGHT(FEATURE_MAP_HEIGHT),
  .INPUT_NB_CHANNELS (INPUT_NB_CHANNELS),
  .OUTPUT_NB_CHANNELS(OUTPUT_NB_CHANNELS),
  .KERNEL_SIZE       (KERNEL_SIZE)
  ) dut (
   .clk         (intf_i.clk),
   .arst_n_in   (intf_i.arst_n),

   .input0     (intf_i.input0),
   .input1     (intf_i.input1),
   .input2     (intf_i.input2),
   .input1     (intf_i.input3),
   .input2     (intf_i.input4),
   .valid     (intf_i.valid),
   .valid     (intf_i.valid),

   .out         (intf_i.output_data),
   .output_valid(intf_i.output_valid),
   .output_x    (intf_i.output_x),
   .output_y    (intf_i.output_y),
   .output_ch   (intf_i.output_ch),

   .start       (intf_i.start),
   .running     (intf_i.running)
  );

  // report latency
  longint latency= 0;
  always_ff @(posedge clk) begin
    latency++;
  end
  final begin
    $display("Total clock cycles elapsed: %0d cycles", latency);
  end


endmodule
