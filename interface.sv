interface fifo_if(input logic clk, reset_n);
    // Write Interface
    logic wr_en;
    logic [7:0] data_in;
    logic full;
    logic almost_full;
    
    // Read Interface  
    logic rd_en;
    logic [7:0] data_out;
    logic empty;
    logic almost_empty;
    
    // FIFO Parameters
    parameter DEPTH = 16;
    parameter DATA_WIDTH = 8;
    
    // Clocking blocks
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output wr_en, data_in, rd_en;
        input full, almost_full, empty, almost_empty, data_out;
    endclocking
    
    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input wr_en, data_in, rd_en, full, almost_full, empty, almost_empty, data_out;
    endclocking
    
    // Modports
    modport DRIVER  (clocking driver_cb);
    modport MONITOR (clocking monitor_cb);
endinterface
