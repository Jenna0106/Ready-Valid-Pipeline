module top #(
    parameter DATA_W = 32
)(
    input  wire                 clk,
    input  wire                 rst_n,

    // Input side
    input  wire                 in_valid,
    output wire                 in_ready,
    input  wire [DATA_W-1:0]    in_data,

    // Output side
    output wire                 out_valid,
    input  wire                 out_ready,
    output wire [DATA_W-1:0]    out_data
);

    reg [DATA_W-1:0] data_q;
    reg              full;

    // Handshake signals
    wire accept_in  = in_valid  && in_ready;
    wire accept_out = out_valid && out_ready;

    // Ready/valid assignments
    assign out_valid = full;
    assign out_data  = data_q;

    // Can accept new data if empty, or if current data is being consumed
    assign in_ready = !full || accept_out;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            full   <= 1'b0;
            data_q <= {DATA_W{1'b0}};
        end else begin
            case ({accept_in, accept_out})
                2'b10: begin
                    // Load new data into empty register
                    data_q <= in_data;
                    full   <= 1'b1;
                end

                2'b01: begin
                    // Output consumed, no new input
                    full <= 1'b0;
                end

                2'b11: begin
                    // Simultaneous consume and accept (bypass behavior)
                    data_q <= in_data;
                    full   <= 1'b1;
                end

                default: begin
                    // Hold state
                    full <= full;
                end
            endcase
        end
    end

endmodule
