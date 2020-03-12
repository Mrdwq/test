delete_bd_objs -quiet [get_bd_cells -quiet /u96_pl/pr_set_0_1]
delete_bd_objs -quiet [get_bd_cells -quiet /u96_pl/pr_set_0_0]

create_bd_cell -quiet -type hier /u96_pl/pr_set_0_0


set system [get_bd_cell /u96_pl]
create_bd_pin -dir I -type clk /u96_pl/pr_set_0_0/clk_0
create_bd_pin -dir I -type rst /u96_pl/pr_set_0_0/rst_2
create_bd_pin -dir I -type rst /u96_pl/pr_set_0_0/rst_0
create_bd_pin -dir I -type rst /u96_pl/pr_set_0_0/rst_1
create_bd_pin -dir I -type rst /u96_pl/pr_set_0_0/rst_3
create_bd_pin -dir I -type rst /u96_pl/pr_set_0_0/rst_4
create_bd_pin -dir I -type rst /u96_pl/pr_set_0_0/rst_8
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 /u96_pl/pr_set_0_0/common_intf_CTRL
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 /u96_pl/pr_set_0_0/common_intf_M_AXI_1
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 /u96_pl/pr_set_0_0/common_intf_M_AXI_2
create_bd_pin -dir I /u96_pl/pr_set_0_0/decoup_en
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_1
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_2
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_3
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_4
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_5
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_6
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_7
create_bd_pin -dir O /u96_pl/pr_set_0_0/irq_i_8
create_bd_pin -dir I -type clk /u96_pl/pr_set_0_0/clk_5
create_bd_pin -dir I -type clk /u96_pl/pr_set_0_0/clk_6
create_bd_pin -dir I -type clk /u96_pl/pr_set_0_0/clk_7

safe_connect_bd_net /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0 /u96_pl/pr_set_0_0/clk_0
safe_connect_bd_net /p_u96_pl/proc_sys_reset_0/interconnect_aresetn /u96_pl/pr_set_0_0/rst_2
safe_connect_bd_net /p_u96_pl/proc_sys_reset_0/peripheral_aresetn /u96_pl/pr_set_0_0/rst_0
safe_connect_bd_net /p_u96_pl/proc_sys_reset_0/bus_struct_reset /u96_pl/pr_set_0_0/rst_1
safe_connect_bd_net /p_u96_pl/proc_sys_reset_0/mb_reset /u96_pl/pr_set_0_0/rst_3
safe_connect_bd_net /p_u96_pl/proc_sys_reset_0/peripheral_reset /u96_pl/pr_set_0_0/rst_4
safe_connect_bd_net /p_u96_pl/zynq_ultra_ps_e_0/pl_resetn0 /u96_pl/pr_set_0_0/rst_8
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/decoup_en /u96_pl/pr_set_0_0/decoup_en
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_1 /u96_pl/pr_set_0_0/irq_i_1
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_2 /u96_pl/pr_set_0_0/irq_i_2
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_3 /u96_pl/pr_set_0_0/irq_i_3
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_4 /u96_pl/pr_set_0_0/irq_i_4
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_5 /u96_pl/pr_set_0_0/irq_i_5
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_6 /u96_pl/pr_set_0_0/irq_i_6
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_7 /u96_pl/pr_set_0_0/irq_i_7
safe_connect_bd_net /p_u96_pl/vsi_common_interface_0/irq_i_8 /u96_pl/pr_set_0_0/irq_i_8
safe_connect_bd_net /p_u96_pl/zynq_ultra_ps_e_0/pl_clk1 /u96_pl/pr_set_0_0/clk_5
safe_connect_bd_net /p_u96_pl/zynq_ultra_ps_e_0/pl_clk2 /u96_pl/pr_set_0_0/clk_6
safe_connect_bd_net /p_u96_pl/zynq_ultra_ps_e_0/pl_clk3 /u96_pl/pr_set_0_0/clk_7
connect_with_check \
    [ get_bd_intf_pin /p_u96_pl/vsi_common_interface_0/CTRL ] \
    [ get_bd_intf_pin /u96_pl/pr_set_0_0/common_intf_CTRL ]
