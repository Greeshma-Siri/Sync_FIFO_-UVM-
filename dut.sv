module fifo #(
    parameter DEPTH = 16,
    parameter DATA_WIDTH = 8
)(
    input logic clk,
    input logic reset_n,
    
    // Write Interface
    input logic wr_en,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic full,
    output logic almost_full,
    
    // Read Interface
    input logic rd_en,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic empty,
    output logic almost_empty
);
    
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    logic [4:0] wr_ptr, rd_ptr; // One extra bit for full/empty detection
    logic [4:0] fifo_count;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            for (int i = 0; i < DEPTH; i++)
                memory[i] <= 0;
        end else begin
            // Write operation
            if (wr_en && !full) begin
                memory[wr_ptr[3:0]] <= data_in;
                wr_ptr <= wr_ptr + 1;
            end
            
            // Read operation
            if (rd_en && !empty) begin
                data_out <= memory[rd_ptr[3:0]];
                rd_ptr <= rd_ptr + 1;
            end
            
            // Update FIFO count
            case ({wr_en && !full, rd_en && !empty})
                2'b01:   fifo_count <= fifo_count - 1; // Read only
                2'b10:   fifo_count <= fifo_count + 1; // Write only
                2'b11:   fifo_count <= fifo_count;     // Simultaneous
                default: fifo_count <= fifo_count;     // No operation
            endcase
        end
    end
    
    // Status flags
    assign full = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);
    assign almost_full = (fifo_count >= DEPTH-1);
    assign almost_empty = (fifo_count <= 1);
    
endmodule
