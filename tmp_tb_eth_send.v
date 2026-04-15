`timescale 1ns/1ns

module tmp_tb_eth_send;

reg         clk;
reg         rst_n;
reg         clk_en;
wire        send_en;
wire [31:0] send_data;
wire [15:0] send_data_num;
wire        format_done;
wire        read_data_req;
wire        send_end;
wire        eth_tx_en;
wire [3:0]  eth_tx_data;
wire        crc_en;
wire        crc_clr;
wire [31:0] crc_data;
wire [31:0] crc_next;

initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        clk_en <= 1'b0;
    else
        clk_en <= ~clk_en;
end

initial begin
    rst_n = 1'b0;
    clk_en = 1'b0;
    #100;
    rst_n = 1'b1;
    #20000;
    $finish;
end

packet_format u_packet_format (
    .eth_clk(clk),
    .eth_clk_ce(clk_en),
    .sys_rst_n(rst_n),
    .read_data_req(read_data_req),
    .send_end(send_end),
    .send_en(send_en),
    .send_data(send_data),
    .send_data_num(send_data_num),
    .format_done(format_done)
);

ip_send u_ip_send (
    .sys_clk(clk),
    .clk_en(clk_en),
    .sys_rst_n(rst_n),
    .send_en(send_en),
    .send_data(send_data),
    .send_data_num(send_data_num),
    .crc_data(crc_data),
    .crc_next(crc_next[31:28]),
    .send_end(send_end),
    .read_data_req(read_data_req),
    .eth_tx_en(eth_tx_en),
    .eth_tx_data(eth_tx_data),
    .crc_en(crc_en),
    .crc_clr(crc_clr)
);

crc32_d4 u_crc32 (
    .sys_clk(clk),
    .clk_en(clk_en),
    .sys_rst_n(rst_n),
    .data(eth_tx_data),
    .crc_en(crc_en),
    .crc_clr(crc_clr),
    .crc_data(crc_data),
    .crc_next(crc_next)
);

always @(posedge clk) begin
    if(rst_n) begin
        if(send_en)
            $display("%0t send_en", $time);
        if(read_data_req)
            $display("%0t read_data_req data=%h", $time, send_data);
        if(eth_tx_en)
            $display("%0t eth_tx_en tx=%h", $time, eth_tx_data);
        if(send_end)
            $display("%0t send_end", $time);
    end
end

endmodule
