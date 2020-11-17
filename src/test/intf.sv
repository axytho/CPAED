interface intf #(
    config_t cfg
  )
  (
    input logic clk
  );
  logic arst_n;

  // input interface
  logic [cfg.DATA_WIDTH - 1 : 0] input0;
  logic [cfg.DATA_WIDTH - 1 : 0] input1;
  logic [cfg.DATA_WIDTH - 1 : 0] input2;

  logic [cfg.DATA_WIDTH - 1 : 0] input3;
  logic [cfg.DATA_WIDTH - 1 : 0] input4;
  logic valid;
  logic ready;

  // output interface
  logic signed [cfg.DATA_WIDTH-1:0] output_data;
  logic output_valid;
  logic [$clog2(cfg.FEATURE_MAP_WIDTH)-1:0] output_x;
  logic [$clog2(cfg.FEATURE_MAP_HEIGHT)-1:0] output_y;
  logic [$clog2(cfg.OUTPUT_NB_CHANNELS)-1:0] output_ch;

  logic start;
  logic running;

  default clocking cb @(posedge clk);
    default input #1ns output #2ns;
    output arst_n;
    output input0;
    output input1;
    output nput2;
    output valid;
    input  ready;

    output input3;
    output input4;

    input output_data;
    input output_valid;
    input output_x;
    input output_y;
    input output_ch;


    output start;
    input  running;
  endclocking

  modport tb (clocking cb); // testbench's view of the interface

endinterface
