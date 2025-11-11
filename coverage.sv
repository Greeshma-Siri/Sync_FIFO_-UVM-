class fifo_coverage extends uvm_subscriber #(fifo_transaction);
    fifo_transaction cov_trans;
    `uvm_component_utils(fifo_coverage)
    
    covergroup fifo_cg;
        option.per_instance = 1;
        
        // Operation coverage
        op_cp: coverpoint cov_trans.op {
            bins write_op = {fifo_transaction::WRITE};
            bins read_op  = {fifo_transaction::READ};
            bins write_read_op = {fifo_transaction::WRITE_READ};
        }
        
        // Data coverage
        data_in_cp: coverpoint cov_trans.data {
            bins zero = {0};
            bins max  = {8'hFF};
            bins low  = {[1:85]};
            bins mid  = {[86:170]};
            bins high = {[171:254]};
        }
        
        // Status coverage
        full_cp: coverpoint cov_trans.full;
        empty_cp: coverpoint cov_trans.empty;
        almost_full_cp: coverpoint cov_trans.almost_full;
        almost_empty_cp: coverpoint cov_trans.almost_empty;
        
        // Cross coverage - critical scenarios
        op_vs_full: cross op_cp, full_cp;
        op_vs_empty: cross op_cp, empty_cp;
        write_when_full: cross op_cp, full_cp {
            bins write_to_full = binsof(op_cp.write_op) && binsof(full_cp) intersect {1};
        }
        read_when_empty: cross op_cp, empty_cp {
            bins read_from_empty = binsof(op_cp.read_op) && binsof(empty_cp) intersect {1};
        }
        
        // FIFO level coverage
        fifo_level: coverpoint ref_fifo_size {
            bins empty = {0};
            bins almost_empty = {[1:3]};
            bins middle = {[4:12]};
            bins almost_full = {[13:15]};
            bins full = {16};
        }
        
    endgroup
    
    // Reference to scoreboard for FIFO size
    fifo_scoreboard scb;
    int ref_fifo_size;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo_cg = new;
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Get reference to scoreboard for FIFO size
        if(!uvm_config_db#(fifo_scoreboard)::get(this, "", "scb", scb))
            `uvm_warning("COV", "Scoreboard reference not available for FIFO level coverage")
    endfunction
    
    virtual function void write(fifo_transaction t);
        cov_trans = t;
        if(scb != null)
            ref_fifo_size = scb.ref_fifo.size();
        fifo_cg.sample();
    endfunction
endclass
