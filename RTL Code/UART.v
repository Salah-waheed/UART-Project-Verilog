module UART_top #(
    parameter CLK_FREQ = 50_000_000   // system clock frequency
)(
    input        clk,        // system clock (e.g., 50 MHz)
    input        rst,        // reset
    input  [2:0] baud_sel,   // baud rate selector
    output       baud_clk,       // 1x baud clock for TX
    output       baud_x16_clk,   // 16x baud clock for RX
    
    // TX interface
    input        tx_start,   // trigger transmission
    input  [7:0] tx_data,    // parallel data to send
    output       tx_busy,    // transmitter busy flag
    output       tx_serial,  // serial TX line

    // RX interface
    input        rx_serial,  // serial RX line
    output [7:0] rx_data,    // received byte
    output       rx_done,    // high when RX completes a byte
    output       rx_busy     // receiver busy flag
);



    // -------------------------------------------------
    // Baud Rate Generator
    baud_gen #(
        .CLK_FREQ(CLK_FREQ)
    ) u_baud (
        .clk(clk),
        .rst(rst),
        .baud_sel(baud_sel),
        .baud_clk(baud_clk),
        .baud_x16_clk(baud_x16_clk)
    );

    // -------------------------------------------------
    // Transmitter
    TX u_tx (
        .data(tx_data),
        .start(tx_start),
        .rst(rst),
        .baud_clk(baud_clk),
        .serial_data(tx_serial),
        .busy(tx_busy)
    );

    // -------------------------------------------------
    // Receiver
    RX u_rx (
        .serial_in(rx_serial),
        .rst(rst),
        .baud_x16_clk(baud_x16_clk),
        .data(rx_data),
        .rx_done(rx_done),
        .busy(rx_busy)
    );

endmodule
