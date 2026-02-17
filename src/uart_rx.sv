module uart_rx (
    input  logic       clk,       // 50MHz
    input  logic       rst_n,
    input  logic       rx_line,   // Serial input
    output logic [7:0] rx_data,   // Parallel output
    output logic       rx_done    // High for one cycle when byte received
);
  // --- NEW: Synchronizer Registers ---
    logic rx_sync_stage1;
    logic rx_sync; // Use this signal in the FSM

    localparam int TICKS_PER_BIT = 5208;
    localparam int TICKS_PER_OVERSAMPLE = 325; // 5208 / 16

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [8:0]  tick_count;  // Counts to 325
    logic [3:0]  sample_count; // Counts 0 to 15 (the 16 samples)
    logic [2:0]  bit_index;
    logic [7:0]  rx_shift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            rx_data        <= 8'h00; // Removes NaN from output
            rx_shift_reg   <= 8'h00;
            rx_done      <= 1'b0;
            tick_count   <= 0;
            sample_count <= 0;
        end else begin
          // --- SYNC THE INPUT ---
            rx_sync_stage1 <= rx_line;
            rx_sync        <= rx_sync_stage1;
            rx_done <= 1'b0; // Default pulse

            case (state)
                IDLE: begin
                  if (rx_sync == 1'b0) begin // Detect falling edge
                        tick_count   <= 0;
                        sample_count <= 0;
                        state        <= START;
                    end
                end

                START: begin
                    if (tick_count < TICKS_PER_OVERSAMPLE - 1) begin
                        tick_count <= tick_count + 1;
                    end else begin
                        tick_count <= 0;
                        if (sample_count == 7) begin // Middle of Start bit
                            if (rx_sync == 1'b0) begin
                                sample_count <= 0;
                                bit_index    <= 0;
                                state        <= DATA;
                            end else begin
                                state <= IDLE; // Noise detected
                            end
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end

                DATA: begin
                    if (tick_count < TICKS_PER_OVERSAMPLE - 1) begin
                        tick_count <= tick_count + 1;
                    end else begin
                        tick_count <= 0;
                        if (sample_count == 15) begin // Middle of Data bit
                            rx_shift_reg[bit_index] <= rx_line;
                            sample_count <= 0;
                            if (bit_index < 7)
                                bit_index <= bit_index + 1;
                            else
                                state <= STOP;
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end

                STOP: begin
                    if (tick_count < TICKS_PER_OVERSAMPLE - 1) begin
                        tick_count <= tick_count + 1;
                    end else begin
                        tick_count <= 0;
                        if (sample_count == 15) begin
                            rx_data <= rx_shift_reg;
                            rx_done <= 1'b1;
                            state   <= IDLE;
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule
