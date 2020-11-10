
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
    intf_i.cb.a_valid <= 0;
    intf_i.cb.b_valid <= 0;
    intf_i.cb.arst_n  <= 0;
    repeat (2) @(intf_i.cb);
    intf_i.cb.arst_n  <= 1; //synchronous release of reset
    repeat (2) @(intf_i.cb);
    $display("[DRV] -----  Reset Ended  -----");
  endtask

  task run();
    // Get a transaction with kernel from the Generator
    // Kernel remains same throughput the verification
    Transaction_Kernel #(cfg) tract_kernel;
    gen2drv_kernel.get(tract_kernel);

    $display("[DRV] -----  Start execution -----");
    intf_i.cb.start <= 1;
    @(intf_i.cb);
    intf_i.cb.start <= 0;

    forever begin

      // Get a transaction with feature from the Generator
      Transaction_Feature #(cfg) tract_feature;
      gen2drv_feature.get(tract_feature);


      $display("[DRV] ----- Driving a new input feature map -----");
      for(int x=0;x<cfg.FEATURE_MAP_WIDTH; x++) begin
        $display("[DRV] %.2f %% of the computation done", ((x)*100.0)/cfg.FEATURE_MAP_WIDTH);
        for(int y=0;y<cfg.FEATURE_MAP_HEIGHT; y++) begin
          for(int inch=0;inch<cfg.INPUT_NB_CHANNELS; inch++) begin
            for(int outch=0;outch<cfg.OUTPUT_NB_CHANNELS; outch++) begin
              for(int ky=0;ky<cfg.KERNEL_SIZE; ky++) begin
			      $display("[DRV] a new loop");
                //for(int kx=0;kx<cfg.KERNEL_SIZE; kx++) begin
                  
                  //drive a (one word from feature)
                  intf_i.cb.a_valid <= 1;
                  if( x+0-cfg.KERNEL_SIZE/2 >= 0 && x+0-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                    &&y+ky-cfg.KERNEL_SIZE/2 >= 0 && y+ky-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                    assert (!$isunknown(tract_feature.inputs[y+ky-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch]));
                    intf_i.cb.a_input0 <= tract_feature.inputs[y+ky-cfg.KERNEL_SIZE/2 ][x+0-cfg.KERNEL_SIZE/2][inch];
                  end else begin
                    intf_i.cb.a_input0 <= 0; // zero padding for boundary cases
                  end
                                    if( x+1-cfg.KERNEL_SIZE/2 >= 0 && x+1-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                    &&y+ky-cfg.KERNEL_SIZE/2 >= 0 && y+ky-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                    assert (!$isunknown(tract_feature.inputs[y+ky-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch]));
                    intf_i.cb.a_input1 <= tract_feature.inputs[y+ky-cfg.KERNEL_SIZE/2 ][x+1-cfg.KERNEL_SIZE/2][inch];
                  end else begin
                    intf_i.cb.a_input1 <= 0; // zero padding for boundary cases
                  end
                                    if( x+2-cfg.KERNEL_SIZE/2 >= 0 && x+2-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_WIDTH
                    &&y+ky-cfg.KERNEL_SIZE/2 >= 0 && y+ky-cfg.KERNEL_SIZE/2 < cfg.FEATURE_MAP_HEIGHT) begin
                    assert (!$isunknown(tract_feature.inputs[y+ky-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch]));
                    intf_i.cb.a_input2 <= tract_feature.inputs[y+ky-cfg.KERNEL_SIZE/2 ][x+2-cfg.KERNEL_SIZE/2][inch];
                  end else begin
                    intf_i.cb.a_input2 <= 0; // zero padding for boundary cases
                  end
                  @(intf_i.cb iff intf_i.cb.a_ready);
                  intf_i.cb.a_valid <= 0;

                  //drive a (one word from kernel)
                  intf_i.cb.b_valid <= 1;
                  assert (!$isunknown(tract_kernel.kernel[ky][0][inch][outch]));
                  intf_i.cb.b_input0 <= tract_kernel.kernel[ky][0][inch][outch];
                  assert (!$isunknown(tract_kernel.kernel[ky][1][inch][outch]));
                  intf_i.cb.b_input1 <= tract_kernel.kernel[ky][1][inch][outch];
                  assert (!$isunknown(tract_kernel.kernel[ky][2][inch][outch]));
                  intf_i.cb.b_input2 <= tract_kernel.kernel[ky][2][inch][outch];

                  @(intf_i.cb iff intf_i.cb.b_ready);
                  intf_i.cb.b_valid <= 0;
                //end
              end
            end
          end
        end
      end
    end
  endtask : run
endclass : Driver
