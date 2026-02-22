module RX(
    input        serial_in, rst, baud_x16_clk,
    output reg [7:0]  data,
    output reg   rx_done, busy
);

parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

reg [1:0] cur_state = IDLE;   // FSM state
reg [7:0] shift_reg;          // shift register to build received byte
reg [2:0] bit_counter;        // counts received bits (0..7)
reg [3:0] sample_counter;     // oversample counter (0..15)

always @(posedge baud_x16_clk or posedge rst) begin
    if (rst) begin
        cur_state      <= IDLE;
        shift_reg      <= 0;
        bit_counter    <= 0;
        sample_counter <= 0;
        data           <= 0;
        rx_done        <= 0;
        busy           <= 0;
    end else begin
        case (cur_state)
            // -------------------------------------------------
            IDLE: begin
                rx_done <= 0;
                busy    <= 0;
                if (~serial_in) begin   // start bit detected
                    busy            <= 1;
                    sample_counter  <= 0;
                    cur_state       <= START;
                end
            end

            // -------------------------------------------------
            START: begin
                sample_counter <= sample_counter + 1;
                if (sample_counter == 7) begin // middle of start bit
                    if (~serial_in) begin // still low ? valid start
                        bit_counter    <= 0;
                        sample_counter <= 0;
                        cur_state      <= DATA;
                    end else begin
                        cur_state <= IDLE; // false start
                    end
                end
            end

            // -------------------------------------------------
            DATA: begin
                sample_counter <= sample_counter + 1;
                if (sample_counter == 15) begin // middle of data bit
                    sample_counter <= 0;
                    shift_reg[bit_counter] <= serial_in;
                    if (bit_counter == 7)
                        cur_state <= STOP;
                    else
                        bit_counter <= bit_counter + 1;
                end
            end

            // -------------------------------------------------
            STOP: begin
                sample_counter <= sample_counter + 1;
                if (sample_counter == 15) begin // middle of stop bit
                    data    <= shift_reg;
                    rx_done <= 1;
                    busy    <= 0;
                    cur_state <= IDLE;
                end
            end
        endcase
    end
end

endmodule
