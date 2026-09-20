module uart_top (
    input  clk,       // 50MHz Board Clock
    input  uart_rx,   // Data coming from PC
    output uart_tx    // Data going to PC
);

    wire [7:0] rx_data;
    wire       rx_valid;
    wire       tx_busy;

    UART rx_inst (
        .clk(clk),
        .dain(uart_rx),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // rx_valid is held HIGH for one full bit period, not a single-cycle
    // pulse. Edge-detect it, and if the transmitter is still busy
    // finishing the previous byte, latch this one as "pending" instead
    // of dropping it -- this is what protects back-to-back bytes from
    // being silently lost.
    reg  rx_valid_d;
    wire rx_pulse = rx_valid & ~rx_valid_d;

    reg  [7:0] pending_data;
    reg        pending_flag;
    reg  [7:0] tx_data_reg;
    reg        tx_start;

    always @(posedge clk) begin
        rx_valid_d <= rx_valid;
        tx_start   <= 1'b0; // default: only pulses high for one cycle when needed

        if (rx_pulse) begin
            if (!tx_busy && !pending_flag) begin
                tx_data_reg <= rx_data;
                tx_start    <= 1'b1;
            end else begin
                // TX is busy right now -- queue this byte instead of losing it
                pending_data <= rx_data;
                pending_flag <= 1'b1;
            end
        end else if (pending_flag && !tx_busy) begin
            tx_data_reg  <= pending_data;
            tx_start     <= 1'b1;
            pending_flag <= 1'b0;
        end
    end

    UART_tx tx_inst (
        .clk     (clk),
        .data_in (tx_data_reg),
        .start   (tx_start),
        .busy    (tx_busy),
        .daout   (uart_tx)
    );

endmodule