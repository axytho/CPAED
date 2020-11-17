
class Driver #(config_t cfg);

  virtual intf #(cfg) intf_i;

  mailbox #(Transaction_Feature #(cfg)) gen2drv_feature;
  mailbox #(Transaction_Kernel #(cfg)) gen2drv_kernel;

  function new(
    virtual intf #(cfg) i,
    mailbox #(Transaction_Feature #(cfg)) g2d_feature,
    mailbox #(Transaction_Kernel #(cfg)) g2d_kernel
  );
    intf_i = i;
    gen2drv_feature = g2d_feature;
    gen2drv_kernel = g2d_kernel;
  endfunction : new

  task reset;
    $display("[DRV] ----- Reset Started -----");
     //asynchronous start of reset
    intf_i.cb.start   <= 0;
    intf_i.cb.valid <= 0;
    intf_i.cb.valid <= 0;
    intf_i.cb.arst_n  <= 0;
    repeat (2) @(intf_i.cb);
    intf_i.cb.arst_n  <= 1; //synchronous release of reset
    repeat (2) @(intf_i.cb);
    $display("[DRV] -----  Reset Ended  -----");
  endtask

  task run();
    // Get a transaction with kernel from the Generator
    // Kernel remains same throughput the verification

    forever begin
      Transaction_Feature #(cfg) tract_feature;
	  Transaction_Kernel #(cfg) tract_kernel;
      gen2drv_feature.get(tract_feature);
      gen2drv_kernel.get(tract_kernel);
	  repeat (20) @(intf_i.cb);
	  reset;
      $display("[DRV] -----  Start execution -----");
      intf_i.cb.start <= 1;
      @(intf_i.cb);
      intf_i.cb.start <= 0;
      // Get a transaction with feature from the Generator
      $display("[DRV] ----- Driving a new input feature map -----");
	  for(int inch=0;inch<cfg.INPUT_NB_CHANNELS; inch++) begin
         $display("[DRV] %.2f %% of the computation done", ((x)*100.0)/cfg.INPUT_NB_CHANNELS);
         for(int outch=0;outch<cfg.OUTPUT_NB_CHANNELS; outch++) begin
		     intf_i.cb.valid <= 1;
             assert (!$isunknown(tract_kernel.kernel[0][0][inch][outch]));
             intf_i.cb.input0 <= tract_kernel.kernel[0][0][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[0][1][inch][outch]));
             intf_i.cb.input1 <= tract_kernel.kernel[0][1][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[0][2][inch][outch]));
             intf_i.cb.input2 <= tract_kernel.kernel[0][2][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[1][0][inch][outch]));
             intf_i.cb.input3 <= tract_kernel.kernel[1][0][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[1][1][inch][outch]));
             intf_i.cb.input4 <= tract_kernel.kernel[1][1][inch][outch];	
             @(intf_i.cb);
			 intf_i.cb.valid <= 1;
             assert (!$isunknown(tract_kernel.kernel[1][2][inch][outch]));
             intf_i.cb.input0 <= tract_kernel.kernel[1][2][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[2][0][inch][outch]));
             intf_i.cb.input1 <= tract_kernel.kernel[2][0][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[2][1][inch][outch]));
             intf_i.cb.input2 <= tract_kernel.kernel[2][1][inch][outch];	
             assert (!$isunknown(tract_kernel.kernel[2][2][inch][outch]));
             intf_i.cb.input3 <= tract_kernel.kernel[2][2][inch][outch];
             @(intf_i.cb);			 
             for(int x=0;x<cfg.FEATURE_MAP_WIDTH; x++) begin
                 for(int y=0;y<cfg.FEATURE_MAP_HEIGHT; y++) begin 
                     intf_i.cb.valid <= 1;
                     if( x+0-cfg.KERNEL_SIZE/2 >= 0 && x+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                        &&y+0-cfg.KERNEL_SIZE/2 >= 0 && y+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+0-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input0 <= tract_feature.inputs[y+0-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                       intf_i.cb.input0 <= 0; // zero padding for boundary cases
                     end
                     if( x+1-cfg.KERNEL_SIZE/2 >= 0 && x+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                         &&y+0-cfg.KERNEL_SIZE/2 >= 0 && y+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+0-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input1 <= tract_feature.inputs[y+0-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                       intf_i.cb.nput1 <= 0; // zero padding for boundary cases
                     end
                     if( x+2-cfg.KERNEL_SIZE/2 >= 0 && x+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                        &&y+0-cfg.KERNEL_SIZE/2 >= 0 && y+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+0-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input2 <= tract_feature.inputs[y+0-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                        intf_i.cb.input2 <= 0; // zero padding for boundary cases
                     end
                     if( x+0-cfg.KERNEL_SIZE/2 >= 0 && x+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                        &&y+1-cfg.KERNEL_SIZE/2 >= 0 && y+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+1-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input0 <= tract_feature.inputs[y+1-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                       intf_i.cb.input0 <= 0; // zero padding for boundary cases
                     end
                     if( x+1-cfg.KERNEL_SIZE/2 >= 0 && x+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                         &&y+1-cfg.KERNEL_SIZE/2 >= 0 && y+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+1-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input1 <= tract_feature.inputs[y+1-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                       intf_i.cb.nput1 <= 0; // zero padding for boundary cases
                     end
					 @(intf_i.cb);	
                     if( x+2-cfg.KERNEL_SIZE/2 >= 0 && x+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                        &&y+1-cfg.KERNEL_SIZE/2 >= 0 && y+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+1-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input2 <= tract_feature.inputs[y+1-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                        intf_i.cb.input2 <= 0; // zero padding for boundary cases
                     end

                     intf_i.cb.valid <= 1;
                     if( x+0-cfg.KERNEL_SIZE/2 >= 0 && x+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                        &&y+2-cfg.KERNEL_SIZE/2 >= 0 && y+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+2-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input0 <= tract_feature.inputs[y+2-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                       intf_i.cb.input0 <= 0; // zero padding for boundary cases
                     end
                     if( x+1-cfg.KERNEL_SIZE/2 >= 0 && x+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                         &&y+2-cfg.KERNEL_SIZE/2 >= 0 && y+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+2-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input1 <= tract_feature.inputs[y+2-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                       intf_i.cb.nput1 <= 0; // zero padding for boundary cases
                     end
                     if( x+2-cfg.KERNEL_SIZE/2 >= 0 && x+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                        &&y+2-cfg.KERNEL_SIZE/2 >= 0 && y+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                     assert (!$isunknown(tract_feature.inputs[y+2-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch]));
                     intf_i.cb.input2 <= tract_feature.inputs[y+2-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch];
                     end else begin
                        intf_i.cb.input2 <= 0; // zero padding for boundary cases
                     end					 

                  
                  //@(intf_i.cb iff (intf_i.cb.b_ready & intf_i.cb.a_ready));
                     @(intf_i.cb);
                  //@(intf_i.cb);

                  //intf_i.cb.b_valid <= 0;
                  //intf_i.cb.a_valid <= 0;
                  
                //end
            end
          end
        end
      end
    end
  endtask : run
endclass : Driver