sys_intf_termination \
    [ get_bd_cells /u96_pl/pr_set_0_0 ] \
    [ get_bd_intf_pin /u96_pl/pr_set_0_0/common_intf_CTRL ]
connect_with_check \
    [ get_bd_intf_pin /p_u96_pl/vsi_common_interface_0/M_AXI_1 ] \
    [ get_bd_intf_pin /u96_pl/pr_set_0_0/common_intf_M_AXI_1 ]
sys_intf_termination \
    [ get_bd_cells /u96_pl/pr_set_0_0 ] \
    [ get_bd_intf_pin /u96_pl/pr_set_0_0/common_intf_M_AXI_1 ]
connect_with_check \
    [ get_bd_intf_pin /p_u96_pl/vsi_common_interface_0/M_AXI_2 ] \
    [ get_bd_intf_pin /u96_pl/pr_set_0_0/common_intf_M_AXI_2 ]
sys_intf_termination \
    [ get_bd_cells /u96_pl/pr_set_0_0 ] \
    [ get_bd_intf_pin /u96_pl/pr_set_0_0/common_intf_M_AXI_2 ]

# ---------------------------- Place RTL IP's start ----------------------------




# ----------------------------- Place RTL IP's end -----------------------------
# ----------------------- Place HLS Wizard blocks start ------------------------
		# Place Wizard: u96_pl/pr_set_0_0/min_max
set placed_cell [create_bd_cell -type ip -vlnv vsi.com:hls:min_max_shmem:1.0 /u96_pl/pr_set_0_0/min_max]

set ap_c [create_bd_cell -type ip -vlnv vsi.com:ip:vsi_hls_control /u96_pl/pr_set_0_0/ap_c_min_max ]
puts "1584011808.9007342"
set_property -dict [list \
	CONFIG.NUM_PARAMS {1} \
	CONFIG.C_AP_START_NONE {0} \
	CONFIG.C_AP_START_TIMER {0} \
	CONFIG.P00_param_dir {1} \
	CONFIG.P00_param_access {1} \
	] $ap_c
puts "1584011808.9008029"
vsi::connect_bd_net [get_bd_pin ${ap_c}/ap_clk] [get_bd_pin /u96_pl/pr_set_0_0/min_max/ap_clk]
vsi::connect_bd_net [get_bd_pin ${ap_c}/ap_resetn] [get_bd_pin /u96_pl/pr_set_0_0/min_max/ap_rst_n]
#connect_bd_intf_net [get_bd_intf_pin ${ap_c}/ap_control] [get_bd_intf_pin /u96_pl/pr_set_0_0/min_max/ap_ctrl]
connect_bd_net [get_bd_pins ${ap_c}/ap_start] [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_start]
connect_bd_net [get_bd_pins ${ap_c}/ap_done] [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_done]
connect_bd_net [get_bd_pins ${ap_c}/ap_idle] [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_idle]

set this_intf [get_hls_intf /u96_pl/pr_set_0_0/min_max done]
set this_intf [get_hls_intf /u96_pl/pr_set_0_0/min_max io_frame]
puts "1584011808.901044"
set oc [create_bd_cell -type ip -vlnv vsi.com:ip:hls_interrupt /u96_pl/pr_set_0_0/oc_min_max_io_frame]
set_property CONFIG.param_access 3 $oc
#connect_bd_intf_net [get_bd_intf_pin ${oc}/ap]  [get_bd_intf_pin /u96_pl/pr_set_0_0/min_max/ap_ctrl]
connect_bd_net [get_bd_pins ${oc}/ap_start] [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_start]
connect_bd_net [get_bd_pins ${oc}/ap_done] [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_done]
connect_bd_net [get_bd_pins ${oc}/ap_idle] [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_idle]
vsi::connect_bd_net [get_bd_pin ${oc}/ap_clk] [get_bd_pin /u96_pl/pr_set_0_0/min_max/ap_clk]
vsi::connect_bd_net [get_bd_pin ${oc}/ap_rst_n] [get_bd_pin /u96_pl/pr_set_0_0/min_max/ap_rst_n]
set this_intf [get_hls_intf /u96_pl/pr_set_0_0/min_max start]
connect_bd_intf_net [get_bd_intf_pins ${ap_c}/S0_AXIS] $this_intf
puts "1584011808.901211"
set_property CONFIG.C_S0_AXI_DATA_WIDTH [expr 8 * [get_property CONFIG.TDATA_NUM_BYTES $this_intf]] [get_bd_cells ${ap_c}]





