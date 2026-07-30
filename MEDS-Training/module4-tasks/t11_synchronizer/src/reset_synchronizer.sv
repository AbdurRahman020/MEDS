module reset_synchronizer (
    input  logic clk,
    input  logic rst_n_async,   // asynchronous active-low reset
    output logic rst_n_sync     // synchronized active-low reset
);

    logic sync_ff1, sync_ff2;

    // asynchronous assertion, synchronous deassertion
    always_ff @(posedge clk or negedge rst_n_async) begin
        if (!rst_n_async) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end
        else begin
            sync_ff1 <= 1'b1;
            sync_ff2 <= sync_ff1;
        end
    end

    assign rst_n_sync = sync_ff2;

endmodule : reset_synchronizer
