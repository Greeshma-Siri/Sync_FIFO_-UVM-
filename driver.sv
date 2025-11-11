class fifo_driver extends uvm_driver #(fifo_transaction);
    virtual fifo_if vif;
    `uvm_component_utils(fifo_driver)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        reset_fifo();
        
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task reset_fifo();
        vif.driver_cb.wr_en <= 0;
        vif.driver_cb.rd_en <= 0;
        vif.driver_cb.data_in <= 0;
        @(vif.driver_cb);
    endtask
    
    virtual task drive_transaction(fifo_transaction trans);
        case(trans.op)
            fifo_transaction::WRITE: begin
                if(!vif.driver_cb.full) begin
                    vif.driver_cb.wr_en <= 1;
                    vif.driver_cb.data_in <= trans.data;
                    vif.driver_cb.rd_en <= 0;
                    `uvm_info("DRIVER", $sformatf("Writing data: 0x%0h", trans.data), UVM_MEDIUM)
                end else begin
                    `uvm_warning("DRIVER", "Attempted write to full FIFO")
                end
            end
            
            fifo_transaction::READ: begin
                if(!vif.driver_cb.empty) begin
                    vif.driver_cb.rd_en <= 1;
                    vif.driver_cb.wr_en <= 0;
                    `uvm_info("DRIVER", "Reading data from FIFO", UVM_MEDIUM)
                end else begin
                    `uvm_warning("DRIVER", "Attempted read from empty FIFO")
                end
            end
            
            fifo_transaction::WRITE_READ: begin
                // Write then read in same cycle (if possible)
                vif.driver_cb.wr_en <= !vif.driver_cb.full;
                vif.driver_cb.rd_en <= !vif.driver_cb.empty;
                vif.driver_cb.data_in <= trans.data;
                `uvm_info("DRIVER", $sformatf("Simultaneous write(0x%0h) and read", trans.data), UVM_MEDIUM)
            end
        endcase
        
        @(vif.driver_cb);
        vif.driver_cb.wr_en <= 0;
        vif.driver_cb.rd_en <= 0;
    endtask
endclass
