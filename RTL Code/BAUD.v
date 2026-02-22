module baud_gen #(
    parameter CLK_FREQ = 50_000_000
)(
    input  clk, rst,
    input  [2:0] baud_sel,   // select baud rate
    output reg  baud_clk,     // TX clock
    output reg  baud_x16_clk  // RX oversample clock
);

    reg [11:0] divisor_1x;
    reg [7:0] divisor_16x;
    reg [11:0] counter_1x;
    reg [7:0] counter_16x;

    // compute divisors for both clocks
    always @(*) begin
        case (baud_sel)
            3'b000: begin // 9600
                divisor_1x  = CLK_FREQ /(2 * 9600);
                divisor_16x = CLK_FREQ /(2 * 9600 * 16);
            end
            3'b001: begin // 19200
                divisor_1x  = CLK_FREQ /(2 * 19200);
                divisor_16x = CLK_FREQ /(2 * 19200 * 16);
            end
            3'b010: begin // 38400
                divisor_1x  = CLK_FREQ /(2 * 38400);
                divisor_16x = CLK_FREQ /(2 * 38400 * 16);
            end
            3'b011: begin // 57600
                divisor_1x  = CLK_FREQ /(2 * 57600);
                divisor_16x = CLK_FREQ /(2 * 57600 * 16);
            end
            3'b100: begin // 115200
                divisor_1x  = CLK_FREQ /(2 * 115200);
                divisor_16x = CLK_FREQ /(2 * 115200 * 16);
            end
            default: begin
                divisor_1x  = CLK_FREQ /(2 * 9600);
                divisor_16x = CLK_FREQ /(2 * 9600 * 16);
            end
        endcase
    end

    // TX baud clock (1x)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_1x <= 0;
            baud_clk   <= 0;
        end else begin
            if (counter_1x == divisor_1x - 1) begin
                counter_1x <= 0;
                baud_clk   <= ~baud_clk;
            end else begin
                counter_1x <= counter_1x + 1;
            end
        end
    end

    // RX baud clock (16x oversample)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_16x  <= 0;
            baud_x16_clk <= 0;
        end else begin
            if (counter_16x == divisor_16x - 1) begin
                counter_16x <= 0;
                baud_x16_clk <= ~baud_x16_clk;
            end else begin
                counter_16x <= counter_16x + 1;
            end
        end
    end

endmodule
