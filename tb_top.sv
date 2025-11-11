`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import the FIFO package
    import fifo_pkg::*;
    
    // Clock and reset signals
    logic clk;
    logic reset_n;
    
    // Instantiate the interface
    fifo_if fifo_vif(clk, reset_n);
    
    // Instantiate the DUT (Synchronous FIFO)
    fifo #(
        .DEPTH(16),
        .DATA_WIDTH(8)
    ) dut (
        .clk          (clk),
        .reset_n      (reset_n),
        .wr_en        (fifo_vif.wr_en),
        .data_in      (fifo_vif.data_in),
        .full         (fifo_vif.full),
        .almost_full  (fifo_vif.almost_full),
        .rd_en        (fifo_vif.rd_en),
        .data_out     (fifo_vif.data_out),
        .empty        (fifo_vif.empty),
        .almost_empty (fifo_vif.almost_empty)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end
    
    // Reset generation
    initial begin
        reset_n = 0;
        #100 reset_n = 1;
    end
    
    // UVM test setup and run
    initial begin
        // Set the virtual interface in config DB
        uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.agent*", "fifo_vif", fifo_vif);
        
        // Set verbosity
        uvm_top.set_report_verbosity_level_hier(UVM_MEDIUM);
        
        // Start the test
        run_test();
    end
    
    // Waveform dumping
    initial begin
        if ($test$plusargs("WAVE")) begin
            $dumpfile("fifo_waves.vcd");
            $dumpvars(0, tb_top);
        end
    end
    
    // Simulation timeout
    initial begin
        #500000; // 500us timeout
        `uvm_fatal("TIMEOUT", "Simulation timeout reached")
        $finish;
    end
    
endmodule
