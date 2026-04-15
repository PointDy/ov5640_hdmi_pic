`timescale 1ns/1ns

module ct_stream_bypass
(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            pixel_valid,
    input   wire    [15:0]  pixel_in,

    output  reg             pixel_valid_out,
    output  reg     [15:0]  pixel_out
);

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        pixel_valid_out <= 1'b0;
        pixel_out       <= 16'd0;
    end
    else
    begin
        pixel_valid_out <= pixel_valid;
        pixel_out       <= pixel_in;
    end
end

endmodule
