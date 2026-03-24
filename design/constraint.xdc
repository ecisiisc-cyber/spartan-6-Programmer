set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

#####################################################################
#                          Clock 100 MHz                            #
#####################################################################

set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN F4 [get_ports clk]





create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports target_done]
set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports target_done]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports target_init_b]
set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports target_init_b]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports config_error]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports config_error]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports config_success]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports config_success]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports target_cclk]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports target_cclk]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports target_din]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports target_din]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports target_prog_b]
set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports target_prog_b]
set_property IOSTANDARD LVCMOS33 [get_ports config_error]
set_property IOSTANDARD LVCMOS33 [get_ports config_success]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports target_cclk]
set_property IOSTANDARD LVCMOS33 [get_ports target_din]
set_property IOSTANDARD LVCMOS33 [get_ports target_done]
set_property IOSTANDARD LVCMOS33 [get_ports target_init_b]
set_property IOSTANDARD LVCMOS33 [get_ports target_prog_b]
set_property PACKAGE_PIN D12 [get_ports config_error]
set_property PACKAGE_PIN F13 [get_ports config_success]
set_property PACKAGE_PIN A15 [get_ports rst_n]
set_property PACKAGE_PIN C12 [get_ports target_cclk]
set_property PACKAGE_PIN C11 [get_ports target_din]
set_property PACKAGE_PIN B7 [get_ports target_done]
set_property PACKAGE_PIN A6 [get_ports target_init_b]
set_property PACKAGE_PIN E7 [get_ports target_prog_b]
