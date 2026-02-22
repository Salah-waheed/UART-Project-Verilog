`timescale 1ns/1ps

module tb_uart_loopback;

    // system clock (50 MHz)
    reg sys_clk = 0;
    always #10 sys_clk = ~sys_clk; // 20 ns period -> 50 MHz
    
    // -------------------------------------------------
    // testbench signals
    reg rst;
    reg start;
    reg [7:0] tx_data;
    reg [2:0] baud_sel;

    wire baud_clk;
    wire baud_x16_clk;
    wire tx_busy;
    wire tx_serial;
    wire [7:0] rx_data;
    wire rx_done;
    wire rx_busy;
    
    // -------------------------------------------------
    // Instantiate UART top-level (loopback: tx_serial ? rx_serial)
    UART_top #(
        .CLK_FREQ(50_000_000)
    ) u_uart (
        .clk(sys_clk),
        .rst(rst),
        .baud_sel(baud_sel),
        .baud_clk(baud_clk),
        .baud_x16_clk(baud_x16_clk),
        
        // TX interface
        .tx_start(start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_serial(tx_serial),

        // RX interface
        .rx_serial(tx_serial),  // loopback connection
        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_busy(rx_busy)
    );

    // -------------------------------------------------
    // test sequence
    initial begin
        // init
        rst = 1;
        start = 0;
        tx_data = 8'h00;
        baud_sel = 3'b100; // choose 115200 baud (fast)
        #200;              // wait a bit on sys clock
        rst = 0;

        // --- send first byte ---
        @(posedge baud_clk);
        tx_data = 8'hA5;  // 1010_0101
        start = 1;
        @(posedge baud_clk);
        start = 0;

        // wait for rx to assert rx_done (pulse when byte received)
        wait(rx_done);

        // --- send second byte ---
        @(posedge baud_clk);
        baud_sel = 3'b000;
        tx_data = 8'h3A;  // 0011_1010
        start = 1;
        @(posedge baud_clk);
        start = 0;
        
        wait(rx_done);

        // --- send Thierd byte ---
        @(posedge baud_clk);
        baud_sel = 3'b001;
        tx_data = 8'h3B;  // 0011_1011
        start = 1;
        @(posedge baud_clk);
        start = 0;
        
        wait(rx_done);
        
        #1000;
        $display("Testbench finished.");
        $finish;
    end

endmodule

