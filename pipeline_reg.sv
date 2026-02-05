module pipeline_reg #(
    parameter int DATA_W = 32
)(
    input  logic clk,
    input  logic rst_n,

    // Input interface
    input  logic in_valid,
    output logic in_ready,
    input  logic [DATA_W-1:0] in_data,

    // Output interface
    output logic out_valid,
    input  logic out_ready,
    output logic [DATA_W-1:0] out_data
);

    // Internal storage
    logic [DATA_W-1:0] data_q;
    logic full;

    // Handshake detection
    logic accept_in;
    logic accept_out;

    // Combinational handshake logic
    always_comb begin
        out_valid = full;
        out_data  = data_q;

        accept_out = out_valid && out_ready;
        in_ready   = !full || accept_out;
        accept_in  = in_valid && in_ready;
    end

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full <= 1'b0;
            data_q <= '0;
        end
        else begin
            unique case({accept_in, accept_out})
                2'b10: begin
                    data_q <= in_data;
                    full <= 1'b1;
                end

                2'b01: begin
                    full <= 1'b0;
                end

                2'b11: begin
                    data_q <= in_data;
                    full <= 1'b1;
                end

                default: begin
                    full <= full;
                end
            endcase
        end
    end

endmodule