# ------------------------ Place HLS Wizard blocks end -------------------------
# ----------------------------- Connect pins start -----------------------------
# vsi_system/u96_pl/pr_set_0_0/min_max Clock list:
connect_bd_net \
    [get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0] \
    [get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_clk]





# ------------------------------ Connect pins end ------------------------------
# ----------------------  Place adapters interfaces start ----------------------
# ..............................................................................
# Interface addapter handle for : 
#     vsi_system/u96_pl/pr_set_0_0/min_max/done
# ..............................................................................

create_bd_cell -type ip -vlnv vsi.com:ip:vsi_axi_fifo_mm_s /u96_pl/pr_set_0_0/s2mm_min_max_done
set_property -dict [list \
	CONFIG.C_USE_RX_DATA {1} \
	CONFIG.C_USE_TX_DATA {1} \
	CONFIG.C_USE_TX_CTRL {0} \
	CONFIG.C_DATA_INTERFACE_TYPE {1} \
	CONFIG.C_HAS_AXIS_TKEEP {True} \
	CONFIG.C_USE_RX_CUT_THROUGH {False} \
	CONFIG.C_S_AXI4_DATA_WIDTH {64} \
	CONFIG.C_AXIS_TUSER_WIDTH {8} \
	CONFIG.C_RX_FIFO_DEPTH {512} \
	CONFIG.C_RX_FIFO_PF_THRESHOLD {256} \
	CONFIG.C_S_AXI_ADDR_WIDTH {8} \
] [get_bd_cell /u96_pl/pr_set_0_0/s2mm_min_max_done]
set data_intf [get_bd_intf_pin /u96_pl/pr_set_0_0/s2mm_min_max_done/S_AXI_FULL]
set control_intf [get_bd_intf_pin /u96_pl/pr_set_0_0/s2mm_min_max_done/S_AXI]
apply_connection /p_u96_pl/vsi_common_interface_0/M_AXI_1 $data_intf ${system}
apply_connection /p_u96_pl/vsi_common_interface_0/CTRL $control_intf ${system}
vsi_add_regslice $control_intf

set src_axis [get_hls_intf /u96_pl/pr_set_0_0/min_max done]
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect /u96_pl/pr_set_0_0/dwc_min_max_done
set_property -dict [list CONFIG.NUM_MI {1} ] [get_bd_cell /u96_pl/pr_set_0_0/dwc_min_max_done]
# Fifo mode: last.
set_property -dict [list CONFIG.M00_FIFO_MODE {1} CONFIG.S00_FIFO_MODE {1} ] [get_bd_cell /u96_pl/pr_set_0_0/dwc_min_max_done]
# Update tuser bit width
set d_tuserw [get_property CONFIG.TUSER_WIDTH $src_axis]
set d_tdataw [get_property CONFIG.C_AXIS_TUSER_WIDTH $src_axis]
if {$d_tuserw != "" && $d_tuserw != "0"} {
	set_property -dict [list CONFIG.C_HAS_AXIS_TUSER {true}] [get_bd_cell /u96_pl/pr_set_0_0/s2mm_min_max_done]
}
connect_bd_intf_net [get_bd_intf_pin /u96_pl/pr_set_0_0/s2mm_min_max_done/AXI_STR_RXD] [get_bd_intf_pin /u96_pl/pr_set_0_0/dwc_min_max_done/M00_AXIS]
connect_bd_intf_net [get_bd_intf_pin /u96_pl/pr_set_0_0/dwc_min_max_done/S00_AXIS] $src_axis

puts "1584011808.9027264"
puts "#0x9d344a08"


