`timescale 1ns/1ns

module ct_overlay
#(
    parameter [10:0] FRAME_WIDTH    = 11'd640,
    parameter [10:0] FRAME_HEIGHT   = 11'd480,
    parameter [10:0] CROSS_HALF_LEN = 11'd8
)
(
    input   wire    [10:0]  pixel_x,
    input   wire    [10:0]  pixel_y,
    input   wire    [15:0]  pixel_in,
    input   wire    [10:0]  cross_x,
    input   wire    [10:0]  cross_y,
    input   wire            gate_enable,
    input   wire    [10:0]  gate_left,
    input   wire    [10:0]  gate_right,
    input   wire    [10:0]  gate_top,
    input   wire    [10:0]  gate_bottom,

    output  wire    [15:0]  pixel_out
);

wire cross_h;
wire cross_v;
wire gate_h;
wire gate_v;

assign cross_h = (pixel_y == cross_y)
              && (pixel_x >= cross_x - CROSS_HALF_LEN)
              && (pixel_x <= cross_x + CROSS_HALF_LEN);
assign cross_v = (pixel_x == cross_x)
              && (pixel_y >= cross_y - CROSS_HALF_LEN)
              && (pixel_y <= cross_y + CROSS_HALF_LEN);

assign gate_h  = gate_enable
              && ((pixel_y == gate_top) || (pixel_y == gate_bottom))
              && (pixel_x >= gate_left)
              && (pixel_x <= gate_right);
assign gate_v  = gate_enable
              && ((pixel_x == gate_left) || (pixel_x == gate_right))
              && (pixel_y >= gate_top)
              && (pixel_y <= gate_bottom);

assign pixel_out = (cross_h || cross_v || gate_h || gate_v) ? 16'hFFFF : pixel_in;

endmodule
