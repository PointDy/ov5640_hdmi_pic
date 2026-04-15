# =========================================================
# 1. 约束物理输入主时钟 (Base Clocks)
# =========================================================
# 50MHz 系统主晶振
create_clock -name sys_clk -period 20.000 [get_ports {sys_clk}]

# ~24MHz 摄像头像素时钟
create_clock -name ov5640_pclk -period 41.666 [get_ports {ov5640_pclk}]

# 50MHz 以太网 PHY 提供的主时钟 (注意检查你的顶层端口名是 eth_clk 还是 eth_rmii_clk)
create_clock -name eth_clk -period 20.000 [get_ports {eth_clk}]


# =========================================================
# 2. 约束代码翻转生成的时钟 (Generated Clock) - 【核心新增】
# =========================================================
# 告诉编译器：mii_clk 是由 eth_clk 二分频得来的。
# ⚠️ 注意：[get_registers {mii_clk}] 里的名字必须是你代码里那个翻转寄存器的真实名字！
# 如果你在 eth_imp.v 顶层里写的是 reg mii_clk; 则写 {mii_clk} 或 {mii_clk~reg0}。


# =========================================================
# 3. 自动推导 PLL 时钟与时钟抖动 (PLLs & Uncertainty)
# =========================================================
derive_pll_clocks
derive_clock_uncertainty


# =========================================================
# 4. 划分异步时钟域 (Asynchronous Clock Groups)
# =========================================================
# 将三大时钟源彻底隔离开，避免跨时钟域的 FIFO 连线报错。
# 注意：eth_clk 和它衍生出的 mii_clk 属于同一个 Group（同源）。
set_clock_groups -asynchronous \
    -group { \
        sys_clk \
        clk_gen_inst|altpll_component|auto_generated|pll1|clk[0] \
        clk_gen_inst|altpll_component|auto_generated|pll1|clk[1] \
        clk_gen_inst|altpll_component|auto_generated|pll1|clk[2] \
    } \
    -group {ov5640_pclk} \
    -group {eth_clk}