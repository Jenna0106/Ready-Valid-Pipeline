`timescale 1ns/1ps

module tb;

    localparam DATA_W = 32;

    reg                  clk;
    reg                  rst_n;

    // Input side
    reg                  in_valid;
    wire                 in_ready;
    reg  [DATA_W-1:0]    in_data;

    // Output side
    wire                 out_valid;
    reg                  out_ready;
    wire [DATA_W-1:0]    out_data;

    // DUT
    top #(
        .DATA_W(DATA_W)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .in_data   (in_data),
        .out_valid (out_valid),
        .out_ready (out_ready),
        .out_data  (out_data)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    // Simple task to send one word
    task send(input [DATA_W-1:0] data);
        begin
            @(posedge clk);
            in_valid <= 1'b1;
            in_data  <= data;
            while (!in_ready)
                @(posedge clk);
            @(posedge clk);
            in_valid <= 1'b0;
        end
    endtask

    // Simple task to consume one word
    task recv;
        begin
            out_ready <= 1'b1;
            while (!out_valid)
                @(posedge clk);
            @(posedge clk);
            out_ready <= 1'b0;
        end
    endtask

    initial begin
        // Init
        clk       = 0;
        rst_n     = 0;
        in_valid  = 0;
        in_data   = 0;
        out_ready = 0;

        // Reset
        repeat (2) @(posedge clk);
        rst_n = 1;

        // -------------------------
        // Test 1: Pass-through
        // -------------------------
        $display("Test 1: Pass-through");
        out_ready = 1;
        send(32'hA5A5_0001);
        @(posedge clk);
        if (out_valid && out_data == 32'hA5A5_0001)
            $display("PASS: Pass-through");
        else
            $display("FAIL: Pass-through");

        // -------------------------
        // Test 2: Backpressure hold
        // -------------------------
        $display("Test 2: Backpressure");
        out_ready = 0;
        send(32'hDEAD_BEEF);

        // Hold for a few cycles
        repeat (3) @(posedge clk);
        if (out_valid && out_data == 32'hDEAD_BEEF)
            $display("PASS: Data held under backpressure");
        else
            $display("FAIL: Backpressure hold");

        // -------------------------
        // Test 3: Release backpressure
        // -------------------------
        $display("Test 3: Release backpressure");
        out_ready = 1;
        @(posedge clk);
        if (!out_valid)
            $display("PASS: Data released correctly");
        else
            $display("FAIL: Data not released");

        // -------------------------
        // Test 4: Simultaneous in/out
        // -------------------------
        $display("Test 4: Simultaneous in/out");
        out_ready = 1;
        send(32'h1234_5678);
        send(32'hCAFE_F00D);

        @(posedge clk);
        if (out_valid && out_data == 32'hCAFE_F00D)
            $display("PASS: Simultaneous transfer");
        else
            $display("FAIL: Simultaneous transfer");

        // Done
        repeat (5) @(posedge clk);
        $display("Simulation finished");
        $finish;
    end

endmodule
