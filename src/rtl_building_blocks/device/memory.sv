//a simple pseudo-2 port memory (can read and write simultaneously)
//Feel free to write a single port memory (inout data, either write or read every cycle) to decrease your bandwidth
module memory #(
  parameter int WIDTH = 16,
  parameter int HEIGHT = 1,
  parameter bit USED_AS_EXTERNAL_MEM = 0 // for area estimation
  )
  (
  input logic clk,

  //read port (0 cycle: there is no clock edge between changing the read_addr and the output)
  input logic unsigned[$clog2(HEIGHT)-1:0] read_addr,
  output logic[WIDTH-1:0] qout,

  //write port (data is written on the rising clock edge)
  input logic unsigned[$clog2(HEIGHT)-1:0] write_addr,
  input logic [WIDTH-1:0] din,
  input logic write_en
  );


  //storage
  logic [WIDTH-1:0] data [0:HEIGHT-1];

  always @ (posedge clk) begin
    if (write_en) begin
        data[write_addr] <= din;
    end
  end

  assign qout = data[read_addr];


  // log area in area_report.txt
  final begin : area
    int fd;
    fd= $fopen("area_report.txt", "a");
    if (!fd)
      $display("PROBLEM: Could not open \"area_report.txt\"");
    else begin
      if (!USED_AS_EXTERNAL_MEM) begin
        if (HEIGHT < 256) begin
          $fdisplay(fd, "%m: %d", 17*WIDTH*HEIGHT);
        end else begin
          $fdisplay(fd, "%m: %d", 1*WIDTH*HEIGHT);
        end
      end
      $fclose(fd);
    end
  end

endmodule
