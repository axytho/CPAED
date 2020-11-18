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
  input  logic valid,
  output logic ready,
  output logic write_af,
  output logic write_bf,
  output logic write_as,
  output logic write_bs,
  output logic mac_valid,
  output logic mac_accumulate_with_0,

  output logic output_valid,
  output logic [32-1:0] output_x,
  output logic [32-1:0] output_y,
  output logic [32-1:0] output_ch

  );

   typedef enum {IDLE, PRE_FETCH_W1, PRE_FETCH_W2,MAC1,MAC2, MACW1, MACW2, LO1, LO2, LO3,LO4, DONE} fsm_state;
   fsm_state current_state;
   fsm_state next_state;
   fsm_state extra_state;
   logic reset_fw, reset_ch_in, reset_ch_out, reset_x, reset_y;
   logic last_x, last_y, last_ch_in, last_ch_out,last_overall;
   logic  fetchw_next;
   
   

  
  //loop counters (see register.sv for macro)
  `REG(1, k);
  `REG(32, x);
  `REG(32, y);
  `REG(32, ch_in);
  `REG(32, ch_out);
  

  
  assign last_ch_out  = ch_out ==   OUTPUT_NB_CHANNELS -1;
  assign last_x       = x      ==   FEATURE_MAP_WIDTH  -1;
  assign last_y       = y      ==   FEATURE_MAP_HEIGHT -1;
  assign last_ch_in   = ch_in  ==   INPUT_NB_CHANNELS  -1;
  assign last_overall =  last_ch_in && last_ch_out && last_x && last_y && k; 
  
  
  assign k_next      = ~k; 
  assign ch_out_next = (last_ch_out) ? 0: ch_out +1;
  assign y_next      = (last_y) ?      0: y +1 ;
  assign x_next      = (last_x) ?      0: x + 1;
  assign ch_in_next  = (last_ch_in) ?  0: ch_in + 1;
  
  
  
  assign k_we      = mac_valid;
  assign ch_out_we = x_we       && last_x;
  assign y_we      = k_we       && k;
  assign x_we      = y_we       && last_y;
  assign ch_in_we  = ch_out_we  && last_ch_out; 
  
  assign mac_accumulate_with_0 = ch_in == 0;
  
  
  assign fetchw_next =  last_x && last_y && k;
  
  assign mem_read_addr[16:0] = {x[5:0], y[5:0],ch_out[4:0]};
  assign mem_re              = k && mac_valid; 
  
  
  `REG(32, x_1);
  `REG(32, y_1);
  `REG(32, ch_out_1);
   assign x_1_we      = 1;
   assign y_1_we      = 1;
   assign ch_out_1_we = 1;
   assign x_1_next    = x;
   assign y_1_next    = y;
   assign ch_out_1_next = ch_out;
  `REG(32, x_2); 
  `REG(32, y_2);
  `REG(32, ch_out_2);
   assign x_2_we      = 1;
   assign y_2_we      = 1;
   assign ch_out_2_we = 1;
   assign x_2_next    = x_1;
   assign y_2_next    = y_1;
   assign ch_out_2_next = ch_out_1;   
  `REG(32, x_3);
  `REG(32, y_3);
  `REG(32, ch_out_3);
   assign x_3_we      = 1;
   assign y_3_we      = 1;
   assign ch_out_3_we = 1;
   assign x_3_next    = x_2;
   assign y_3_next    = y_2;
   assign ch_out_3_next = ch_out_2; 
  `REG(32, x_4);
  `REG(32, y_4);
  `REG(32, ch_out_4);
   assign x_4_we      = 1;
   assign y_4_we      = 1;
   assign ch_out_4_we = 1;
   assign x_4_next    = x_3;
   assign y_4_next    = y_3;
   assign ch_out_4_next = ch_out_3;   
  `REG(32, x_5);
  `REG(32, y_5);
  `REG(32, ch_out_5);
   assign x_5_we      = 1;
   assign y_5_we      = 1;
   assign ch_out_5_we = 1;
   assign x_5_next    = x_4;
   assign y_5_next    = y_4;
   assign ch_out_5_next = ch_out_4; 
   assign output_ch = ch_out_5; 
   assign output_x  = x_5;
   assign output_y  = y_5; 
   assign mem_write_addr[31:17] = 15'b0;
   assign mem_read_addr[31:17] = 15'b0;
   assign mem_write_addr[16:0] = {x_5[5:0], y_5[5:0],ch_out_5[4:0]};;   
  `REG(1, output_valid_1);
  `REG(1, output_valid_2);
  `REG(1, output_valid_3);
  `REG(1, output_valid_4);
  `REG(1, output_valid_5);
  assign output_valid_1_next = k && mac_valid && last_ch_in;
  assign output_valid_1_we   = 1; 
  assign output_valid_2_next = output_valid_1;
  assign output_valid_2_we   = 1; 
  assign output_valid_3_next = output_valid_2;
  assign output_valid_3_we   = 1;   
  assign output_valid_4_next = output_valid_3;
  assign output_valid_4_we   = 1; 
  assign output_valid_5_next = output_valid_4;
  assign output_valid_5_we   = 1; 
  assign output_valid = output_valid_5; 
  
  
  
  `REG(1, mem_we_1);
  `REG(1, mem_we_2);
  `REG(1, mem_we_3);
  `REG(1, mem_we_4);
  `REG(1, mem_we_5);
  assign mem_we_1_next = k && mac_valid && !last_ch_in;
  assign mem_we_1_we   = mac_valid; 
  assign mem_we_2_next = mem_we_1;
  assign mem_we_2_we   = 1;   
  assign mem_we_3_next = mem_we_2;
  assign mem_we_3_we   = 1; 
  assign mem_we_4_next = mem_we_3;
  assign mem_we_4_we   = 1; 
  assign mem_we_5_next = mem_we_4;
  assign mem_we_5_we   = 1;
  assign mem_we        = mem_we_5;  
  /*
  chosen loop order:
  for ch_in
    for x
      for y
        for ch_out     (with this order, accumulations need to be kept because ch_out is inside ch_in)
          for k
              body
  */
  // ==>
  //assign k_h_we    = mac_valid; //each time a mac is done, k_h_we increments (or resets to 0 if last)
 

	  always @ (posedge clk or negedge arst_n_in) begin
		if(arst_n_in==0) begin
		  current_state <= IDLE;
		end else begin
		  current_state <= next_state;
		end
	  end 
      always_comb begin
	      next_state = current_state;
		  running   = 1;
          ready     = 1;
		  mac_valid = 0;
		  write_af  = 0;
	      write_bf  = 0;
	      write_as  = 0;
	      write_bs  = 0;
          case (current_state)
              IDLE: begin
                  running    = 0;
				  ready      = 0;
                  next_state = (start) ? PRE_FETCH_W1 : IDLE;			  
			  end
			  PRE_FETCH_W1: begin
			      write_bf   = 1;
			      next_state = (valid) ? PRE_FETCH_W2 : PRE_FETCH_W1;
			  end
			  PRE_FETCH_W2: begin
			      write_bs   = 1;
			      next_state = (valid) ? MAC1 : PRE_FETCH_W2;
			  end			  
			  MAC1: begin
			      mac_valid  = valid;
			      write_af   = 1;
			      next_state = (valid) ? MAC2: MAC1;
			  end
			  MAC2: begin
			      mac_valid  = valid;
			      write_as   = 1;
			      extra_state = (last_overall)? LO1 : ((fetchw_next) ? MACW1: MAC1);
				  next_state  = (valid) ? extra_state:MAC2; 
			  end
			  MACW1: begin
			      write_bf    = 1;
				  next_state  = (valid) ? MACW2:MACW1; 
			  end
			  MACW2: begin
			      write_bs    = 1;
				  next_state  = (valid) ? MAC1:MACW2; 
			  end
			  LO1: begin
				  next_state  = LO2; 
			  end
			  LO2: begin
				  next_state  = LO3; 
			  end	
			  LO3: begin
				  next_state  = LO4; 
			  end
			  LO4: begin
				  next_state  = DONE; 
			  end
			  DONE: begin
				  next_state  = IDLE; 
			  end				  
		  endcase
      end 	  

endmodule
