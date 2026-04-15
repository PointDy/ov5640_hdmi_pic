create_clock -name sys_clk -period 20.000 [get_ports {sys_clk}]
create_clock -name ov5640_pclk -period 41.666 [get_ports {ov5640_pclk}]
create_clock -name eth_clk -period 20.000 [get_ports {eth_clk}]

derive_pll_clocks
derive_clock_uncertainty

create_generated_clock -name mii_clk \
    -source [get_ports {eth_clk}] \
    -divide_by 2 \
    [get_pins {*|mii_clk~q}]

set_clock_groups -asynchronous \
    -group {sys_clk clk_gen_inst|altpll_component|auto_generated|pll1|clk[0] clk_gen_inst|altpll_component|auto_generated|pll1|clk[1] clk_gen_inst|altpll_component|auto_generated|pll1|clk[2]} \
    -group {ov5640_pclk} \
    -group {eth_clk mii_clk}
