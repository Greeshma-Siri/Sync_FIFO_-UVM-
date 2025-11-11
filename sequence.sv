class basic_fifo_sequence extends uvm_sequence #(fifo_transaction);
    `uvm_object_utils(basic_fifo_sequence)
    
    function new(string name = "basic_fifo_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        fifo_transaction trans;
        
        `uvm_info("SEQ", "Starting basic FIFO test: Fill then empty", UVM_LOW)
        
        // Fill FIFO completely
        repeat(16) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::WRITE; });
            finish_item(trans);
        end
        
        // Empty FIFO completely
        repeat(16) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::READ; });
            finish_item(trans);
        end
    endtask
endclass

class random_fifo_sequence extends uvm_sequence #(fifo_transaction);
    rand int num_transactions = 100;
    `uvm_object_utils(random_fifo_sequence)
    
    function new(string name = "random_fifo_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        fifo_transaction trans;
        
        `uvm_info("SEQ", $sformatf("Starting random FIFO test with %0d transactions", num_transactions), UVM_LOW)
        
        repeat(num_transactions) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize());
            finish_item(trans);
        end
    endtask
endclass

class corner_case_fifo_sequence extends uvm_sequence #(fifo_transaction);
    `uvm_object_utils(corner_case_fifo_sequence)
    
    function new(string name = "corner_case_fifo_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        fifo_transaction trans;
        
        `uvm_info("SEQ", "Testing FIFO corner cases", UVM_LOW)
        
        // Test overflow - write beyond capacity
        repeat(20) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::WRITE; });
            finish_item(trans);
        end
        
        // Test underflow - read beyond available data
        repeat(20) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::READ; });
            finish_item(trans);
        end
        
        // Test simultaneous read/write at boundary conditions
        // Fill to almost full
        repeat(15) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::WRITE; });
            finish_item(trans);
        end
        
        // Test simultaneous operations at boundary
        repeat(10) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::WRITE_READ; });
            finish_item(trans);
        end
    endtask
endclass

class data_pattern_fifo_sequence extends uvm_sequence #(fifo_transaction);
    `uvm_object_utils(data_pattern_fifo_sequence)
    
    function new(string name = "data_pattern_fifo_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
        fifo_transaction trans;
        
        `uvm_info("SEQ", "Testing specific data patterns", UVM_LOW)
        
        // Test all zeros
        trans = fifo_transaction::type_id::create("trans");
        start_item(trans);
        assert(trans.randomize() with { 
            op == fifo_transaction::WRITE;
            data == 8'h00;
        });
        finish_item(trans);
        
        // Test all ones
        trans = fifo_transaction::type_id::create("trans");
        start_item(trans);
        assert(trans.randomize() with { 
            op == fifo_transaction::WRITE;
            data == 8'hFF;
        });
        finish_item(trans);
        
        // Test alternating pattern
        trans = fifo_transaction::type_id::create("trans");
        start_item(trans);
        assert(trans.randomize() with { 
            op == fifo_transaction::WRITE;
            data == 8'hAA;
        });
        finish_item(trans);
        
        trans = fifo_transaction::type_id::create("trans");
        start_item(trans);
        assert(trans.randomize() with { 
            op == fifo_transaction::WRITE;
            data == 8'h55;
        });
        finish_item(trans);
        
        // Read back patterns
        repeat(4) begin
            trans = fifo_transaction::type_id::create("trans");
            start_item(trans);
            assert(trans.randomize() with { op == fifo_transaction::READ; });
            finish_item(trans);
        end
    endtask
endclass
