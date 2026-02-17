module uart_tx (
    input  logic       clk,      // 50MHz Clock
    input  logic       rst_n,    // Active-low Reset
    input  logic [7:0] tx_data,  // 8-bit Data to send
    input  logic       tx_start, // Pulse to start transmission
    output logic       tx_line,  // Serial output
    output logic       tx_busy   // High while transmitting
);

    // --- Baud Rate Generator (50MHz / 9600 = 5208) ---
    localparam int CLK_PER_BIT = 5208;
    
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [12:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  data_buffer;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            tx_line     <= 1'b1; // Idle state is High
            tx_busy     <= 1'b0;
            clk_count   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_line <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        data_buffer <= tx_data;
                        tx_busy     <= 1'b1;
                        state       <= START;
                    end
                end

                START: begin
                    tx_line <= 1'b0; // Start bit
                    if (clk_count < CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= DATA;
                        bit_index <= 0;
                    end
                end

                DATA: begin
                    tx_line <= data_buffer[bit_index];
                    if (clk_count < CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx_line <= 1'b1; // Stop bit
                    if (clk_count < CLK_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
