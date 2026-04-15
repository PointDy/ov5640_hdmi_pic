`timescale 1ns/1ns

module ct_tracker_stub
#(
    parameter [10:0] FRAME_WIDTH  = 11'd640,
    parameter [10:0] FRAME_HEIGHT = 11'd480,
    parameter [10:0] GATE_HALF_W  = 11'd20,
    parameter [10:0] GATE_HALF_H  = 11'd20
)
(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            frame_start,
    input   wire            track_enable,

    output  reg             lock_valid,
    output  reg     [10:0]  target_x,
    output  reg     [10:0]  target_y,
    output  reg     [10:0]  gate_left,
    output  reg     [10:0]  gate_right,
    output  reg     [10:0]  gate_top,
    output  reg     [10:0]  gate_bottom
);

localparam [10:0] CENTER_X = FRAME_WIDTH >> 1;
localparam [10:0] CENTER_Y = FRAME_HEIGHT >> 1;

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        lock_valid   <= 1'b0;
        target_x     <= CENTER_X;
        target_y     <= CENTER_Y;
        gate_left    <= CENTER_X - GATE_HALF_W;
        gate_right   <= CENTER_X + GATE_HALF_W;
        gate_top     <= CENTER_Y - GATE_HALF_H;
        gate_bottom  <= CENTER_Y + GATE_HALF_H;
    end
    else if(frame_start == 1'b1)
    begin
        lock_valid   <= track_enable;
        target_x     <= CENTER_X;
        target_y     <= CENTER_Y;
        gate_left    <= CENTER_X - GATE_HALF_W;
        gate_right   <= CENTER_X + GATE_HALF_W;
        gate_top     <= CENTER_Y - GATE_HALF_H;
        gate_bottom  <= CENTER_Y + GATE_HALF_H;
    end
end

endmodule
