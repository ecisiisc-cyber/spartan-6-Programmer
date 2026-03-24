`timescale 1ns / 1ps



module tb_fpga_slave_serial_config();



    // -------------------------------------------------------------------------
    // 1. Signals
    // -------------------------------------------------------------------------
    reg  clk;
    reg  rst_n;
    
    // Target FPGA simulated outputs (Inputs to our module)
    reg  target_init_b;
    reg  target_done;
    
    // Controller outputs (Outputs from our module)
    wire target_prog_b;
    wire target_cclk;
    wire target_din;
    wire config_success;
    wire config_error;

//for serial to prallerl conversion

reg [7:0] serial_parall;
reg [3:0] count;
reg buyterx;
    // -------------------------------------------------------------------------
    // 2. Instantiate the Unit Under Test (UUT)
    // -------------------------------------------------------------------------
    localparam TEST_SIZE = 340650; // Read the first 16 bytes of your real .coe



    fpga_slave_serial_config #(
        .SYS_CLK_FREQ(100_000_000), 
        .CCLK_FREQ(1_000_000),      
        .BITSTREAM_SIZE(TEST_SIZE)  
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .target_init_b(target_init_b),
        .target_done(target_done),
        .target_prog_b(target_prog_b),
        .target_cclk(target_cclk),
        .target_din(target_din),
        .config_success(config_success),
        .config_error(config_error)
    );



    // -------------------------------------------------------------------------
    // 3. Generate 100 MHz System Clock (10ns period)
    // -------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end



    // -------------------------------------------------------------------------
    // 4. Simulate Target FPGA Behavior (The Handshake)
    // -------------------------------------------------------------------------
    integer received_bits = 0;



    initial begin
        target_init_b = 1'b1;
        target_done   = 1'b0;
    end



    // Step A: Respond to Host pulling PROG_B LOW
    always @(negedge target_prog_b) begin
        target_init_b <= 1'b0; // Acknowledge reset
        target_done   <= 1'b0;
        received_bits <= 0;
        serial_parall<=0;
        buyterx<=0;
        count<=0;
    end



    // Step B: Respond to Host releasing PROG_B HIGH
    always @(posedge target_prog_b) begin
        // Simulate a 5 microsecond internal memory clearing delay
        #5000; 
        target_init_b <= 1'b1; // Signal that target is ready for data!
    end


    // Step C: Count incoming CCLK edges and assert DONE
always @(posedge target_cclk) begin
    serial_parall <= {serial_parall[6:0], target_din};

    if (count == 7) begin 
        buyterx <= 1;
        count <= 0; 
    end else begin 
        count <= count + 1; 
        buyterx <= 0;
    end
end

    // -------------------------------------------------------------------------
    // 5. Main Simulation Sequence
    // -------------------------------------------------------------------------
    initial begin
        // Apply System Reset
        rst_n = 0;
        #100;
        rst_n = 1;



        $display("--------------------------------------------------");
        $display("Starting Configuration Simulation...");
        $display("Reading first %0d bytes from Block RAM IP...", TEST_SIZE);
        $display("--------------------------------------------------");
        
        // Wait for the state machine to hit Success or Error
        wait (config_success == 1'b1 || config_error == 1'b1);
        
        if (config_success) begin
            $display("SIMULATION PASSED! config_success is HIGH.");
        end else begin
            $display("SIMULATION FAILED! config_error is HIGH.");
        end



        // Let the simulation run just a bit longer to observe the final extra CCLK cycles
        #10000; 
        $finish;
    end



endmodule