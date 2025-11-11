class fifo_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) item_collected_export;
    
    // Reference model - simple queue
    logic [7:0] ref_fifo[$];
    int fifo_depth = 16;
    
    // Statistics
    int write_count = 0;
    int read_count = 0;
    int error_count = 0;
    int overflow_count = 0;
    int underflow_count = 0;
    
    `uvm_component_utils(fifo_scoreboard)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    virtual function void write(fifo_transaction trans);
        logic [7:0] expected_data;
        logic expected_full, expected_empty;
        logic expected_almost_full, expected_almost_empty;
        
        // Update reference model based on operation
        case(trans.op)
            fifo_transaction::WRITE: begin
                if(ref_fifo.size() < fifo_depth) begin
                    ref_fifo.push_back(trans.data);
                    write_count++;
                end else begin
                    overflow_count++;
                    `uvm_error("SCOREBOARD", $sformatf("OVERFLOW: Attempted write to full FIFO, data=0x%0h", trans.data))
                end
            end
            
            fifo_transaction::READ: begin
                if(ref_fifo.size() > 0) begin
                    expected_data = ref_fifo.pop_front();
                    read_count++;
                    
                    // Check read data
                    if(trans.read_data !== expected_data) begin
                        error_count++;
                        `uvm_error("SCOREBOARD", $sformatf("DATA MISMATCH: Expected=0x%0h, Got=0x%0h", 
                                  expected_data, trans.read_data))
                    end else begin
                        `uvm_info("SCOREBOARD", $sformatf("READ PASS: data=0x%0h", trans.read_data), UVM_LOW)
                    end
                end else begin
                    underflow_count++;
                    `uvm_error("SCOREBOARD", "UNDERFLOW: Attempted read from empty FIFO")
                end
            end
            
            fifo_transaction::WRITE_READ: begin
                // Handle simultaneous write and read
                if(ref_fifo.size() > 0) begin
                    expected_data = ref_fifo.pop_front();
                    read_count++;
                    
                    if(trans.read_data !== expected_data) begin
                        error_count++;
                        `uvm_error("SCOREBOARD", $sformatf("SIMULTANEOUS READ DATA MISMATCH: Expected=0x%0h, Got=0x%0h", 
                                  expected_data, trans.read_data))
                    end
                end else begin
                    underflow_count++;
                end
                
                if(ref_fifo.size() < fifo_depth) begin
                    ref_fifo.push_back(trans.data);
                    write_count++;
                end else begin
                    overflow_count++;
                end
            end
        endcase
        
        // Check status flags
        calculate_expected_flags(expected_full, expected_empty, expected_almost_full, expected_almost_empty);
        
        if(trans.full !== expected_full) begin
            error_count++;
            `uvm_error("SCOREBOARD", $sformatf("FULL FLAG MISMATCH: Expected=%0d, Got=%0d, FIFO size=%0d", 
                      expected_full, trans.full, ref_fifo.size()))
        end
        
        if(trans.empty !== expected_empty) begin
            error_count++;
            `uvm_error("SCOREBOARD", $sformatf("EMPTY FLAG MISMATCH: Expected=%0d, Got=%0d, FIFO size=%0d", 
                      expected_empty, trans.empty, ref_fifo.size()))
        end
    endfunction
    
    virtual function void calculate_expected_flags(output logic full, empty, 
                                                 output logic almost_full, almost_empty);
        full = (ref_fifo.size() == fifo_depth);
        empty = (ref_fifo.size() == 0);
        almost_full = (ref_fifo.size() >= fifo_depth - 1);
        almost_empty = (ref_fifo.size() <= 1);
    endfunction
    
    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD", $sformatf("\n=== FIFO VERIFICATION SUMMARY ==="), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("Total Writes: %0d", write_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("Total Reads: %0d", read_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("Overflows: %0d", overflow_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("Underflows: %0d", underflow_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("Errors: %0d", error_count), UVM_NONE)
        `uvm_info("SCOREBOARD", $sformatf("Final FIFO Size: %0d", ref_fifo.size()), UVM_NONE)
        
        if(error_count == 0 && overflow_count == 0 && underflow_count == 0)
            `uvm_info("SCOREBOARD", "✅ ALL TESTS PASSED!", UVM_NONE)
        else
            `uvm_error("SCOREBOARD", "❌ TEST FAILURES DETECTED!")
    endfunction
endclass