safe_connect_bd_net -quiet \
        [get_bd_pins /u96_pl/pr_set_0_0/s2mm_min_max_done/s_axi_aclk] \
        [get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0]
safe_connect_bd_net [get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_done/M00_AXIS_ACLK] \
        [get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0]
safe_connect_bd_net [get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_done/ACLK] \
        [get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0]

safe_connect_bd_net -quiet \
	[get_bd_pins /u96_pl/pr_set_0_0/s2mm_min_max_done/s_axi_aresetn] \
	[get_bd_pins /p_u96_pl/proc_sys_reset_0/peripheral_aresetn]
safe_connect_bd_net [get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_done/M00_AXIS_ARESETN] \
	[get_bd_pins /p_u96_pl/proc_sys_reset_0/peripheral_aresetn]
safe_connect_bd_net [get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_done/ARESETN] \
	[get_bd_pins /p_u96_pl/proc_sys_reset_0/peripheral_aresetn]

safe_connect_bd_net -quiet \
	[get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0] \
	[get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_done/S00_AXIS_ACLK]

safe_connect_bd_net -quiet \
	[get_bd_pins /p_u96_pl/proc_sys_reset_0/peripheral_aresetn] \
	[get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_done/S00_AXIS_ARESETN]

safe_connect_bd_net \
	[get_bd_pins /u96_pl/pr_set_0_0/s2mm_min_max_done/interrupt] \
	[get_bd_pins /p_u96_pl/vsi_common_interface_0/irq_i_3]



set fifo [get_bd_cell /u96_pl/pr_set_0_0/s2mm_min_max_done]
	puts "/u96_pl/pr_set_0_0/s2mm_min_max_done"
# Set data memory sets
	 set slave_interface [get_hls_intf ${fifo} S_AXI_FULL]
assign_bd_address -quiet [get_bd_addr_seg -of_objects ${slave_interface}]
assign_bd_address -quiet -offset 0x200000000 -range 0x10000 [get_bd_addr_seg -of_objects ${slave_interface}]
include_bd_addr_seg -quiet [get_bd_addr_seg -excluded -of [get_bd_addr_seg -of_objects ${slave_interface}] ]
set_property range 0x1000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property offset 0x200000000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property range  0x10000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]

# Set controll memory sets
	 set slave_interface [get_control_hls ${fifo} S_AXI]
assign_bd_address -quiet [get_bd_addr_seg -of_objects ${slave_interface}]
assign_bd_address -quiet -offset 0x88020000 -range 0x10000 [get_bd_addr_seg -of_objects ${slave_interface}]
include_bd_addr_seg -quiet [get_bd_addr_seg -excluded -of [get_bd_addr_seg -of_objects ${slave_interface}] ]
set_property range 0x1000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property offset 0x88020000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property range  0x10000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]

# Vivado bug workaround
set_property -dict [list CONFIG.C_AXI4_BASEADDR 0x00000000 CONFIG.C_AXI4_HIGHADDR 0x0000FFFF CONFIG.C_BASEADDR {0x88020000} CONFIG.C_HIGHADDR {0x8802FFFF}] ${fifo}


 
# ..............................................................................
# Interface addapter handle for : 
#     vsi_system/u96_pl/pr_set_0_0/min_max/io_frame
# ..............................................................................
# MM2MM no needed extra converters aximm_to_aximm.
 
# ..............................................................................
# Interface addapter handle for : 
#     vsi_system/u96_pl/pr_set_0_0/min_max/start
# ..............................................................................

set mm2s [create_bd_cell -type ip -vlnv vsi.com:ip:vsi_axi_fifo_mm_s /u96_pl/pr_set_0_0/mm2s_min_max_start]
set_property -dict [list \
	CONFIG.C_USE_RX_DATA {1} \
	CONFIG.C_USE_TX_DATA {1} \
	CONFIG.C_USE_TX_CTRL {0} \
	CONFIG.C_DATA_INTERFACE_TYPE {1} \
	CONFIG.C_HAS_AXIS_TKEEP {true} \
	CONFIG.C_S_AXI_ADDR_WIDTH {8} \
	CONFIG.C_S_AXI4_DATA_WIDTH {64} \
	CONFIG.C_AXIS_TUSER_WIDTH {8} \
	CONFIG.C_TX_FIFO_DEPTH {512} \
] $mm2s

