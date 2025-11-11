class fifo_test_base extends uvm_test;
    fifo_env env;
    `uvm_component_utils(fifo_test_base)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        // Base test doesn't run anything
        phase.raise_objection(this);
        phase.drop_objection(this);
    endtask
endclass

class basic_fifo_test extends fifo_test_base;
    `uvm_component_utils(basic_fifo_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        basic_fifo_sequence seq;
        
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting Basic FIFO Test", UVM_LOW)
        
        seq = basic_fifo_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #1000; // Wait for all transactions to complete
        
        `uvm_info("TEST", "Basic FIFO Test Completed", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

class random_fifo_test extends fifo_test_base;
    `uvm_component_utils(random_fifo_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        random_fifo_sequence seq;
        
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting Random FIFO Test", UVM_LOW)
        
        seq = random_fifo_sequence::type_id::create("seq");
        assert(seq.randomize() with { num_transactions == 200; });
        seq.start(env.agent.sequencer);
        
        #2000; // Wait for all transactions to complete
        
        `uvm_info("TEST", "Random FIFO Test Completed", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

class corner_case_fifo_test extends fifo_test_base;
    `uvm_component_utils(corner_case_fifo_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        corner_case_fifo_sequence seq;
        
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting Corner Case FIFO Test", UVM_LOW)
        
        seq = corner_case_fifo_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #1500; // Wait for all transactions to complete
        
        `uvm_info("TEST", "Corner Case FIFO Test Completed", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

class data_pattern_fifo_test extends fifo_test_base;
    `uvm_component_utils(data_pattern_fifo_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        data_pattern_fifo_sequence seq;
        
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting Data Pattern FIFO Test", UVM_LOW)
        
        seq = data_pattern_fifo_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #1000; // Wait for all transactions to complete
        
        `uvm_info("TEST", "Data Pattern FIFO Test Completed", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass

class fifo_regression_test extends fifo_test_base;
    `uvm_component_utils(fifo_regression_test)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        basic_fifo_sequence basic_seq;
        random_fifo_sequence rand_seq;
        corner_case_fifo_sequence corner_seq;
        data_pattern_fifo_sequence data_seq;
        
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting FIFO Regression Test Suite", UVM_LOW)
        
        // Run basic test
        `uvm_info("REGRESSION", "Running Basic FIFO Test", UVM_LOW)
        basic_seq = basic_fifo_sequence::type_id::create("basic_seq");
        basic_seq.start(env.agent.sequencer);
        #1000;
        
        // Run random test
        `uvm_info("REGRESSION", "Running Random FIFO Test", UVM_LOW)
        rand_seq = random_fifo_sequence::type_id::create("rand_seq");
        assert(rand_seq.randomize() with { num_transactions == 100; });
        rand_seq.start(env.agent.sequencer);
        #1000;
        
        // Run corner case test
        `uvm_info("REGRESSION", "Running Corner Case Test", UVM_LOW)
        corner_seq = corner_case_fifo_sequence::type_id::create("corner_seq");
        corner_seq.start(env.agent.sequencer);
        #1000;
        
        // Run data pattern test
        `uvm_info("REGRESSION", "Running Data Pattern Test", UVM_LOW)
        data_seq = data_pattern_fifo_sequence::type_id::create("data_seq");
        data_seq.start(env.agent.sequencer);
        #1000;
        
        `uvm_info("TEST", "FIFO Regression Test Suite Completed", UVM_LOW)
        phase.drop_objection(this);
    endtask
endclass
