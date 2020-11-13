module controller_fsm #(
  parameter int LOG2_OF_MEM_HEIGHT = 20,
  parameter int FEATURE_MAP_WIDTH = 1024,
  parameter int FEATURE_MAP_HEIGHT = 1024,
  parameter int INPUT_NB_CHANNELS = 64,
  parameter int OUTPUT_NB_CHANNELS = 64,
  parameter int KERNEL_SIZE = 3
  )
  (input logic clk,
  input logic arst_n_in, //asynchronous reset, active low

  input logic start,
  output logic running,

  //memory control interface
  output logic mem_we,
  output logic [LOG2_OF_MEM_HEIGHT-1:0] mem_write_addr,
  output logic mem_re,
  output logic [LOG2_OF_MEM_HEIGHT-1:0] mem_read_addr,

  //datapad control interface & external handshaking communication of a and b
  input logic a_valid,
  input logic b_valid,
  output logic b_ready,
  output logic a_ready,
  output logic write_a,
  output logic write_b,
  output logic mac_valid,
  output logic mac_accumulate_internal,
  output logic mac_accumulate_with_0,

  output logic output_valid,
  output logic [32-1:0] output_x,
  output logic [32-1:0] output_y,
  output logic [32-1:0] output_ch

  );


  //loop counters (see register.sv for macro)
  `REG(32, k_v);
  `REG(32, k_h);
  `REG(32, x);
  `REG(32, y);
  `REG(32, ch_in);
  `REG(32, ch_out);

  logic reset_k_v, reset_k_h, reset_x, reset_y, reset_ch_in, reset_ch_out;
  //assign k_h_next = reset_k_h ? 0 : k_h + 1;
  assign k_v_next = reset_k_v ? 0 : k_v + 1;
  assign x_next = reset_x ? 0 : x + 1;
  assign y_next = reset_y ? 0 : y + 1;
  assign ch_in_next = reset_ch_in ? 0 : ch_in + 1;
  assign ch_out_next = reset_ch_out ? 0 : ch_out + 1;

  logic last_k_v, last_k_h, last_x, last_y, last_ch_in, last_ch_out;
  //assign last_k_h = k_h == KERNEL_SIZE - 1;
  assign last_k_h = 1;
  assign last_k_v = k_v == KERNEL_SIZE - 1;
  assign last_x = x == FEATURE_MAP_WIDTH-1;
  assign last_y = y == FEATURE_MAP_HEIGHT-1;
  assign last_ch_in = ch_in == INPUT_NB_CHANNELS - 1;
  assign last_ch_out = ch_out == OUTPUT_NB_CHANNELS - 1;

  
  assign reset_k_h = last_k_h;
  assign reset_k_v = last_k_v;
  assign reset_x = last_x;
  assign reset_y = last_y;
  assign reset_ch_in = last_ch_in;
  assign reset_ch_out = last_ch_out;


  /*
  chosen loop order:
  for x
    for y
      for ch_in
        for ch_out     (with this order, accumulations need to be kept because ch_out is inside ch_in)
          for k_v
            for k_h
              body
  */
  // ==>
  //assign k_h_we    = mac_valid; //each time a mac is done, k_h_we increments (or resets to 0 if last)
  assign k_v_we    = mac_valid && last_k_h; //only if last of k_h loop
  assign ch_out_we = mac_valid && last_k_h && last_k_v; //only if last of all enclosed loops
  assign ch_in_we  = mac_valid && last_k_h && last_k_v && last_ch_out; //only if last of all enclosed loops
  assign y_we      = mac_valid && last_k_h && last_k_v && last_ch_out && last_ch_in; //only if last of all enclosed loops
  assign x_we      = mac_valid && last_k_h && last_k_v && last_ch_out && last_ch_in && last_y; //only if last of all enclosed loops

  logic last_overall;
  assign last_overall   = last_k_h && last_k_v && last_ch_out && last_ch_in && last_y && last_x;


  //given loop order, partial sums need be saved over input channels
  assign mem_we         = k_v == 2 && k_h == 0; // Note: one cycle after last_k_v and last_k_h, because of register in mac unit
  assign mem_write_addr = ch_out;

  //and loaded back
  assign mem_re         = k_v == 0 && k_h == 0;
  assign mem_read_addr  = ch_out;

  assign mac_accumulate_internal = ! (k_v == 0 && k_h == 0);
  assign mac_accumulate_with_0   = ch_in ==0 && k_v == 0 && k_h == 0;

  //mark outputs
  `REG(1, output_valid_reg);
  assign output_valid_reg_next = mac_valid && last_ch_in && last_k_v && last_k_h;
  assign output_valid_reg_we   = 1;
  assign output_valid = output_valid_reg;

  register #(.WIDTH(32)) output_x_r (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(x),
                                                .qout(output_x),
                                                .we(mac_valid && last_ch_in && last_k_v && last_k_h));
  register #(.WIDTH(32)) output_y_r (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(y),
                                                .qout(output_y),
                                                .we(mac_valid && last_ch_in && last_k_v && last_k_h));
  register #(.WIDTH(32)) output_ch_r (.clk(clk), .arst_n_in(arst_n_in),
                                                .din(ch_out),
                                                .qout(output_ch),
                                                .we(mac_valid && last_ch_in && last_k_v && last_k_h));
  //mini fsm to loop over <fetch_a, fetch_b, acc>

  typedef enum {IDLE, FETCH_AB, MAC} fsm_state;
  fsm_state current_state;
  fsm_state next_state;
  always @ (posedge clk or negedge arst_n_in) begin
    if(arst_n_in==0) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end


  always_comb begin
    //defaults: applicable if not overwritten below
    next_state = current_state;
    write_a = 0;
    write_b = 0;
    mac_valid = 0;
    running = 1;
    a_ready = 0;
    b_ready = 0;

    case (current_state)
      IDLE: begin
        running = 0;
        next_state = (start) ? FETCH_AB : IDLE;
      end
      FETCH_AB: begin
        a_ready = 1;
        write_a = 1;
        b_ready = 1;
        write_b = 1;
        next_state =  MAC;
      end
      MAC: begin
        a_ready = 1;
        write_a = 1;
        b_ready = 1;
        write_b = 1;
        mac_valid = 1;
        next_state = last_overall ? IDLE : MAC;
      end
    endcase
  end
endmodule
