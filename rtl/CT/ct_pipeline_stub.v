`timescale 1ns/1ns

module ct_pipeline_stub
#(
    parameter [10:0] FRAME_WIDTH  = 11'd640,
    parameter [10:0] FRAME_HEIGHT = 11'd480
)
(
    input   wire            clk,
    input   wire            rst_n,
    input   wire            frame_start,
    input   wire            pixel_valid,
    input   wire    [15:0]  pixel_in,
    input   wire            track_key_flag,
    input   wire            mode_key_flag,

    output  wire            pixel_valid_out,
    output  wire    [15:0]  pixel_out,
    output  reg             track_enable,
    output  reg             edge_mode_enable,
    output  wire            lock_valid
);

localparam [10:0] CENTER_X = FRAME_WIDTH >> 1;
localparam [10:0] CENTER_Y = FRAME_HEIGHT >> 1;

reg [10:0] pixel_x;
reg [10:0] pixel_y;

wire        bypass_valid;
wire [15:0] bypass_pixel;
wire [10:0] target_x;
wire [10:0] target_y;
wire [10:0] gate_left;
wire [10:0] gate_right;
wire [10:0] gate_top;
wire [10:0] gate_bottom;
wire [15:0] overlay_pixel;

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        pixel_x <= 11'd0;
        pixel_y <= 11'd0;
    end
    else if(frame_start == 1'b1)
    begin
        pixel_x <= 11'd0;
        pixel_y <= 11'd0;
    end
    else if(pixel_valid == 1'b1)
    begin
        if(pixel_x == (FRAME_WIDTH - 11'd1))
        begin
            pixel_x <= 11'd0;
            if(pixel_y == (FRAME_HEIGHT - 11'd1))
                pixel_y <= 11'd0;
            else
                pixel_y <= pixel_y + 11'd1;
        end
        else
            pixel_x <= pixel_x + 11'd1;
    end
end

ct_stream_bypass ct_stream_bypass_inst
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .pixel_valid    (pixel_valid    ),
    .pixel_in       (pixel_in       ),
    .pixel_valid_out(bypass_valid   ),
    .pixel_out      (bypass_pixel   )
);

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        track_enable     <= 1'b0;
        edge_mode_enable <= 1'b0;
    end
    else
    begin
        if(track_key_flag == 1'b1)
            track_enable <= ~track_enable;

        if(mode_key_flag == 1'b1)
            edge_mode_enable <= ~edge_mode_enable;
    end
end

ct_tracker_stub
#(
    .FRAME_WIDTH  (FRAME_WIDTH ),
    .FRAME_HEIGHT (FRAME_HEIGHT)
)
ct_tracker_stub_inst
(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .frame_start (frame_start ),
    .track_enable(track_enable),
    .lock_valid  (lock_valid  ),
    .target_x    (target_x    ),
    .target_y    (target_y    ),
    .gate_left   (gate_left   ),
    .gate_right  (gate_right  ),
    .gate_top    (gate_top    ),
    .gate_bottom (gate_bottom )
);

ct_overlay
#(
    .FRAME_WIDTH  (FRAME_WIDTH ),
    .FRAME_HEIGHT (FRAME_HEIGHT)
)
ct_overlay_inst
(
    .pixel_x    (pixel_x      ),
    .pixel_y    (pixel_y      ),
    .pixel_in   (bypass_pixel ),
    .cross_x    (lock_valid ? target_x : CENTER_X),
    .cross_y    (lock_valid ? target_y : CENTER_Y),
    .gate_enable(lock_valid   ),
    .gate_left  (gate_left    ),
    .gate_right (gate_right   ),
    .gate_top   (gate_top     ),
    .gate_bottom(gate_bottom  ),
    .pixel_out  (overlay_pixel)
);

ct_mode_mux ct_mode_mux_inst
(
    .edge_mode_enable    (edge_mode_enable),
    .pixel_raw           (overlay_pixel    ),
    .pixel_edge_overlay  (overlay_pixel    ),
    .pixel_out           (pixel_out        )
);

assign pixel_valid_out = bypass_valid;

endmodule