set data_intf [get_bd_intf_pins -quiet ${mm2s}/S_AXI_FULL]
set control_intf [get_bd_intf_pins -quiet ${mm2s}/S_AXI]
safe_connect_bd_net \
	[get_bd_pins ${mm2s}/s_axi_aclk] \
	[get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0]
safe_connect_bd_net \
	[get_bd_pins ${mm2s}/s_axi_aresetn] \
	[get_bd_pins /p_u96_pl/proc_sys_reset_0/peripheral_aresetn]

puts "1584011808.9041266"
apply_connection /p_u96_pl/vsi_common_interface_0/M_AXI_2 $data_intf ${system}
apply_connection /p_u96_pl/vsi_common_interface_0/CTRL $control_intf ${system}
vsi_add_regslice $control_intf
set dest_axis [get_hls_intf /u96_pl/pr_set_0_0/min_max start]
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect /u96_pl/pr_set_0_0/dwc_min_max_start
set_property -dict [list CONFIG.NUM_MI {1} ] [get_bd_cell /u96_pl/pr_set_0_0/dwc_min_max_start]

puts "1584011808.9043303"
connect_bd_intf_net [get_bd_intf_pin ${mm2s}/AXI_STR_TXD] [get_bd_intf_pin /u96_pl/pr_set_0_0/dwc_min_max_start/S00_AXIS]
safe_connect_bd_net [get_bd_pin ${mm2s}/s_axi_aclk] [get_bd_pin /u96_pl/pr_set_0_0/dwc_min_max_start/S00_AXIS_ACLK]
safe_connect_bd_net [get_bd_pin ${mm2s}/s_axi_aresetn] [get_bd_pin /u96_pl/pr_set_0_0/dwc_min_max_start/S00_AXIS_ARESETN]
safe_connect_bd_net [get_bd_pin ${mm2s}/s_axi_aclk] [get_bd_pin /u96_pl/pr_set_0_0/dwc_min_max_start/ACLK]
safe_connect_bd_net [get_bd_pin ${mm2s}/s_axi_aresetn] [get_bd_pin /u96_pl/pr_set_0_0/dwc_min_max_start/ARESETN]

puts "1584011808.904581"
puts "#0x9b225c40"
safe_connect_bd_net -quiet \
	[get_bd_pins ${mm2s}/s_axi_aclk] \
	[get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_clk]
safe_connect_bd_net -quiet \
	[get_bd_pins ${mm2s}/s_axi_aresetn] \
	[get_bd_pins /u96_pl/pr_set_0_0/min_max/ap_rst_n]

connect_bd_intf_net [get_bd_intf_pin /u96_pl/pr_set_0_0/dwc_min_max_start/M00_AXIS] $dest_axis


safe_connect_bd_net -quiet \
	[get_bd_pins /p_u96_pl/zynq_ultra_ps_e_0/pl_clk0] \
	[get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_start/M00_AXIS_ACLK]

safe_connect_bd_net -quiet \
	[get_bd_pins /p_u96_pl/proc_sys_reset_0/peripheral_aresetn] \
	[get_bd_pins /u96_pl/pr_set_0_0/dwc_min_max_start/M00_AXIS_ARESETN]

# if destination does not have TLAST then set cut-through mode
set d_tlast [get_property CONFIG.HAS_TLAST $dest_axis]
if {$d_tlast != "1"} { set_property -dict [list CONFIG.C_USE_TX_CUT_THROUGH {1}] $mm2s }


set fifo [get_bd_cell /u96_pl/pr_set_0_0/mm2s_min_max_start]
	puts "/u96_pl/pr_set_0_0/mm2s_min_max_start"
# Set data memory sets
	 set slave_interface [get_hls_intf ${fifo} S_AXI_FULL]
