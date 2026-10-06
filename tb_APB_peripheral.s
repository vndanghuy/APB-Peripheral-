`timescale 1ns/1ps

module tb_APB;
    // Testbench Signals
    logic        clk;
    logic        rst;

    logic        psel;
    logic        penable;
    logic        pwrite;
    logic [7:0]  paddr;
    logic [31:0] pwdata;

    logic [31:0] prdata;
    logic        pready;
    // DUT
    APB dut (
        .clk     (clk),
        .rst     (rst),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .paddr   (paddr),
        .pwdata  (pwdata),
        .prdata  (prdata),
        .pready  (pready)
    );

    // Clock Generation
    // 10 ns period
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    // APB Write Task
    task automatic apb_write(
        input logic [7:0]  addr,
        input logic [31:0] data
    );

        // SETUP phase
        @(negedge clk);

        psel    = 1;
        penable = 0;
        pwrite  = 1;
        paddr   = addr;
        pwdata  = data;

        // ACCESS phase
        @(negedge clk);

        penable = 1;

        // Wait for PREADY
        @(posedge clk);

        if (!pready)
            $error("WRITE ERROR: PREADY was not asserted");

        // Return to IDLE
        @(negedge clk);

        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;

    endtask

    // APB Read Task
    task automatic apb_read(
        input  logic [7:0]  addr,
        output logic [31:0] data
    );

        // SETUP phase
        @(negedge clk);

        psel    = 1;
        penable = 0;
        pwrite  = 0;
        paddr   = addr;
        pwdata  = 0;

        // ACCESS phase
        @(negedge clk);

        penable = 1;

        @(posedge clk);

        if (!pready)
            $error("READ ERROR: PREADY was not asserted");

        data = prdata;

        // Return to IDLE
        @(negedge clk);

        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;

    endtask
    // Test Sequence
    logic [31:0] read_data;

    initial begin
        // Initial values
        rst     = 1;

        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = 0;
        pwdata  = 0;

        // Hold reset for 2 clocks
        repeat (2) @(posedge clk);

        rst = 0;
        // TEST 1: Write CONTROL register
        $display("\n========================================");
        $display("TEST 1: WRITE CONTROL");
        $display("========================================");

        apb_write(8'h00, 32'h00000001);

        // TEST 2: Read CONTROL register
        $display("\n========================================");
        $display("TEST 2: READ CONTROL");
        $display("========================================");

        apb_read(8'h00, read_data);

        $display("CONTROL = 0x%08h", read_data);

        if (read_data !== 32'h00000001)
            $error("CONTROL READ FAILED!");
        else
            $display("CONTROL READ PASSED!");

        // TEST 3: Write DATA register
        $display("\n========================================");
        $display("TEST 3: WRITE DATA");
        $display("========================================");

        apb_write(8'h04, 32'h12345678);

        // TEST 4: Read DATA register
        $display("\n========================================");
        $display("TEST 4: READ DATA");
        $display("========================================");

        apb_read(8'h04, read_data);

        $display("DATA = 0x%08h", read_data);

        if (read_data !== 32'h12345678)
            $error("DATA READ FAILED!");
        else
            $display("DATA READ PASSED!");

        // TEST 5: Read STATUS register
        $display("\n========================================");
        $display("TEST 5: READ STATUS");
        $display("========================================");

        apb_read(8'h08, read_data);

        $display("STATUS = 0x%08h", read_data);
        
        // TEST 6: Invalid Address
        $display("\n========================================");
        $display("TEST 6: INVALID ADDRESS");
        $display("========================================");

        apb_read(8'h0C, read_data);

        $display("INVALID ADDRESS READ = 0x%08h", read_data);

        if (read_data !== 32'b0)
            $error("INVALID ADDRESS TEST FAILED!");
        else
            $display("INVALID ADDRESS TEST PASSED!");

        // Finish
        $display("\n========================================");
        $display("ALL TESTS COMPLETED");
        $display("========================================");

        #20;

        $finish;
    end

endmodule