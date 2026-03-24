`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2026 05:43:03 PM
// Design Name: 
// Module Name: Programmer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module fpga_slave_serial_config #(
    parameter SYS_CLK_FREQ   = 100_000_000, // 100 MHz System Clock
    parameter CCLK_FREQ      = 1_000_000,   // 1 MHz Target CCLK
    parameter BITSTREAM_SIZE = 340606       // Depth of your .coe file
)(
    input  wire clk,           // 100 MHz Main system clock
    input  wire rst_n,         // Active-low system reset
    
    // Target FPGA Pins
    input  wire target_init_b, // INIT_B from target 
    input  wire target_done,   // DONE from target 
    output reg  target_prog_b, // PROG_B to target
    output reg  target_cclk,   // CCLK to target
    output reg  target_din,    // DIN to target
    
    // Status Outputs 
    output reg  config_success,
    output reg  config_error
);

    // -------------------------------------------------------------------------
    // 1. Clock Divider (Generates a 2 MHz tick for 1 MHz CCLK)
    // 100 MHz / 2 MHz = 50 clock cycles per tick.
    // -------------------------------------------------------------------------
    localparam TICK_COUNT_MAX = (SYS_CLK_FREQ / (CCLK_FREQ * 2)) - 1; // 49
    reg [15:0] tick_counter;
    reg tick;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_counter <= 0;
            tick <= 0;
        end else begin
            if (tick_counter >= TICK_COUNT_MAX) begin
                tick_counter <= 0;
                tick <= 1'b1; // Generates a pulse every 0.5 microseconds
            end else begin
                tick_counter <= tick_counter + 1;
                tick <= 1'b0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 2. BRAM IP Instantiation
    // -------------------------------------------------------------------------
    reg  [18:0] addra_reg;  // Connected to BRAM address
    wire [7:0]  douta_wire; // Connected to BRAM data output

    blk_mem_gen_0 your_instance_name (
      .clka(clk),           // 100 MHz System Clock
      .ena(1'b1),           // ALWAYS ON (Option 1)
      .addra(addra_reg),    // Address from State Machine
      .douta(douta_wire)    // Data to State Machine
    );

    // -------------------------------------------------------------------------
    // 3. Main State Machine
    // -------------------------------------------------------------------------
    localparam [3:0]
        S_IDLE         = 4'd0,
        S_PULSE_PROG   = 4'd1,
        S_WAIT_INIT    = 4'd2,
        S_FETCH_DATA   = 4'd3,
        S_SHIFT_LOW    = 4'd4,
        S_SHIFT_HIGH   = 4'd5,
        S_EXTRA_CLOCKS = 4'd6,
        S_FINISH       = 4'd7;

    reg [3:0]  state;
    reg [15:0] delay_timer;  
    reg [2:0]  bit_index;    
    reg [7:0]  shift_reg;    
    reg [4:0]  extra_clocks; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= S_IDLE;
            target_prog_b  <= 1'b1;
            target_cclk    <= 1'b0;
            target_din     <= 1'b0;
            addra_reg      <= 0;
            config_success <= 1'b0;
            config_error   <= 1'b0;
            delay_timer    <= 0;
            bit_index      <= 0;
            extra_clocks   <= 0;
        end else if (tick) begin 
            
            case (state)
                S_IDLE: begin
                    addra_reg      <= 0;
                    config_success <= 1'b0;
                    config_error   <= 1'b0;
                    target_prog_b  <= 1'b0; // Pull PROG_B low
                    delay_timer    <= 0;
                    state          <= S_PULSE_PROG;
                end

                S_PULSE_PROG: begin
                    // Exact 1 ms delay. 
                    // Tick is 0.5 us. 1000 us / 0.5 us = 2000 ticks.
                    if (delay_timer >= 2000) begin
                        target_prog_b <= 1'b1; // Release PROG_B
                        state         <= S_WAIT_INIT;
                    end else begin
                        delay_timer <= delay_timer + 1;
                    end
                end

                S_WAIT_INIT: begin
                    // Target FPGA releases INIT_B when memory is cleared
                    if (target_init_b == 1'b1) begin
                        state <= S_FETCH_DATA;
                    end
                end

                S_FETCH_DATA: begin
                    // The Primitive Register latency is 2 cycles.
                    // Because we waited 50 clock cycles for this tick, 
                    // douta_wire is perfectly stable here.
                    shift_reg   <= douta_wire;
                    bit_index   <= 0;
                    target_cclk <= 1'b0;
                    state       <= S_SHIFT_LOW;
                end

                S_SHIFT_LOW: begin
                    target_cclk <= 1'b0;
                    target_din  <= shift_reg[7]; // Output MSB
                    shift_reg   <= {shift_reg[6:0], 1'b0}; // Shift left
                    state       <= S_SHIFT_HIGH;
                end

                S_SHIFT_HIGH: begin
                    target_cclk <= 1'b1; // Target samples DIN here
                    
                    if (bit_index == 7) begin
                        if (addra_reg == BITSTREAM_SIZE - 1) begin
                            extra_clocks <= 0;
                            state        <= S_EXTRA_CLOCKS;
                        end else begin
                            addra_reg <= addra_reg + 1; // Change address
                            state     <= S_FETCH_DATA;
                        end
                    end else begin
                        bit_index <= bit_index + 1;
                        state     <= S_SHIFT_LOW;
                    end
                end

                S_EXTRA_CLOCKS: begin
                    target_cclk <= ~target_cclk; 
                    target_din  <= 1'b0; 
                    
                    if (target_cclk == 1'b1) begin 
                        if (extra_clocks == 15) begin
                            state <= S_FINISH;
                        end else begin
                            extra_clocks <= extra_clocks + 1;
                        end
                    end
                end

                S_FINISH: begin
                    target_cclk <= 1'b0;
                    if (target_done == 1'b1) begin
                        config_success <= 1'b1; 
                    end else begin
                        config_error   <= 1'b1; 
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule