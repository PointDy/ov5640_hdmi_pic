`timescale 1ns/1ns

module ct_mode_mux
(
    input   wire            edge_mode_enable,
    input   wire    [15:0]  pixel_raw,
    input   wire    [15:0]  pixel_edge_overlay,

    output  wire    [15:0]  pixel_out
);

assign pixel_out = edge_mode_enable ? pixel_edge_overlay : pixel_raw;

endmodule
