class fifo_transaction extends uvm_sequence_item;
    rand fifo_op_t op;  // WRITE, READ, WRITE_READ
    rand logic [7:0] data;
    logic [7:0] read_data;
    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;
    
    typedef enum {WRITE, READ, WRITE_READ} fifo_op_t;
    
    // Constraints
    constraint valid_operations {
        op dist { WRITE := 40, READ := 40, WRITE_READ := 20 };
    }
    
    constraint valid_data {
        data inside {[0:255]};
    }
    
    `uvm_object_utils_begin(fifo_transaction)
        `uvm_field_enum(fifo_op_t, op, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(read_data, UVM_ALL_ON)
        `uvm_field_int(full, UVM_ALL_ON)
        `uvm_field_int(empty, UVM_ALL_ON)
        `uvm_field_int(almost_full, UVM_ALL_ON)
        `uvm_field_int(almost_empty, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "fifo_transaction");
        super.new(name);
    endfunction
endclass
