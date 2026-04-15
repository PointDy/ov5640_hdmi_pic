`timescale 1ns/1ns

module ct_key_ctrl
#(
    parameter CNT_MAX    = 32'd50_000,
    parameter MS_CNT_MAX = 32'd20
)
(
    input   wire    sys_clk,
    input   wire    sys_rst_n,
    input   wire    track_key,
    input   wire    mode_key,

    output  reg     track_key_flag,
    output  reg     mode_key_flag
);

reg [31:0] track_cnt;
reg [31:0] track_ms_cnt;
reg [31:0] mode_cnt;
reg [31:0] mode_ms_cnt;

always @(posedge sys_clk or negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        track_cnt <= 32'd0;
    else if((track_cnt == CNT_MAX - 32'd1) && (track_key == 1'b0))
        track_cnt <= 32'd0;
    else if(track_key == 1'b0)
        track_cnt <= track_cnt + 32'd1;
    else
        track_cnt <= 32'd0;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        track_ms_cnt <= 32'd0;
    else if(track_key == 1'b1)
        track_ms_cnt <= 32'd0;
    else if((track_cnt == CNT_MAX - 32'd1) && (track_ms_cnt <= MS_CNT_MAX))
        track_ms_cnt <= track_ms_cnt + 32'd1;
    else
        track_ms_cnt <= track_ms_cnt;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        track_key_flag <= 1'b0;
    else if((track_cnt == CNT_MAX - 32'd1) && (track_ms_cnt == MS_CNT_MAX))
        track_key_flag <= 1'b1;
    else
        track_key_flag <= 1'b0;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        mode_cnt <= 32'd0;
    else if((mode_cnt == CNT_MAX - 32'd1) && (mode_key == 1'b0))
        mode_cnt <= 32'd0;
    else if(mode_key == 1'b0)
        mode_cnt <= mode_cnt + 32'd1;
    else
        mode_cnt <= 32'd0;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        mode_ms_cnt <= 32'd0;
    else if(mode_key == 1'b1)
        mode_ms_cnt <= 32'd0;
    else if((mode_cnt == CNT_MAX - 32'd1) && (mode_ms_cnt <= MS_CNT_MAX))
        mode_ms_cnt <= mode_ms_cnt + 32'd1;
    else
        mode_ms_cnt <= mode_ms_cnt;
end

always @(posedge sys_clk or negedge sys_rst_n)
begin
    if(sys_rst_n == 1'b0)
        mode_key_flag <= 1'b0;
    else if((mode_cnt == CNT_MAX - 32'd1) && (mode_ms_cnt == MS_CNT_MAX))
        mode_key_flag <= 1'b1;
    else
        mode_key_flag <= 1'b0;
end

endmodule
