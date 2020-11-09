module multiplier #(
  parameter int A_WIDTH = 16,
  parameter int B_WIDTH = 16,
  parameter int OUT_WIDTH = A_WIDTH + B_WIDTH,
  parameter int OUT_SCALE = 16
  )
  (
  input logic signed [A_WIDTH-1:0] a,
  input logic signed [B_WIDTH-1:0] b,
  output logic signed [OUT_WIDTH-1:0] out);

  localparam INTERMEDIATE_WIDTH = A_WIDTH + B_WIDTH;

  logic signed [INTERMEDIATE_WIDTH-1:0] a_extended;
  assign a_extended = a;
  logic signed [INTERMEDIATE_WIDTH-1:0] b_extended;
  assign b_extended = b;
  logic signed [INTERMEDIATE_WIDTH-1:0] unscaled_out;
  assign unscaled_out = a*b;

  assign out = unscaled_out >>> OUT_SCALE;

  // log area in area_report.txt
  final begin : area
    int fd;
    fd= $fopen("area_report.txt", "a");
    if (!fd)
      $display("PROBLEM: Could not open \"area_report.txt\"");
    else begin
      $fdisplay(fd, "%m: %d", 5800);
      $fclose(fd);
    end
  end

endmodule
