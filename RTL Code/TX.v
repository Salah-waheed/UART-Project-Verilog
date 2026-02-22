module TX(
    input  [7:0] data,
    input        start, rst, baud_clk,
    output reg   serial_data, busy
);

    // FSM states
    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] cur_state = IDLE;
    reg [7:0] shift_reg;
    reg [2:0] bit_counter;

    // Sequential FSM 
    always @(posedge baud_clk or posedge rst) begin
        if (rst) begin
            cur_state   <= IDLE;
            shift_reg   <= 0;
            bit_counter <= 0;
            serial_data <= 1; // IDLE
            busy        <= 0;
        end else begin
            case (cur_state)
                //----------------------------------------------
                IDLE: begin
                    serial_data <= 1;
                    busy <= 0;
                    bit_counter <= 0;
                    if (start) begin
                        shift_reg <= data;   // load byte
                        cur_state <= START;    
                    end
                end
                
                //----------------------------------------------
                START:begin
                    serial_data <= 0;
                    busy <= 1;
                    cur_state <= DATA;
                end
                
                //----------------------------------------------
                DATA: begin
                    busy <= 1;
                    serial_data <= shift_reg[bit_counter];         
                    bit_counter <= bit_counter + 1;
                    if (bit_counter == 7)
                        cur_state <= STOP;
                end
                
                //----------------------------------------------
                STOP: begin
                    serial_data <= 1;
                    busy <= 1;
                    if(start) begin
                    shift_reg <= data;   // load byte
                    cur_state <= START;
                    end
                    else
                    cur_state <= IDLE;
                end

                default: cur_state <= IDLE;
            endcase
        end
    end

endmodule