assign_bd_address -quiet [get_bd_addr_seg -of_objects ${slave_interface}]
assign_bd_address -quiet -offset 0x300000000 -range 0x10000 [get_bd_addr_seg -of_objects ${slave_interface}]
include_bd_addr_seg -quiet [get_bd_addr_seg -excluded -of [get_bd_addr_seg -of_objects ${slave_interface}] ]
set_property range 0x1000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property offset 0x300000000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property range  0x10000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]

# Set controll memory sets
	 set slave_interface [get_control_hls ${fifo} S_AXI]
assign_bd_address -quiet [get_bd_addr_seg -of_objects ${slave_interface}]
assign_bd_address -quiet -offset 0x88030000 -range 0x10000 [get_bd_addr_seg -of_objects ${slave_interface}]
include_bd_addr_seg -quiet [get_bd_addr_seg -excluded -of [get_bd_addr_seg -of_objects ${slave_interface}] ]
set_property range 0x1000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property offset 0x88030000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property range  0x10000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]

# Vivado bug workaround
set_property -dict [list CONFIG.C_AXI4_BASEADDR 0x00000000 CONFIG.C_AXI4_HIGHADDR 0x0000FFFF CONFIG.C_BASEADDR {0x88030000} CONFIG.C_HIGHADDR {0x8803FFFF}] ${fifo}


 











# -----------------------  Place adapters interfaces end -----------------------
# -----  Place pass through interfaces ad, target_pr_hierarcyapters start ------

# ----------------  Place pass through interfaces adapters end -----------------
# -------------------------- connect_interfaces start --------------------------
# ..............................................................................
# Handle interface connection : 
#     vsi_system/u96_pl/pr_set_0_0/min_max/done
# ..............................................................................
	

# ..............................................................................
# Handle interface connection : 
#     vsi_system/u96_pl/pr_set_0_0/min_max/io_frame
# ..............................................................................
	
puts "1584011808.906007"


apply_connection \
	[get_hls_intf /p_u96_pl/vsi_common_interface_0 S_AXI_0]\
	[get_hls_intf /u96_pl/pr_set_0_0/min_max io_frame] ${system}
set cell_path /p_u96_pl/vsi_common_interface_0
 set slave_interface [get_hls_intf ${cell_path} S_AXI_0]
assign_bd_address -quiet [get_bd_addr_seg -of_objects ${slave_interface}]
assign_bd_address -quiet -offset 0x0 -range 0x100000000 [get_bd_addr_seg -of_objects ${slave_interface}]
include_bd_addr_seg -quiet [get_bd_addr_seg -excluded -of [get_bd_addr_seg -of_objects ${slave_interface}] ]
set_property range 0x1000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property offset 0x0 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property range  0x100000000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]


puts "1584011808.9062266"


apply_connection \
	[get_control_hls /p_u96_pl/vsi_common_interface_0 CTRL]\
	[get_control_hls /u96_pl/pr_set_0_0/min_max io_frame] ${system}
set cell_path /u96_pl/pr_set_0_0/min_max
 set slave_interface [get_control_hls ${cell_path} io_frame]
assign_bd_address -quiet [get_bd_addr_seg -of_objects ${slave_interface}]
assign_bd_address -quiet -offset 0x88000000 -range 0x10000 [get_bd_addr_seg -of_objects ${slave_interface}]
include_bd_addr_seg -quiet [get_bd_addr_seg -excluded -of [get_bd_addr_seg -of_objects ${slave_interface}] ]
set_property range 0x1000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property offset 0x88000000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]
set_property range  0x10000 [get_bd_addr_seg -of_objects [get_bd_addr_seg -of_objects ${slave_interface}]]



# ..............................................................................
# Handle interface connection : 
#     vsi_system/u96_pl/pr_set_0_0/min_max/start
# ..............................................................................
	












# --------------------------- connect_interfaces end ---------------------------
# -------------------- Connect passthrough interfaces start --------------------

# -------------------------- Connect passthrough end ---------------------------
# -------------------------- Traces maintenance start --------------------------

# --------------------------- Traces maintenance end ---------------------------

