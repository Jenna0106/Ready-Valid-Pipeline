`timescale 1ns/1ps

module tb_pipeline_reg;

    localparam int DATA_W = 32;

    logic clk;
    logic rst_n;

    logic in_valid;
    logic in_ready;
    logic [DATA_W-1:0]  in_data;

    logic out_valid;
    logic out_ready;
    logic [DATA_W-1:0]  out_data;

    // DUT
    pipeline_reg #(
        .DATA_W(DATA_W)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_data(in_data),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .out_data(out_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Send one data item (producer behavior)
    task automatic send(input logic [DATA_W-1:0] data);
        begin
            in_valid <= 1'b1;
            in_data  <= data;

            while (!in_ready)
                @(posedge clk);

            @(posedge clk);
            in_valid <= 1'b0;
        end
    endtask

    // Receive one data item (consumer behavior)
    task automatic recv;
        begin
            out_ready <= 1'b1;

            while (!out_valid)
                @(posedge clk);

            @(posedge clk);
            out_ready <= 1'b0;
        end
    endtask

    initial begin
        clk       = 0;
        rst_n     = 0;
        in_valid  = 0;
        in_data   = '0;
        out_ready = 0;

        repeat (2) @(posedge clk);
        rst_n = 1;

        // Test 1: Pass-through
        $display("TEST 1: Pass-through");
        out_ready = 1;
        send(32'hA5A5_0001);

        @(posedge clk);
        if (out_valid && out_data == 32'hA5A5_0001)
            $display("PASS");
        else
            $display("FAIL");

        // Test 2: Backpressure hold
        $display("TEST 2: Backpressure");
        out_ready = 0;
        send(32'hDEAD_BEEF);

        repeat (3) @(posedge clk);
        if (out_valid && out_data == 32'hDEAD_BEEF)
            $display("PASS");
        else
            $display("FAIL");

        // Test 3: Release backpressure
        $display("TEST 3: Release");
        out_ready = 1;
        @(posedge clk);

        if (!out_valid)
            $display("PASS");
        else
            $display("FAIL");

        // Test 4: Simultaneous in/out
        $display("TEST 4: Replace");
        out_ready = 1;
        send(32'h1234_5678);
        send(32'hCAFE_F00D);

        @(posedge clk);
        if (out_valid && out_data == 32'hCAFE_F00D)
            $display("PASS");
        else
            $display("FAIL");

        // Done
        repeat (5) @(posedge clk);
        $display("Simulation complete");
        $finish;
    end

endmodule
