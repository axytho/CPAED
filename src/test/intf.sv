interface intf #(
    config_t cfg
  )
  (
    input logic clk
  );
  logic arst_n;

  // input interface
  logic [cfg.DATA_WIDTH - 1 : 0] a_input;
  logic a_valid;
  logic a_ready;

  logic [cfg.DATA_WIDTH - 1 : 0] b_input;
  logic b_valid;
  logic b_ready;

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
    output a_input;
    output a_valid;
    input  a_ready;

    output b_input;
    output b_valid;
    input  b_ready;

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
