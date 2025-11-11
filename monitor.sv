class fifo_monitor extends uvm_monitor;
    virtual fifo_if vif;
    uvm_analysis_port #(fifo_transaction) item_collected_port;
    `uvm_component_utils(fifo_monitor)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        fifo_transaction trans;
        forever begin
            trans = fifo_transaction::type_id::create("trans");
            collect_transaction(trans);
            item_collected_port.write(trans);
        end
    endtask
    
    virtual task collect_transaction(fifo_transaction trans);
        @(vif.monitor_cb);
        
        // Capture operation type based on control signals
        if(vif.monitor_cb.wr_en && !vif.monitor_cb.rd_en)
            trans.op = fifo_transaction::WRITE;
        else if(!vif.monitor_cb.wr_en && vif.monitor_cb.rd_en)
            trans.op = fifo_transaction::READ;
        else if(vif.monitor_cb.wr_en && vif.monitor_cb.rd_en)
            trans.op = fifo_transaction::WRITE_READ;
        
        trans.data = vif.monitor_cb.data_in;
        trans.read_data = vif.monitor_cb.data_out;
        trans.full = vif.monitor_cb.full;
        trans.empty = vif.monitor_cb.empty;
        trans.almost_full = vif.monitor_cb.almost_full;
        trans.almost_empty = vif.monitor_cb.almost_empty;
        
        `uvm_info("MONITOR", $sformatf("Captured: op=%s, data_in=0x%0h, data_out=0x%0h, full=%0d, empty=%0d", 
                  trans.op.name(), trans.data, trans.read_data, trans.full, trans.empty), UVM_HIGH)
    endtask
endclass
