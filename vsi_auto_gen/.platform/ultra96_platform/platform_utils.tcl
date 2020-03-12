###############################################################################
##
## (c) Copyright 2015-2018 System View Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of System View Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith.
##
## CRITICAL APPLICATIONS
## System View products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of System View products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
###############################################################################

namespace eval vsi::aie {}
namespace eval vsi::utils {}

# Using of default interconnector only if wasn't predefined it previews.
if { [info proc intc_vlnv_type] == "" } {
# ------------------------------------------------------------------------------
# intc_vlnv_type -- get interconect VLNV
# ------------------------------------------------------------------------------
  proc intc_vlnv_type { {interface ""} } {
    if { [is_axi_stream ${interface}] } {
      return "xilinx.com:ip:axis_interconnect"
    }
    return "xilinx.com:ip:smartconnect"
  }
}

# ------------------------------------------------------------------------------
# memory_generator_vlnv_type -- vlnv of memory block based on project type
# ------------------------------------------------------------------------------
proc memory_generator_vlnv_type { } {
  if { [is_versal] } {
    return "xilinx.com:ip:emb_mem_gen"
  }
  return "xilinx.com:ip:blk_mem_gen"
}

# ------------------------------------------------------------------------------
# is_versal -- check if current project part is versa
# ------------------------------------------------------------------------------
proc is_versal { } {
	set part [get_property part [get_projects]]
	set C_FAMILY [get_property -q C_FAMILY [get_parts ${part}]]
	# Use smart connector only for versal
	if { ${C_FAMILY} == "versal" } {
		return true
	}
  return false
}

# ------------------------------------------------------------------------------
# vsi_add_regslice --
# add register slice to a given axi master port of an interconnect
# cannot have hierarchy n between them
# ------------------------------------------------------------------------------
proc vsi_add_regslice {slave} {
  set dest_ipin [find_bd_objs \
    -relation connected_to -thru_hier -stop_at_interconnect $slave]
  if {$dest_ipin == ""} return;
  if {[get_property mode $dest_ipin] != "Master"} return;
  set dp_block [get_bd_cells -quiet -of $dest_ipin]
  if {$dp_block == ""} return;
  set dpb_vlnv [get_property vlnv $dp_block]
  if {[regexp "(.*):(.*):(.*):(.*)" $dpb_vlnv vv i_vendor i_lib i_name i_ver]} {
    if {$i_name  == "axi_interconnect"} {
      set dip_name [get_property name $dest_ipin]
      if {[regexp "(.*)_(.*)" $dip_name vv port type]} {
        set_property CONFIG.${port}_HAS_REGSLICE 1 $dp_block
      }
    }
  } else {
    return;
  }
}

# ------------------------------------------------------------------------------
# connect_open --
# Connect the port to the destination if it is not connected
# ------------------------------------------------------------------------------
proc connect_open {args} {
  set port [lindex $args 0]
  set currentconnect [find_bd_objs -rela CONNECTED_TO \
      -thru_hier [get_bd_ports $port]]
  set lpin_path [lrange $args 1 end]

  foreach pin_path $lpin_path {
    set target_port [get_bd_ports -quiet $port]
    set destination_pin [get_bd_pins -quiet $pin_path]
    connect_bd_net -quiet ${target_port} ${destination_pin}
  }
}

# connect pins, excluding pin who already has connection
#  *only for pins axi should has another logic !!
proc safe_connect_bd_net {args} {
  set lpin [flatten ${args}]
  set lpin [split ${lpin}]
  # remove "-quiet" argument needed for compatible with originalfunction
  set quiet_pos [lsearch ${lpin} "-quiet"]
  set lpin [lreplace ${lpin} ${quiet_pos} ${quiet_pos}]
  set lpin [flatten ${lpin}]
  set inputs [get_bd_pins -quiet ${lpin} -filter "DIR=~I"]
  set outputs [get_bd_pins -quiet ${lpin} -filter "DIR=~O"]

  set sourcepin [lindex ${outputs} 0]
  set pinlist ${sourcepin}
  set driven_by_list ""
  if {${sourcepin} != ""} {
    set driven_by_list [split [flatten $outputs]]
  }

  foreach inputspin ${inputs} {
    set driven_by [find_bd_objs -relation connected_to ${inputspin} -thru_hier]
    if {${driven_by} != "" && [lsearch ${driven_by_list} ${driven_by}] == -1} {
      lappend driven_by_list [flatten $driven_by]
    }
  }

  if { [llength ${driven_by_list}] > 1} {
    bd::send_msg -of [get_bd_cells /] \
        -type CRITICAL_WARNING -msg_id {142} \
        -text "Multiple drivers cannot be connected: \
               \n\t[join ${driven_by_list} \n\t]"
  }

  foreach inputspin ${inputs} {
    set driven_by [find_bd_objs -relation connected_to ${inputspin} -thru_hier]
    # if no driven pin founded for current pin list and current pin has it -
    #   add that pin to list and exclude another pin who already has it
    if { ${driven_by} == ""} {
      lappend pinlist ${inputspin}
    } elseif { ${sourcepin} == "" && ${driven_by} != ""} {
      set sourcepin ${driven_by}
      lappend pinlist ${inputspin}
    } elseif { [lsearch ${driven_by_list} ${driven_by}] == -1 } {
      highlight_objects -color red $inputs
      bd::send_msg -of [get_bd_cells /] \
        -type CRITICAL_WARNING -msg_id {142} \
        -text "\tPin ${inputspin} cannot be connected because \
                 connected to source: ${driven_by}"
    }
  }
  vsi::connect_bd_net -quiet [get_bd_pins -quiet $pinlist] -boundary_type upper
}
# ------------------------------------------------------------------------------
# get_hls_intf --
# Get hls interface
# ------------------------------------------------------------------------------
proc get_hls_intf {block intf {hier ""}} {
  set lIntfName [list \
    ${block}/${intf} \
    ${block}/m_axi_${intf} \
    ${block}/${intf}_V_V \
    ${block}/${intf}_V \
    ${block}/${intf}_r \
    ${block}/${intf}_V_data_V \
    ${block}/${intf}_PORTA \
    ${block}/${intf}_r_PORTA \
    ${block}/${intf}_V_PORTA \
    ${block}/m_axi_${intf}_V \
    ${block}/m_axi_${intf}_p \
    ${block}/m_axi_${intf}_r \
    ${block}/m_axi_${intf}_V \
    ${block}/s_axi_${intf} \
    ${block}/m_axi_gmem \
  ]

  foreach intfName ${lIntfName} {
    set ret_intf [get_bd_intf_pins ${intfName}]
    if {$ret_intf != ""} { return ${ret_intf} }
  }
  error "Interface ${block} ${intf} not found"
}

# ------------------------------------------------------------------------------
# get_control_hls --
# Proc to get control port (AXILITE) of a wizar
# ------------------------------------------------------------------------------
proc get_control_hls { block intf } {
  set lIntfName [list \
    ${block}/m_axi_AXILiteS \
    ${block}/s_axi_AXILiteS \
    ${block}/s_axi_CONTROL_BUS \
    ${block}/${intf} \
  ]

  foreach intfName ${lIntfName} {
    set ret_intf [get_bd_intf_pins ${intfName}]
    if {$ret_intf != ""} { return ${ret_intf} }
  }
  error "Interface ${block} ${intf} not found"
}

#-------------------------------------------------------------------------------
# get_ip_name --
# Get ip name that corresponds to the current Vivado version
#-------------------------------------------------------------------------------
proc get_ip_name {lip} {
  foreach ip $lip {
    set ipvlnv [get_ipdefs -filter NAME=~$ip]
    if {[llength $ipvlnv]} {
      set ip_model [get_property MODEL_NAME  $ipvlnv]
      set ip_revision [get_property CORE_REVISION  $ipvlnv]
      set name_el_lib "$ip_model\_$ip_revision"
      lappend cur_name $name_el_lib
    }
  }
  if {[info exists cur_name]} {
    return $cur_name
  }
  return ""
}

# ------------------------------------------------------------------------------
# intc_clk_rst_connect --
# ------------------------------------------------------------------------------
proc intc_clk_rst_connect {intf_pin {dest_intc_intf ""}} {
  # try to propagate clk/rst only if connection between ip and interconnect
  #   in case if interconnect interface not defined use this function to connect
  #   control clk/rst of interconnector to clk/rst of intf_pin
  if {${dest_intc_intf} != ""} {
    intf_to_intf_rst_clk_connect ${intf_pin} ${dest_intc_intf}
  } else {
    set dest_intc_intf ${intf_pin}
  }

  set clk_pin [associated_pin ${intf_pin} clk]
  set reset_pin [associated_pin ${intf_pin} RESET]
  set dest_intc [get_bd_cells -quiet -of_objects ${dest_intc_intf}]
  if {![is_interconnect $dest_intc]} {
    return
  }

  set intc_xbar_clk [xbar_clk_of_intc ${dest_intc}]
  set intc_xbar_rst [xbar_rst_of_intc ${dest_intc}]
  # try to connect only if both exist
  if {[llength ${intc_xbar_clk}] && [llength ${clk_pin}]} {
    safe_connect_bd_net ${intc_xbar_clk} ${clk_pin}
  }
  if {[llength ${intc_xbar_rst}] && [llength ${reset_pin}]} {
    safe_connect_bd_net ${intc_xbar_rst} ${reset_pin}
  }
}

# ------------------------------------------------------------------------------
# intf_clk_rst_propag_connect -- function to connect clk(s)/reset(s)
#   based on interface propagation
# ------------------------------------------------------------------------------
proc intf_clk_rst_propag_connect {intf} {
  set connected_to_intf [find_practical_connect ${intf}]
  if {${connected_to_intf} != ""} {
    set connected_to_intf [lindex ${connected_to_intf} 0]
    intf_to_intf_rst_clk_connect ${intf} ${connected_to_intf}
  }
}

# intf_to_intf_rst_clk_connect -- soft connection of clk/rst for interfaces
proc intf_to_intf_rst_clk_connect {target_intf dest_intf} {
  set dest_intf [get_bd_intf_pins ${dest_intf}]
  set target_intf [get_bd_intf_pins ${target_intf}]
  set dest_cell [par_cell ${dest_intf}]
  if { [is_smart_interconnect ${dest_cell}] } {
     set dest_clk_pin [first_open_clk ${dest_cell}]
  } else {
    set dest_clk_pin [associated_pin ${dest_intf} clk]
  }
  set dest_rst_pin [associated_pin ${dest_intf} RESET]

  set target_cell [par_cell ${target_intf}]
  if { [is_smart_interconnect ${target_cell}] } {
     set target_clk_pin [first_open_clk ${target_cell}]
  } else {
    set target_clk_pin [associated_pin ${target_intf} clk]
  }
  set target_rst_pin [associated_pin ${target_intf} RESET]

  safe_connect_bd_net $target_clk_pin $dest_clk_pin
  safe_connect_bd_net $target_rst_pin $dest_rst_pin
}

# ------------------------------------------------------------------------------
# which_slave -- Get slave interface 
# ------------------------------------------------------------------------------
proc which_slave { pin_a pin_b } {
  if { [is_master $pin_b] && [is_slave $pin_a] } {
    return $pin_a
  } elseif { [is_master $pin_a] && [is_slave $pin_b] } {
    return $pin_a
  } else {
    error "No Slave interface pins in: $pin_a \n $pin_b "
  }
}

proc interface_connection {masterpin slavepin
                           ms_intc_in_system sl_intc_in_system
                           {auto_clock_reset_en 0}} {
  set intc_on_slave_absent 0
  # connect clocks and resets for interface in intc. wich has intf connection
  # if master or slave intc. not defined - use correspond intf. as target
  if {![llength ${sl_intc_in_system}]} {
    set intc_s_pin ${slavepin}
    set intc_on_slave_absent 1
  } else {
    set intc_s_pin [lindex [alloc_intc_intf ${slavepin} ${sl_intc_in_system}] 0]
  }

  if {![llength ${ms_intc_in_system}]} {
    set intc_m_pin ${masterpin}
    set open_slave [open_intf ${slavepin}]
    if {${intc_on_slave_absent} && ${open_slave} == ""} {
      # Use original apply_bd_automation
      # this branch should be approach only if 2 interface is open
      set config [list \
          Clk_master "Auto" Clk_slave "Auto" \
          Clk_xbar "Auto" Master ${masterpin} Slave ${slavepin} \
          intc_ip "Auto" master_apm {0}]
      set apply_connection_command "apply_bd_automation \
        -rule xilinx.com:bd_rule:axi4 \
        -config \{${config}\} \[get_bd_intf_pins ${slavepin}\]"
      eval ${apply_connection_command}
      return ""
    }
  } else {
    set intc_m_pin [lindex [alloc_intc_intf ${masterpin} ${ms_intc_in_system}] 0]
  }

  connect_bd_intf_net ${intc_m_pin} ${intc_s_pin}
  # Connect association clocks and reset(s) of iteraces
  intf_to_intf_rst_clk_connect ${intc_m_pin} ${intc_s_pin}
  if { ${auto_clock_reset_en} } {
    # soft connection of clock/reset based on interface propagation connection
    intf_clk_rst_propag_connect ${slavepin}
    intf_clk_rst_propag_connect ${masterpin}
  }

  set slavepin [which_slave \
      [get_bd_intf_pins ${masterpin}] \
      [get_bd_intf_pins ${slavepin}]]
  # assign_bd_address -quiet [get_bd_addr_seg -of ${slavepin}]
  # include_bd_addr_seg -quiet [get_bd_addr_seg -of ${slavepin}]
}

proc alloc_intc_intf {target_intf target_intc} {
  set target_intf_mode [get_property MODE ${target_intf}]
  # rule for now: if Master - take last intc. otherwise - firs
  if { ${target_intf_mode} == "Masetr" } {
    set target_intc [lindex ${target_intc} end]
  } else {
    set target_intc [lindex ${target_intc} 0]
  }
  set target_intc [get_bd_cells -quiet ${target_intc}]
  # Re-use open connection on interconnector
  set intc_pin_list [cell_intf_by_mode ${target_intc} ${target_intf_mode}]
  foreach intc_pin $intc_pin_list {
    set intc_pin [open_intf ${intc_pin}]
    if { ${intc_pin} != "" } {
      # Disconnect associated clock only for interconnector
      if { ![is_smart_interconnect ${target_intc}] } {
        set clk_pin [associated_pin ${intc_pin} clk]
        set clk_net [get_bd_nets -quiet -of_objects ${clk_pin}]
        set rst_pin [associated_pin ${intc_pin} RESET]
        set rst_net [get_bd_nets -quiet -of_objects ${rst_pin}]
        disconnect_bd_net -quiet ${clk_net} ${clk_pin}
        disconnect_bd_net -quiet ${rst_net} ${rst_pin}
      } elseif { [first_open_clk ${target_intc}] == ""} {
        # Add clock to smart connector if no left open clocks
        add_smartintc_clk ${target_intc}
      }
      return ${intc_pin}
    }
  }
  set intc_pin [intc_add_intf ${target_intc} ${target_intf_mode}]
  return ${intc_pin}
}

proc mod_reverse {mode} {
  set oposite_intf_mod "Slave"
  if {${mode} != "Slave" && ${mode} != "Master"} { return "" }
  if {${mode} == "Slave"} { set oposite_intf_mod "Master" }
  return ${oposite_intf_mod}
}

# ------------------------------------------------------------------------------
# intc_add_intf -- mode : Master/Slave returned created interface
# ------------------------------------------------------------------------------
proc intc_add_intf {target_intc mode} {
  set property_num_name ""
  if {${mode} == "Slave"} {
    set property_num_name "CONFIG.NUM_SI"
  } elseif {${mode} == "Master"} {
    set property_num_name "CONFIG.NUM_MI"
  } else {
    error "Undefine mode. Can be: \[Master | Slave\]"
  }

  set currentnum [get_property ${property_num_name} ${target_intc}]
  set newnum [expr $currentnum + 1]
  set pinlistbefore [get_bd_intf_pins -of_objects ${target_intc}]
  set_property ${property_num_name} ${newnum} ${target_intc}
  # Add clock for new interface, needed for smart-connector
  add_smartintc_clk ${target_intc}

  # get_bd_intf_pins -of_objects [get_selected_objects ] -filter "PATH!=$a"
  set pinlistafter [get_bd_intf_pins -of_objects ${target_intc}]
  set lnewpins [listcomp ${pinlistafter} ${pinlistbefore}]
  return ${lnewpins}
}

# add_smartintc_clk -- add clock pin for smart interconnector
proc add_smartintc_clk { target_intc } {
  set num_clks [get_property -quiet CONFIG.NUM_CLKS ${target_intc}]
  set num_clks [expr ${num_clks} + 1]
  set_property -quiet CONFIG.NUM_CLKS ${num_clks} ${target_intc}
}

# ------------------------------------------------------------------------------
# is_in_target_hier -- check if target_obj inside target_hier
# ------------------------------------------------------------------------------
proc is_in_target_hier {target_obj target_hier} {
  set match_result [string match ${target_hier}* ${target_obj}]
  return ${match_result}
}

proc is_end_point {interface} {
  if {[open_intf ${interface}] == ${interface}} {
    return 1
  }
  return 0
}
# ------------------------------------------------------------------------------
# apply_connection -- main function to connect interfaces
# set masterpin /p_zynqMP_pl/vsi_common_interface_0/M_AXI_1
# set slavepin $slave
# set slavepin $slave
# set sys_hier ${placed_hier}
# set auto_clock_reset_en 0
# ------------------------------------------------------------------------------
proc apply_connection {masterpin slavepin {sys_hier "/"} {auto_clock_reset_en 0}} {
  # Debug:
  # puts "set masterpin \[ get_bd_intf_pins $masterpin \] \n\
  #       set slavepin \[ get_bd_intf_pins $slavepin \] \n\
  #       set sys_hier \[ get_bd_cells $sys_hier \] \n\
  #       set auto_clock_reset_en  $auto_clock_reset_en"

  set masterpin [get_bd_intf_pins ${masterpin}]
  set slavepin [get_bd_intf_pins ${slavepin}]
  # Normalization interfaces to avoid mismatching mode when try to connect 
  # interfaces on edges of hierarchies.
  set masterpin [on_edge_connected_intf ${masterpin}]
  set slavepin [on_edge_connected_intf ${slavepin}]

  set ignore_system_intc 1
  set ms_intc_in_system [correspond_interc_of_intf ${masterpin} ${sys_hier} ${ignore_system_intc}]
  set sl_intc_in_system [correspond_interc_of_intf ${slavepin} ${sys_hier} ${ignore_system_intc}]
  set sl_intc_in_block_diagram [correspond_interc_of_intf ${slavepin}]
  set ms_intc_in_block_diagram [correspond_interc_of_intf ${masterpin} ${ignore_system_intc}]
  set sl_intc_in_block_diagram [correspond_interc_of_intf ${slavepin} ${ignore_system_intc}]
  # place interconector if connection exist but intc. is absent
  if {${ms_intc_in_system} == "" && [open_intf ${masterpin}] == ""} {
    set ms_intc_in_system ${ms_intc_in_block_diagram}
    if {${ms_intc_in_system} == "" && ${sl_intc_in_block_diagram} == ""} {
      # Use the same hierarchy as IP of master interface pin for inter-connector
      # if a system hierarchy is not defined.
      set master_hier ${sys_hier}
      if {${master_hier} == "/"} {
        set master_hier [get_parent_hier ${masterpin}]
      }
      set ms_intc_in_system [create_intc_for_intf ${masterpin} ${master_hier}]
    }
  }

  if { ${sl_intc_in_system} == "" } {
    set sl_intc_in_system ${sl_intc_in_block_diagram}
    if {${sl_intc_in_system} == "" && ${ms_intc_in_system} == ""} {
      # Use the same hierarchy as IP of slave interface pin for inter-connector
      # if a system hierarchy is not defined.
      set slave_hier ${sys_hier}
      if {${slave_hier} == "/"} {
        set slave_hier [get_parent_hier ${slavepin}]
      }
      set sl_intc_in_system [create_intc_for_intf ${slavepin} ${slave_hier}]
    }
  }

  # artifacts cells appear in the top of block diagram
  set sysparenthier "/"
  set lcell_before_automation [get_cells_in_hier ${sysparenthier}]


# lassign [list ${masterpin} ${slavepin} ${ms_intc_in_system} ${sl_intc_in_system} ${auto_clock_reset_en}] masterpin slavepin ms_intc_in_system sl_intc_in_system auto_clock_reset_en
  # Get only one closest to correspondent interface interconnector
  set ms_intc_in_system [closest_path ${ms_intc_in_system} ${slavepin}]
  set sl_intc_in_system [closest_path ${sl_intc_in_system} ${masterpin}]
  interface_connection ${masterpin} ${slavepin} ${ms_intc_in_system} \
                       ${sl_intc_in_system} ${auto_clock_reset_en}
  # post_apply_check ${sysparenthier} ${sys_hier} ${lcell_before_automation}
}

# ------------------------------------------------------------------------------
# get_cells_in_hier -- get cells
# ------------------------------------------------------------------------------
proc get_cells_in_hier {targethier} {
  set entry_inst_place [current_bd_instance .]
  current_bd_instance ${targethier}
  set cellsinhier [get_bd_cells -quiet]
  current_bd_instance ${entry_inst_place}
  return ${cellsinhier}
}

# ------------------------------------------------------------------------------
# pre_apply_cell_list -- get cells
# ------------------------------------------------------------------------------
proc post_apply_check {targethier destinationhier lcmpcell} {
  set entry_inst_place [current_bd_instance .]
  current_bd_instance ${targethier}
  set cellsinhier [get_cells_in_hier ${targethier}]
  foreach cell ${cellsinhier} {
    set cmpresult [lsearch ${lcmpcell} ${cell}]
    # if cell not in list with cells - move it in to destination hierarchy
    if { ${cmpresult} == -1 }  {
      move_bd_cells [get_bd_cells ${destinationhier}] [get_bd_cells ${cell}]
    }
  }
  current_bd_instance ${entry_inst_place}
  return ${cellsinhier}
}

# correspond_interc_of_intf -- get list of interconectors in hierarchy which has
#   connection with interface, and place it
proc correspond_interc_of_intf {interface {look_in_hier "/"} {ignore_marked 0}} {
  if {![llength ${interface}]} { return "" }
  set look_in_hier [get_bd_cells -quiet ${look_in_hier}]
  set linterconnector ""
  set stop_at_ip 1
  set start_from_interface [on_edge_connected_intf ${interface}]
  set interface_connection_path [get_pin_path ${start_from_interface} ${stop_at_ip}]
  set lintercopath ""
  foreach path $interface_connection_path {
    foreach interface_in_path $path {
      set connected_to_cell [get_bd_cells -quiet -of_objects $interface_in_path]
      if { [is_interconnect ${connected_to_cell} 0 ${ignore_marked}] } {
        lappend lintercopath "PATH=~${connected_to_cell}"
      }
    }
  }

  if { ${lintercopath} != "" } {
    set filter [join ${lintercopath} { || }]
    set linterconnector [get_bd_cells -hierarchical -of_objects $look_in_hier \
        -quiet -filter ${filter}]
  }

  return ${linterconnector}
}

# ------------------------------------------------------------------------------
# create_intc_for_intf -- create intc. in target_hier and connect it to intf.
# ------------------------------------------------------------------------------
proc create_intc_for_intf {interface {target_hier "/"}} {
  if {![llength ${interface}]} { return "" }
  set entry_inst_place [current_bd_instance .]
  current_bd_instance ${target_hier}

  set interface_mode [get_property MODE ${interface}]
  set intc_name [build_unique_cell_name "axi_intc"]
  set intc_vlnv [intc_vlnv_type ${interface}]
  set newintc [create_bd_cell -type ip -vlnv ${intc_vlnv} ${intc_name}]
  set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1}] ${newintc}
  set_property -quiet CONFIG.NUM_CLKS 2 ${newintc}
  set cell_of_intf [get_bd_cells -of_objects ${interface}]
  set target_intf_mode [mod_reverse ${interface_mode}]
  # Sl2Sl or Master2Master can be if target cell located in hierarchy
  if {[is_hierarchy ${cell_of_intf}] && ![is_ip ${cell_of_intf}]} {
    set target_intf_mode ${interface_mode}
  }
  set intc_pin [cell_intf_by_mode ${newintc} ${target_intf_mode}]
  connect_bd_intf_net ${intc_pin} ${interface}
  # Connect association clocks and reset(s) of iteraces
  intf_to_intf_rst_clk_connect ${intc_pin} ${interface}
  current_bd_instance ${entry_inst_place}
  return ${newintc}

}

# Utility to build clock rules for apply_bd_automation
proc clock_drive_rule { targetinterface } {
  if { ![llength ${targetinterface}] } { return "Auto" }

  set associated_clk_pin [associated_pin ${targetinterface} clk]
  set associated_pin_dir [get_property -quiet DIR ${associated_clk_pin}]
  # case if associated pin is driver clock
  if { ${associated_pin_dir} == "O"} {
    set driver_clock_pin ${associated_clk_pin}
  } else {
    set driver_clock_pin [find_connected ${associated_clk_pin}]
  }
  set driver_clock_mhz [get_freq_mhz ${driver_clock_pin}]
  set rule_str [build_rule_str ${driver_clock_pin} ${driver_clock_mhz}]
  return [list ${rule_str} ${driver_clock_pin} ${driver_clock_mhz}];
}

# Utility to get driver reset and clock
proc reset_drive_pin { targetinterface } {
  return [get_drive_pin ${targetinterface} RESET]
}

proc clock_drive_pin { targetinterface } {
  return [get_drive_pin ${targetinterface} clk]
}

proc get_drive_pin { targetinterface type} {
  if { ![llength ${targetinterface}] } { return "" }
  set associated_pin [associated_pin ${targetinterface} ${type}]
  set associated_pin_dir [get_property -quiet DIR ${associated_pin}]
  # case if associated pin is driver clock
  if { ${associated_pin_dir} == "O"} {
    set driver_pin ${associated_pin}
  } else {
    set driver_pin [find_connected ${associated_pin}]
  }
  return ${driver_pin}
}

proc build_rule_str { driver_clock freq_mhz } {
  set rule_str "Auto"
  if { ${driver_clock} != "" } {
    if { ${freq_mhz} != "" } { set freq_mhz "(${freq_mhz} MHz)" }
    set rule_str [concat ${driver_clock} ${freq_mhz}]
  }
  return ${rule_str}
}

proc get_freq_mhz { targetclkpin } {
  set targetclkpin [get_bd_pin ${targetclkpin}]
  if { ${targetclkpin} != "" } {
    set freq_hz [get_property -quiet CONFIG.FREQ_HZ ${targetclkpin}]
    if {${freq_hz} != ""} {
      return [expr ${freq_hz}/1000000]
    }
  }
  return ""
}

# ------------------------------------------------------------------------------
# associated_pin --
# ------------------------------------------------------------------------------
proc associated_pin { targetpin {type} } {
  if {![llength ${targetpin}]} return ""
  if { [catch { get_property CLASS ${targetpin} } ] } {
    return ""
  } else { set interface ${targetpin} }
  set targetpin_type [get_property TYPE ${targetpin}]
  if {${interface} == ""} {
    debug::send_message -severity ERROR -msg "${targetpin} doesn't exist"
  }

  set parentcellpath [get_bd_cells -of_objects ${interface}]
  set parentcell [get_bd_cells ${parentcellpath}]
  if { ${type} == "clk" } {
    # case if selected pin correspond to looking type (only clk for now)
    if {${targetpin_type} == ${type}} {
      return ${targetpin}
    }
    set clk_pins [get_bd_pins -quiet -of_object ${parentcell} \
        -filter {TYPE=~*clk}]
    foreach pin ${clk_pins} {
      set assoc_busifs [get_property CONFIG.ASSOCIATED_BUSIF ${pin}]
      if {$assoc_busifs!=""} {
        set splitted_busif [split ${assoc_busifs} :]
        foreach busif ${splitted_busif} {
          set busif_parts [split ${targetpin} /]
          set name [lindex ${busif_parts} [expr [llength ${busif_parts}] - 1]]
          if {[string equal [string toupper ${name}] [string toupper ${busif}]]} {
            return [get_bd_pins -quiet ${pin}]
  }}}}
  } else {
    set pin [associated_pin ${targetpin} clk]
    if {${pin} == ""} return ""
    set assoc_busifs [get_property CONFIG.ASSOCIATED_${type} ${pin}]
    if {${assoc_busifs} != ""} {
      set splitted_busif [split ${assoc_busifs} :]
      foreach busif ${splitted_busif} {
        lappend pin_path "${parentcell}/${busif}"
      }
      # by default associated_pin can be input
      set associated_pin_list [get_bd_pins -quiet -filter {DIR=~I} ${pin_path}]
      return [lindex ${associated_pin_list} 0]
    }

    # If IP was packaged bad, but have only one pin with a correspond type
    set get_pin_type ${type}
    # Type in configuration not match with RTL type
    if {[string tolower ${type}] == "reset"} {
      set get_pin_type "rst"
    }

    set force_assoc_pin [get_bd_pins -quiet -of_object ${parentcell} \
                                     -filter "DIR=~I && TYPE==${get_pin_type}"]
    if {[llength ${force_assoc_pin}] == 1} {
       return [lindex ${force_assoc_pin} 0]
    }
  }

  return  ""
}

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# sys_intf_termination
#   Function to place termination inter-connector into target hierarchy and
#   connect target interface with that inter-connector
# ------------------------------------------------------------------------------
proc sys_intf_termination {hierarchy interface} {
  set hierarchy [get_bd_cells -quiet ${hierarchy}]
  set interface [get_bd_intf_pins -quiet ${interface}]
  if {${interface} == "" || ${hierarchy} == ""} {
    error "interface(${interface}) or hierarchy(${hierarchy}) not reachable"
  }
  # place inter_connector only for master cells
  set interfacemode [get_property -quiet MODE ${interface}]
  if { ${interfacemode} != "Slave" } {
    # return
  }

  set interfacemode [get_property MODE ${interface}]
  set intfname [string tolower [get_property NAME ${interface}]]
  set hiername [string tolower [get_property NAME ${hierarchy}]]
  set cellnamepattern "${hierarchy}/intct_${hiername}_${intfname}_inst%d"
  while {1} {
    set np 0
    set cellname [format ${cellnamepattern} ${np}]
    if {[get_bd_cells ${cellname}] == ""} break
    incr np
  }
  set cell [create_bd_cell -type ip \
      -vlnv [intc_vlnv_type] ${cellname}]
  set_property -quiet -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {1} \
      CONFIG.S00_HAS_REGSLICE {1}] ${cell}
  set interconnect_interface [get_bd_intf_pins -of_objects ${cell} \
      -filter Mode=~"${interfacemode}"]
  connect_bd_intf_net -quiet ${interface} ${interconnect_interface}

  # Explicit connection clock's and resets
  set connected_to_through [find_practical_connect ${interconnect_interface}]
  set associated_clk_connect [associated_pin ${connected_to_through} clk]
  set associated_clk_interface [associated_pin ${interconnect_interface} clk]
  if { ${associated_clk_connect} != "" && ${associated_clk_interface} != "" } {
    safe_connect_bd_net ${associated_clk_connect} ${associated_clk_interface}
  } else {
    error "Fail to terminate interfsce: ${interface}\
      No assosciated clock or brocken connection: \
      ${interface} to ${connected_to_through}"
  }
  set associated_rst_connect [associated_pin ${connected_to_through} reset]
  set associated_rst_interface [associated_pin ${interface} reset]
  if { ${associated_clk_connect} != "" && ${associated_clk_interface} != "" } {
    safe_connect_bd_net ${associated_rst_connect} ${associated_rst_interface}
  } else {
    # This is not an error in smart connection
    puts "No assosciated clock or brocken connection \
      Termination interconect interface: ${interconnect_interface} \
      Connected to interface: ${connected_to_through}"
  }
  # intc_clk_rst_connect ${connected_interface} ${interconnect_interface}
}

# ------------------------------------------------------------------------------
# oposite_interface -- get interfaces opposite to target of the same cell
# ------------------------------------------------------------------------------
proc oposite_interface {intf_obj} {
  set intf_mod [get_property -quiet MODE ${intf_obj}]
  set oposite_intf_mod [mod_reverse ${intf_mod}]
  set intf_cell [get_bd_cells -of_objects ${intf_obj}]
  set pinsoncell [cell_intf_by_mode ${intf_cell} ${oposite_intf_mod}]
  return $pinsoncell
}

# ------------------------------------------------------------------------------
# cell_intf_by_mode -- get interfaces in cell by type
# ------------------------------------------------------------------------------
proc cell_intf_by_mode {cell_obj intf_mod} {
  set pinsoncell [get_bd_intf_pins -quiet -of_objects ${cell_obj}\
     -filter MODE=~${intf_mod}]
  return $pinsoncell
}

# ------------------------------------------------------------------------------
# open_intf -- returned open interfaces from interface list
# ------------------------------------------------------------------------------
proc open_intf {target_intf} {
  set connected_to [find_connected_intc_stop ${target_intf}]
  if {${connected_to} == ""} {
    return ${target_intf}
  }

  set pin_of_cell [get_bd_cells -of_objects ${connected_to}]
  if {[is_hierarchy ${pin_of_cell}] && ![is_ip ${pin_of_cell}]} {
    return ${connected_to}
  }

  return ""
}

# ------------------------------------------------------------------------------
# first_open_clk -- returned first open clock of target cell otherwise - "" 
# ------------------------------------------------------------------------------
proc first_open_clk { target_cell } {
  set target_cell [get_bd_cell ${target_cell}]
  set filter { TYPE == "clk" }
  set clk_pin_list [get_bd_pins -hier -filter $filter -of_object $target_cell]
  foreach clk_pin ${clk_pin_list} {
    # Check if current pin is open
    set open_intf_name [open_intf ${clk_pin}]
    if { ${open_intf_name} == ${clk_pin} } {
      return ${clk_pin}
    }
  }

  return ""
}

# ------------------------------------------------------------------------------
# propagation_path --
# Get propagation path for interface, depend on direction.
# Arguments:
# targetpin - target pin/interface_pin block diagram object
# mastertoslave - search direction ;
#       "true" - propagation from master to slave / Output to Input
#       "false" - propagation from slave to master / Input to Output
#       default true
#   intf_hist - preview path, initial should be empty
# Results:
# List of propagation paths as:{{c1/OA c2/BI1} {c2/BO1 c3/CI1}} {{c1/OA c2/BI2}}
# ------------------------------------------------------------------------------
proc propagation_path { targetpin
                        {mastertoslave "true"}
                        {propagationhistory {}}
                      } {
  if {![llength ${targetpin}]} return ""

  set returnpath ""
  set pinclass [get_property -quiet CLASS ${targetpin}]
  set readparameter [direcion_parameter ${pinclass}]
  set targetmode [get_property ${readparameter} ${targetpin}]
  set direction [pin_mode_unify ${targetmode}]
  set get_pin_function [get_pin_function_name ${pinclass}]

  set boundary_type "all"
  if { ${direction} == "O"} {
    set boundary_type "upper"
  } elseif {${direction} == "I"} {
    set boundary_type "lower"
  }

  # no invert if try to search from port
  if {(${mastertoslave} == "false" && ![is_obj ${targetpin} "(.*)_port"]) } {
    set boundary_type [up_lo_invert ${boundary_type}]
  }

  set l_connected_to [find_bd_objs -quiet -relation connected_to \
      -boundary_type ${boundary_type} ${targetpin}]
  if {${direction} == "IO"} {
    set filtred_connections {}
    # Bi direction pin looking for all boundary_type and will try to use a pin
    #  from which him was propagated
    foreach connected_to ${l_connected_to} {
      set flatten_history [flatten ${propagationhistory}]
      set pin_in_history [lsearch ${flatten_history} ${connected_to}]
      # if pin already in history - search try o go reverse
      if {${pin_in_history} == -1} {
        lappend filtred_connections ${connected_to}
      }
    }
    set l_connected_to ${filtred_connections}
  }

  if {![llength ${l_connected_to}]} {
    return [list ${propagationhistory}]
  }

  foreach connected_to ${l_connected_to} {
    set connected_to [${get_pin_function} -quiet [flatten ${connected_to}]]
    set loopdetectedflag 0
    set connectedtocell [get_bd_cells -quiet -of_objects ${connected_to}]
    set currentconnection [list ${targetpin} ${connected_to}]

    # Loop detection
    # it doesn't works for BIDIR's
    set pair_in_history [lsearch ${propagationhistory} ${currentconnection}]
    if { (${pair_in_history} > -1) } {
        set loopdetectedflag 1
        set returnpath [list ${propagationhistory}]
    }


    set pinpropagation ${connected_to}
    # Through IP propagation available only for interface pins
    if {[is_ip ${connectedtocell}] && ${pinclass} == "bd_intf_pin"} {
      # Get opposite interfaces to target pin
      set interfacemode "Master"
      if {${mastertoslave} == "false"} {
        set interfacemode "Slave"
      }
      set pinsoncell [${get_pin_function} -quiet \
        -of_objects ${connectedtocell} -filter MODE=~${interfacemode}]
      if {[llength ${pinsoncell}]} {
        set pinpropagation ${pinsoncell}
      }
    }

    if {!${loopdetectedflag} && [llength ${pinpropagation}]} {
      foreach nexttargetpin ${pinpropagation} {
        set updatedhistory ${propagationhistory}
        if {[llength ${propagationhistory}]} {
          lappend updatedhistory ${currentconnection}
        } else {
          set updatedhistory [list ${currentconnection}]
        }
        # search next possible connection
        set nexttargetpin [${get_pin_function} -quiet ${nexttargetpin}]
        set lchildpath [propagation_path ${nexttargetpin} \
            ${mastertoslave} ${updatedhistory}]
        foreach childpath ${lchildpath} {
          lappend returnpath ${childpath}
        }
      }
    } else {
      set returnpath [list ${propagationhistory}]
    }
  }

  return ${returnpath}
}

# ------------------------------------------------------------------------------
# connected_to_cell -- get bd cell list to which connected target pin
# ------------------------------------------------------------------------------
proc connected_to_cell {targetpin} {
  if {![llength ${targetpin}]} return ""
  set pinclass [get_property -quiet CLASS ${targetpin}]
  if {![llength ${pinclass}]} return ""
  set get_pin_function [get_pin_function_name ${pinclass}]
  set connected_to [find_connected ${targetpin}]
  set connected_to [${get_pin_function} -quiet ${connected_to}]
  # get only IP's (ignore hierarchies)
  set filter "TYPE=~ip"
  set lcells [get_bd_cells -quiet -of_objects ${connected_to} -filter ${filter}]
  return ${lcells}
}

proc find_connected_intc_stop {targetpin {reverse "0"}} {
  set stop_at_intcnct "1"
  return [find_connected ${targetpin} ${stop_at_intcnct} ${reverse}]
}

# ------------------------------------------------------------------------------
# find_connected --
# Find a list of interfaces/pins which connected to target interface/pin.
# targetpin : target interface/pin.
# Results: interface/pin list.
# ------------------------------------------------------------------------------
proc find_connected {targetpin {stop_at_intcnct "0"} {reverse "0"}} {
  if {![llength ${targetpin}]} return ""
  set pinclass [get_property -quiet CLASS ${targetpin}]
  set get_pin_function [get_pin_function_name ${pinclass}]
  set stop_at_ip 1
  set direction "AUTO"
  set return_pairs 0
  set lpin_path [get_pin_path ${targetpin} ${stop_at_ip} ${stop_at_intcnct} \
                              ${direction} ${return_pairs} ${reverse}]
  set lreturnpinlist ""
  set pairCurrent ""
  foreach intfPropag ${lpin_path} {
    set endpointpin ""
    foreach pin $intfPropag {
      set endpointpin ${pin}
      set pinbd_object [${get_pin_function} -quiet ${pin}]
      set cell [get_bd_cells  -quiet -of_objects ${pinbd_object}]
      # included in get_pin_path and can be remove from current place
      # --------------------------------------
      if { ${stop_at_intcnct} == 1 && [is_interconnect ${cell}]} break;
      if { [is_ip ${cell}] && ![is_interconnect ${cell}] } break
      # --------------------------------------
    }
    lappend lreturnpinlist ${endpointpin}
  }

  # remove duplicate interface(s) which can appear in the hierarchical IP's
  set unique_pin_list [lsort -unique ${lreturnpinlist}]
  set lreturnpinlist [${get_pin_function} -quiet ${unique_pin_list}]
  return ${lreturnpinlist}
}

# ------------------------------------------------------------------------------
# find_practical_connect -- no return hierarchy and interconectors
# ------------------------------------------------------------------------------
proc find_practical_connect {targetpin {reverse "0"}} {
  set connections [find_connected ${targetpin} ${reverse}]
  set intflist {}
  foreach intf $connections {
    set cell [get_bd_cells -quiet -of_objects ${intf}]
    if {([is_ip ${cell}] && ![is_interconnect ${cell}]) || [is_port ${intf}] } {
      lappend intflist $intf
    }
  }
  return ${intflist}
}

# ------------------------------------------------------------------------------
# bool_inverse -- inverse boolean false to true and other opposite way
# ------------------------------------------------------------------------------
proc bool_inverse { input_val } {
  if {${input_val} == "true" } { return "false" }
  if {${input_val} == "false" } { return "true" }
  error "0xc6dcc615: Unexpected input value"
}

proc get_reverse_pin_path { targetpin
                            {stop_at_ip "0"}
                            {stop_at_intcnct "0"}
                            {direction "AUTO"}
                            {return_pairs 0}
                            {reverse "1"}
                          } {
  return [get_pin_path ${targetpin} ${stop_at_ip} ${stop_at_intcnct} \
                       ${direction} ${return_pairs} ${reverse}];
}

# ------------------------------------------------------------------------------
# get_pin_path --
# ------------------------------------------------------------------------------
proc get_pin_path { targetpin
                    {stop_at_ip "0"}
                    {stop_at_intcnct "0"}
                    {direction "AUTO"}
                    {return_pairs 0}
                    {reverse "0"}
                  } {
  if {![llength ${targetpin}]} return ""

  set returnpath ""
  set pinclass [get_property -quiet CLASS ${targetpin}]
  set get_pin_function [get_pin_function_name ${pinclass}]
  set get_port_function [get_port_function_name ${pinclass}]
  if {${direction} == "AUTO"} {
    set direction [mastertoslave_auto_dir ${targetpin}]
    if {${reverse}} {
      set direction [bool_inverse ${direction}]
    }
  }

  set lpath [propagation_path ${targetpin} ${direction}]
  set returnpath ""
  set pairCurrent ""
  foreach path ${lpath} {
    set pathpinlist ""
    foreach pair $path {
      lassign ${pair} target destination
      set destination [${get_pin_function} -quiet ${destination}]
      if { ![llength ${destination}] } {
        set destination [${get_port_function} -quiet ${destination}]
        if { [llength ${destination}] } {
          if {${return_pairs}} {
            lappend pathpinlist ${pair}
          } else {
            lappend pathpinlist ${destination}
          }
        }
        break
      }

      if {${return_pairs}} {
        lappend pathpinlist ${pair}
      } else {
        lappend pathpinlist ${destination}
      }

      set cell [get_bd_cells -quiet -of_objects ${destination}]
      if { ${stop_at_intcnct} == 1 && [is_interconnect ${cell}]} break;
      if { ${stop_at_ip} == 1 && [is_ip ${cell}] &&
           ![is_interconnect ${cell}] } { break; }
    }
    lappend returnpath ${pathpinlist}
  }

  return ${returnpath}
}

# ------------------------------------------------------------------------------
# get_parent_hier_ip bd_obj ?only_hip --
#   Get parent hierarchical IP of bd_obj.
# The get_parent_hier_ip command accepts a parameter, bd_obj, which it treats
#   as Vivado(r) block diagram object.
# The get_parent_hier_ip command returns parent hierarchical IP bd_cell object
#   if bd_obj is part of hierarchical IP or it is hierarchical IP.
# The get_parent_hier_ip command returns bd_obj argument if additional only_hip
#   argument not supplied or supplied with "0" value and bd_obj is block diagram
#   cell which is not a part of hierarchical IP.
# The get_parent_hier_ip command returns empty string :
#   - when only_hip argument supplied with value which is not equal to "0" and
#     bd_obj argument is not a part of hierarchical IP
#   - when bd_obj argument is not a part of hierarchical IP and
#     bd_obj argument is not a block diagram object
# ------------------------------------------------------------------------------
proc get_parent_hier_ip {bd_obj {only_hip 0}} {
  set splitpath [split ${bd_obj} "/"]
  set parentsIP ""
  foreach location ${splitpath} {
    lappend path ${location}
    set jpath [join ${path} "/"]
    set parentsIP [get_bd_cells -quiet ${jpath}]
    if { [is_ip ${parentsIP}] } { break }
  }

  if { ${only_hip} != 0 } {
    if { !([is_hierarchy ${parentsIP}] && [is_ip ${parentsIP}]) } {
      set parentsIP ""
    }
  }

  return ${parentsIP}
}

# ==============================================================================
#  Utility functions
# ==============================================================================
# get_parent_hier - function to get closest parent hierarchy of object
proc get_parent_hier {bd_obj} {
  set splitpath [split ${bd_obj} "/"]
  set parentsIP [get_bd_cells -quiet "/"]
  set pass_list ${splitpath}
  while { [llength ${pass_list}] } {
    set joined_path [join ${pass_list} "/"]
    set possibleParentIP [get_bd_cells -quiet ${joined_path}]
    if { [is_hierarchy ${possibleParentIP}] && ![is_ip ${possibleParentIP}] } {
      set parentsIP ${possibleParentIP}
      break
    }
    set pass_list [lrange ${pass_list} 0 end-1]
  }

  return ${parentsIP}
}

# ------------------------------------------------------------------------------
# is_ignore_intc --
# ------------------------------------------------------------------------------
proc is_ignore_intc {cell} {
  set cell [get_bd_cells -quiet ${cell}]
  set ignore [get_property -quiet SPEC_VSI_PROP.IGNORE_AS_INTERCONNECT ${cell}]
  return ${ignore}
}
proc set_as_ignore_intc {cell} {
  set cell [get_bd_cells -quiet ${cell}]
  set_property SPEC_VSI_PROP.IGNORE_AS_INTERCONNECT 1 ${cell}]
}

# ------------------------------------------------------------------------------
# is_interconnect - check if input cell is interconnect IP. Ret.: 1-true.
# ------------------------------------------------------------------------------
proc is_interconnect {cell {nosmart 0} {ignore_marked 0}} {
  if {${ignore_marked} && [is_ignore_intc ${cell}] != ""} {
    return "0"
  }

  set intercParts [list \
    xilinx.com:ip:axi_interconnect \
    xilinx.com:ip:axis_interconnect \
    [intc_vlnv_type] ]
  if {!${nosmart}} {
    set intercParts [concat $intercParts "xilinx.com:ip:smartconnect"]
  }
  set currentIP [get_property -quiet VLNV [get_bd_cells -quiet ${cell}]]
  # remove version of IP
  set currentIP [join [lrange [split ${currentIP} ":"] 0 end-1] ":"]
  set positon [lsearch ${intercParts} ${currentIP}]
  return [expr (${positon} < 0) ? "0" : "1"]
}

# ------------------------------------------------------------------------------
# is_smart_interconnect - check if input cell is smart interconnector IP.
# ------------------------------------------------------------------------------
proc is_smart_interconnect { cell } {
  set vlnv [get_property -quiet VLNV [get_bd_cells -quiet ${cell}]]
  if { [regexp xilinx.com:ip:smartconnect:* ${vlnv}] } {
    return 1
  }
  return 0
}

# ------------------------------------------------------------------------------
# flatten - full flatten of list
# ------------------------------------------------------------------------------
proc flatten list { string map {\{ "" \} ""} $list }

# ------------------------------------------------------------------------------
# is_hierarchy -- Check if cell is hierarchy
# ------------------------------------------------------------------------------
proc is_hierarchy {cell} {
  if { [get_property -quiet TYPE ${cell}] == "hier" } { return 1 }
  return 0
}

# ------------------------------------------------------------------------------
# is_hierarchical_ip -- Check if cell is hierarchical IP
# ------------------------------------------------------------------------------
proc is_hierarchical_ip {cell} {
  if { [is_hierarchy ${cell}] && [is_ip ${cell}]} { return 1 }
  return 0
}

# ------------------------------------------------------------------------------
# is_ip -- Check if cell is IP
# ------------------------------------------------------------------------------
proc is_ip {cell} {
  if { $cell != "" &&  [get_property -quiet VLNV ${cell}] != "" } { return 1 }
  return 0
}

# is_obj -- Check if input is bd object; require_class - can be regular expression
proc is_obj {obj {require_class ""}} {
  set obj_class [get_property -quiet CLASS ${obj}]
  if {${obj_class} != ""} {
    if {[regexp ${require_class} ${obj_class}] || ${require_class} == ""} {
      return 1
    }
  }
  return 0
}

proc par_cell {cell} {
  set splitPath [lrange [split ${cell} "/"] 0 end-1]
  set path [join ${splitPath} "/"]
  if { ${path} == "" } { set path "/" }
  return [get_bd_cells ${path}]
}

# ------------------------------------------------------------------------------
# pin_mode_unify --
# ------------------------------------------------------------------------------
proc pin_mode_unify {mode_or_direction} {
  if { ${mode_or_direction} == "Master" || ${mode_or_direction} == "O" } {
    return "O"
  } elseif { ${mode_or_direction} == "Slave" || ${mode_or_direction} == "I" } {
    return "I"
  }
  return "IO"
}

# ------------------------------------------------------------------------------
# get_pin_function_name -- convert pin class into get bd function
# ------------------------------------------------------------------------------
proc get_pin_function_name {pinclass} {
  set get_pin_function get_bd_pin
  # check if interface
  if {[regexp "bd_intf*" ${pinclass}]} {
     set get_pin_function get_bd_intf_pin
  }
  return ${get_pin_function}
}
# ------------------------------------------------------------------------------
# get_port_function_name -- convert pin class into get bd port function
# ------------------------------------------------------------------------------
proc get_port_function_name {pinclass} {
  set get_port_function get_bd_port
  # check if interface
  if {[regexp "bd_intf*" ${pinclass}]} {
     set get_port_function get_bd_intf_port
  }
  return ${get_port_function}
}

# ------------------------------------------------------------------------------
# direcion_parameter -- get parameter which should be read to get pin purpose
# ------------------------------------------------------------------------------
proc direcion_parameter {pinclass} {
  set readparameter "MODE"
  if { ${pinclass} == "bd_pin" || ${pinclass} == "bd_port" } {
    set readparameter "DIR"
  }
  return ${readparameter}
}

proc mastertoslave_auto_dir { targetpin } {
  set pinclass [get_property -quiet CLASS ${targetpin}]
  set readparameter [direcion_parameter ${pinclass}]
  set intfmode [get_property ${readparameter} ${targetpin}]
  set intfmode [pin_mode_unify ${intfmode}]
  if {${intfmode} == "I" } { return "false" }
  return "true"
}

# ------------------------------------------------------------------------------
# up_lo_invert -- invert boundary type
# ------------------------------------------------------------------------------
proc up_lo_invert {boundary_type} {
  if { ${boundary_type} == "upper" } {
    return "lower"
  } elseif { ${boundary_type} == "lower" } {
    return "upper"
  }
  return "all"
}

# ------------------------------------------------------------------------------
# clear_bd_all --
# ------------------------------------------------------------------------------
proc clear_bd_all {args} {
   delete_bd_objs -quiet [get_bd_addr_segs]
   delete_bd_objs -quiet [get_bd_addr_spaces]
   delete_bd_objs -quiet [get_bd_cells]
   delete_bd_objs -quiet [get_bd_intf_port]
   delete_bd_objs -quiet [get_bd_intf_pin]
   delete_bd_objs -quiet [get_bd_net]
   delete_bd_objs -quiet [get_bd_pin]
   delete_bd_objs -quiet [get_bd_port]
}

# ------------------------------------------------------------------------------
# listcomp -- compare list a with b
# ------------------------------------------------------------------------------
proc listcomp {a b} {
  set diff {}
  foreach i $a {
    if { [lsearch -exact $b $i] == -1 } {
      lappend diff ${i}
    }
  }
  return ${diff}
}

proc auto_to_nothing {str} {
  if {[string tolower ${str}] == "auto"} return ""
  return $str
}

# interconnect pin functions
proc pin_intc {intc pinname} {
  if { [is_interconnect ${intc} 1] } { return [get_bd_pin ${intc}/${pinname}] }
  return {}
  # error "Currently, only axi_interconnect supported"
}

proc xbar_clk_of_intc {intc} { return [pin_intc ${intc} "ACLK"] }
proc xbar_rst_of_intc {intc} { return [pin_intc ${intc} "ARESETN"] }

# ------------------------------------------------------------------------------
# post_processing -- function which will remove interconnectors which do not has
#   connection on master or slaves
# ------------------------------------------------------------------------------
proc post_processing {{target_cell "/"}} {
  set target_cell [get_bd_cells -quiet ${target_cell}]
  remove_nonconnected_intc ${target_cell}
  remove_empty_hier
  post_interface_clk_rst_connect
  intercon_control_clk_rst
  # Hack which will gess rst connection if it oc
  no_driven_reset_hack $target_cell
  # Clock can be open if interface resolve his clock and left allocated
  #  pin not connected.
  no_driven_clock_hack
  remove_open_clk_rst_on_hier ${target_cell}
  # Vivado 2019.* fix for generatad empty segments
  set broken_segment_l [get_bd_addr_segs -hier -excluded -filter {RANGE==1}]
  foreach broken_segment ${broken_segment_l} {
    include_bd_addr_seg $broken_segment
  }
  # Addresses including
  ddr_multiseg_include
  save_bd_design
  validate_bd_design
  save_bd_design
  assign_bd_address
  include_common_intf_ddr
}

# ------------------------------------------------------------------------------
# ddr_multiseg_include -- Include ddr of proccessing system to address segment
# ------------------------------------------------------------------------------
proc ddr_multiseg_include { } {
  # Get processing system, currently suported zynq, zynq_ultrascale, versal
  set proc_list [get_bd_cells -hierarchical \
      -filter { VLNV=~*zynq_ultra_ps_e* 
                || VLNV=~*processing_system7* 
                || VLNV=~*versal_cips* }]
  # Processing address segment for each Slave AXI interface of processing cell
  foreach proc ${proc_list} {
    set proc_slave_list [ get_bd_intf_pins -hierarchical -of_objects ${proc} \
        -filter {MODE==Slave && CONFIG.PROTOCOL==AXI4} ]
    foreach proc_slave ${proc_slave_list} {
      set addr_seg_list [get_bd_addr_segs  -of ${proc_slave}]
      foreach addr_seg ${addr_seg_list} { 
        catch {
          set target_seg [get_bd_addr_segs -ex -of ${addr_seg}]
          set offset [get_property OFFSET ${target_seg}]
          # Include if offset is 0 which correspond to DDR
          if { ${offset} == 0 } {
            include_bd_addr_seg ${target_seg}
          }
        }
      }
    }
  }
}

# remove_open_clk_rst_on_hier -- 
#    Remove open clocks and resets from the edges of target hierarchy
proc remove_open_clk_rst_on_hier { target_cell } {
  set hier_pins [get_bd_pins -of_objects ${target_cell} \
      -filter {INTF==FALSE && (TYPE=="clk" || TYPE=="clk")}]
  foreach pin ${hier_pins} {
    # If pin dosent have a driver - remove it from hierarchy
    set connected [find_bd_objs -relation connected_to ${pin}]
    if { ${connected} == "" } {
      delete_bd_objs ${pin}
    }
  }
}

# no_driven_clock_hack -- Hack to connect open clock of smart connector 
#    to his neighborn pin which have an driver.
proc no_driven_clock_hack {  } {
  set smart_connectors [get_bd_cells -hier \
      -filter {VLNV =~ "xilinx.com:ip:smartconnect:*"}]
  foreach cell ${smart_connectors} {
    set clocks_list [get_bd_pins -of_objects ${cell} -hierarchical \
        -filter { DIR=="I" && INTF==FALSE && TYPE=="clk" }]
    set use_as_driver ""
    # Define which clock have a driver.
    foreach clock_pin $clocks_list {
      if { [open_intf $clock_pin] == "" } {
        set use_as_driver $clock_pin
        break
      }
    }

    if { $use_as_driver == "" } {
      error "No pins on $cell which can be use as clock reference."
    }

    # Connect unconnected pins.
    foreach clock_pin $clocks_list {
      if { [open_intf $clock_pin] != "" } {
        connect_bd_net $clock_pin $use_as_driver
      }
    }
  }
}

# rst connect hack
proc no_driven_reset_hack { target_cell } {
  # This is just a gessing to prevent an error
  set pin_list [get_bd_pins -of_objects ${target_cell} -hierarchical \
      -filter { DIR=="I" && INTF==FALSE && TYPE=="rst" }]
  set rst_driver_list ""
  foreach pin $pin_list {
    # Cannot be multiple drivers:
    set connected_to [find_bd_objs -relation connected_to -thru_hier $pin ]
    if { $connected_to != "" && [lsearch $rst_driver_list $connected_to] == -1} {
      lappend rst_driver_list $connected_to
    }
  }

  # add crittical warning if multiples dirvers
  set resed_pin_to_use [lindex $rst_driver_list 0]
  if { $resed_pin_to_use == "" } {
    set common_interface [get_common_interface]
    if { ${common_interface} != "" } {
      set common_interface [lindex $common_interface 0]
      
      set resed_pin_to_use [get_bd_pins \
          -of_objects ${common_interface} -hierarchical \
          -filter {DIR=="O" && INTF==FALSE && TYPE=="rst" }]
      set resed_pin_to_use [lindex $resed_pin_to_use 0]
    }
  }

  foreach pin $pin_list {
    # Cannot be multiple drivers:
    set connected_to [find_bd_objs -relation connected_to -thru_hier $pin ]
    if { $connected_to == "" } {
      if { $resed_pin_to_use == "" } {
        error "No driver for pin: $pin. No reset driver found. "
      }
      connect_bd_net -quiet $resed_pin_to_use $pin
    }
  }
}
 
# ------------------------------------------------------------------------------
# Get common interfaces in the current bd
# ------------------------------------------------------------------------------
proc get_common_interface { } {
  set common_interface [get_bd_cells -hierarchical \
      -filter {VLNV=~*common_interface*}]
  return ${common_interface}
}

# ------------------------------------------------------------------------------
# post_interface_clk_rst_connect --
# ------------------------------------------------------------------------------
proc post_interface_clk_rst_connect { } {
  set intf_pin_list [get_bd_intf_pins -hierarchical \
      -filter {MODE==Slave || MODE==Master}]
  foreach intf_pin ${intf_pin_list} {
    set intf_parent [get_bd_cells -quiet -of_objects ${intf_pin}]
    set root_cell_of_ip [get_parent_hier_ip ${intf_parent}]
    # check if cell not inside hierarchical IP
    if {${root_cell_of_ip}  == ${intf_parent}} {
      intf_clk_rst_propag_connect ${intf_pin}
    }
  }
}

# ------------------------------------------------------------------------------
# intercon_intf_clk_propagate -- function to connect clocks/resets of
#   interface in interconnectors which already has connection
# ------------------------------------------------------------------------------
proc intercon_intf_clk_propagate {} {
  set cell_list [get_bd_cells -quiet  -hierarchical]
  foreach cell ${cell_list} {
    if {[is_interconnect ${cell}]} {
      set root_cell_of_ip [get_parent_hier_ip ${cell}]
      if {${root_cell_of_ip}  == ${cell}} {
        set interfaces_in_cell [get_bd_intf_pins -of_objects ${cell}]
        foreach interface $interfaces_in_cell {
          intf_clk_rst_propag_connect ${interface}
        }
      }
    }
  }
}

# ------------------------------------------------------------------------------
# intercon_control_clk_rst -- function to find all interconnector's and connect
#   open control clk/rst to closest Slave clk/rst
# ------------------------------------------------------------------------------
proc intercon_control_clk_rst {} {
  set cell_list [get_bd_cells -quiet  -hierarchical]
  foreach cell ${cell_list} {
    if {[is_interconnect ${cell}]} {
      set root_cell_of_ip [get_parent_hier_ip ${cell}]
      if {${root_cell_of_ip}  == ${cell}} {
        set interfaces_in_cell [get_bd_intf_pins -of_objects ${cell} \
                                                 -filter Mode=="Slave"]
        set clk_propagate_interface [lindex ${interfaces_in_cell} 0]
        # startgroup
        intc_clk_rst_connect ${clk_propagate_interface}
        # endgroup
      }
    }
  }
}

# ------------------------------------------------------------------------------
# remove_nonconnected_intc -- function to remove interconnector's
#    which don't have master or slave connection
# ------------------------------------------------------------------------------
proc remove_nonconnected_intc {{target_cell "/"}} {
  set celllist [get_bd_cells -quiet -hierarchical -of_objects ${target_cell}]
  foreach cell ${celllist} {
    if {[is_interconnect ${cell}]} {
      set has_practical_connection 0
      set check_modes {Master Slave}
      foreach mode ${check_modes} {
        set intf_pins [get_bd_intf_pins -quiet -of_objects ${cell} \
            -filter "MODE =~ ${mode}"]
        foreach intf_pin ${intf_pins} {
          set practical_pin [find_practical_connect ${intf_pin}]
          if {[llength ${practical_pin}]} {
            incr has_practical_connection
            break
          }
        }
      }

      if {${has_practical_connection} != [llength ${check_modes}]} {
        delete_bd_objs -quiet ${cell}
      }
    }
  }
}

# ------------------------------------------------------------------------------
# terminate_oc_slave_intc -- function to terminate interconectors if it have
#    open connection at slave
# ------------------------------------------------------------------------------
proc terminate_oc_slave_intc {{target_cell "/"}} {
  set target_cell [get_bd_cells $target_cell]
  set celllist [get_bd_cells -quiet -of_objects ${target_cell}]
  set ip_list ""
  set terminate_clk_ip ""
  # generate list of real IP's to avoid vivado crash after modifying of interconnector
  foreach cell ${celllist} {
    set parent [get_parent_hier_ip ${cell}]
    if { ${parent} == ${cell} } {
      if {[is_interconnect ${cell}]} {
        lappend ip_list ${cell}
      }
    }
  }

  set celllist ${ip_list}

  foreach cell ${celllist} {
    set parent [get_parent_hier_ip ${cell}]
    # remove IP's if it's part of hierarchycal IP
    if { ${parent} != ${cell} } {
      set cell ""
    }
    if {[is_interconnect ${cell}]} {
        set intf_pins [get_bd_intf_pins -quiet -of_objects ${cell} \
            -filter "MODE == Slave"]
        if { [llength ${intf_pins}] > 1 } {
          error "0x4ce5e5c3 ${cell} have more then one open Slave!"
        }

        foreach intf_pin ${intf_pins} {
          set connected_to [find_bd_objs -relation connected_to ${intf_pin}]
          if { ${connected_to} == "" } {
            set master_intf [get_bd_intf_pins -quiet -of_objects ${cell} \
                                              -filter "MODE == Master"]
            if { [llength ${master_intf}] > 1 } {
              puts "0x92379c31 ${cell} is not for PR termination?!"
            }
            set master_intf [lindex ${master_intf} 0]
            # [intc_add_intf ${cell} Master]
            # set allocated_master [alloc_intc_intf [get_bd_cells ${cell}] ${master_intf}]
            set allocated_master [intc_add_intf ${cell} Master]
            set allocated_master [get_bd_intf_pins ${allocated_master}]
            set intf_pin [get_bd_intf_pins ${intf_pin}]
            puts "connect_bd_intf_net ${allocated_master} ${intf_pin}"
            connect_bd_intf_net -boundary_type upper ${allocated_master} ${intf_pin}
            lappend terminate_clk_ip [terminate_clk $cell]
            # terminate ip which is connected
            set connected_to [find_connected_intc_stop ${master_intf}]
            lappend terminate_clk_ip [terminate_clk $connected_to]
          }
        }
    }
  }
  return [flatten ${terminate_clk_ip}]
}

# ------------------------------------------------------------------------------
# terminate_clk --
# ------------------------------------------------------------------------------
proc terminate_clk {{target_object ""}} {
  set facke_clk_const "fake_src"
  set non_driven_pin_list ""
  set fake_const_cell_list ""
  set filter {TYPE == "clk" && dir == "I"}
  if { $target_object == ""} {
    set clk_rst_pins [get_bd_pins -hierarchical -filter $filter]
  } else {
    if { [is_intf ${target_object}] } {
        set clk_rst_pins [associated_pin ${target_object} clk]
    } else {
      set target_object [get_bd_cells $target_object]
      set clk_rst_pins [get_bd_pins -hierarchical -filter $filter -of_object $target_object]
    }
  }

  set terminated_parents ""
  set term_fake_cel ""
  foreach pin $clk_rst_pins {
    set connected_to [find_practical_connect ${pin}]
    if { ${connected_to} == "" } {
      set parent_hier [get_parent_hier $pin]
      set in_proc_lis_num -1
      # [lsearch $terminated_parents $parent_hier]
      if {$in_proc_lis_num == -1} {
        # Generate unique cell name
        set fake_const_cell [build_unique_cell_name ${parent_hier}/${facke_clk_const}]
        set fake_const_cell [create_bd_cell -type ip \
             -vlnv xilinx.com:ip:xlconstant ${fake_const_cell}]
        lappend terminated_parents $parent_hier
        lappend fake_const_cell_list $fake_const_cell
      } else {
        set fake_const_cell [lindex ${fake_const_cell_list} $in_proc_lis_num]
      }

      set fake_clk_pin [get_bd_pins ${fake_const_cell}/dout]
      connect_bd_net ${fake_clk_pin} ${pin}
    }
  }
  return $fake_const_cell_list
}

# ------------------------------------------------------------------------------
# remove_with_check --
# ------------------------------------------------------------------------------
proc remove_with_check {cell_list} {
  set cell_list [flatten $cell_list]
  foreach cell $cell_list {
    set cell [get_bd_cells -quiet $cell]
    if { ${cell} == ""} {
      continue
    }
    delete_bd_objs ${cell}
  }
}

# ------------------------------------------------------------------------------
# remove_empty_hier -- remove empty hierarchies
# ------------------------------------------------------------------------------
proc remove_empty_hier {{target_cell "/"}} {
  set entry_inst_place [current_bd_instance .]
  current_bd_instance ${target_cell}
  set celllist [get_bd_cells -quiet -filter {TYPE==hier}]
  foreach cell ${celllist} {
    set cellsinhier [get_bd_cells -quiet -of_objects ${cell} -filter {VLNV!=""}]
    if {![llength ${cellsinhier}] && ![is_ip ${cell}]} {
      delete_bd_objs -quiet ${cell}
    }
  }
  set entry_inst_place [get_bd_cells -quiet ${entry_inst_place}]
  current_bd_instance ${entry_inst_place}
}

# ------------------------------------------------------------------------------
# build unique cell name for proposed cell name
# ------------------------------------------------------------------------------
proc build_unique_cell_name {cellname} {
  set cellnamepattern "${cellname}_inst%d"
  set inst_number 0
  while {1} {
      set cellname [format ${cellnamepattern} ${inst_number}]
      if {[get_bd_cells -quiet ${cellname}] == ""} break
      incr inst_number
  }
  return ${cellname}
}

# ------------------------------------------------------------------------------
# function to add ip repository to current project
# ------------------------------------------------------------------------------
proc add_ip_repo_path {path} {
  set ip_repo_paths [get_property ip_repo_paths [current_project]]
  lappend ip_repo_paths ${path}
  set_property ip_repo_paths ${ip_repo_paths} [current_project]
}

proc is_port {obj} {
  if {[get_bd_ports -quiet $obj] != "" ||
      [get_bd_intf_ports -quiet $obj] != ""} {
    return 1
  }
  return 0
}

proc is_intf_port {obj} {
  if { [get_bd_intf_ports -quiet $obj] != "" } {
    return 1
  }
  return 0
}

# ------------------------------------------------------------------------------
#  dict_get_quiet --
#     Get value from dictionary list by key in quiet mode.
#  Arguments:
#     dict_list - dictionary list
#     key - key in dictionary
#  Results:
#     value which correspond to key or "" if key not exist
# ------------------------------------------------------------------------------
proc dict_get_quiet { dict_list key {force ""}} {
  if { [dict exists ${dict_list} ${key}] } {
    return [dict get ${dict_list} ${key}]
  }
  return ${force}
}

# ------------------------------------------------------------------------------
#  push -- Add object to the end of the list
# ------------------------------------------------------------------------------
proc push {inlist var} {
    upvar $inlist l
    return [ lappend l $var ]
}

# ------------------------------------------------------------------------------
#  popback -- Get last object of the list
# ------------------------------------------------------------------------------
proc popback {inlist} {
    upvar $inlist l
    set  retval [lindex $l end]
    lset l [lreplace $l end end]
    return $retval
}

# ------------------------------------------------------------------------------
# connect_with_check -- Make simple connection if destination and target
#    interfaces are not connected otherwise use apply connection
#    to connect them.
# ------------------------------------------------------------------------------
proc connect_with_check {target_intf dest_intf {destination_hier "/"} } {
  set target_mode [get_property MODE ${target_intf}]
  set dest_mode [get_property MODE ${dest_intf}]
  set stop_at_intcnct 0
  set direction 0
  if {${target_mode} != ${dest_mode}} {
    # Look in reverse way if destination and target has the different mode
    set direction 1
  }
                                      
  set open_of_target [open_intf ${target_intf}]
  set open_of_dest [open_intf ${dest_intf}]
  # Regular connection if both interfaces is open
  if { ${open_of_target} != "" &&  ${open_of_dest} != "" } {
    connect_bd_intf_net  ${open_of_target} ${open_of_dest}
  } else {
    apply_connection ${target_intf} ${dest_intf} ${destination_hier}
  }
}

# ------------------------------------------------------------------------------
# common_string_part -- Function to get common part of 2 paths
# ------------------------------------------------------------------------------
proc common_string_part {str1 str2 {delimiter "/"}} {
  set split_str1 [split ${str1} ${delimiter}]
  set split_str2 [split ${str2} ${delimiter}]
  set split_str1_size [llength $split_str1]
  set split_str2_size [llength $split_str2]
  set max_len [expr max(${split_str1_size}, ${split_str2_size})]
  set common_part ""
  for {set i 0} {${i} < ${max_len}} {incr i} {
    set current_sub_str1 [lindex ${split_str1} ${i}]
    set current_sub_str2 [lindex ${split_str2} ${i}]
    if {${current_sub_str1} == ${current_sub_str2}} {
      lappend common_part ${current_sub_str1}
      continue
    }
    break
  }
  set common_string [join ${common_part} ${delimiter}]
  return ${common_string}
}

# ------------------------------------------------------------------------------
#  -- for now can fix connection only for 2 pin
# ------------------------------------------------------------------------------
namespace eval vsi {
proc connect_bd_net {args} {

  # connect_bd_net  [-net <arg>] [-boundary_type <arg>] [-quiet] [-verbose] <objects>...
  set arg_set ""
  set pins_to_connect ""
  set pins_to_connect_str ""
  set i 0
  for {set i 0} {${i} < [llength ${args}]} {incr i} {
    set var [lindex ${args} ${i}]
    if {([string first "-n" ${var}] == 0) || ([string first "-b" ${var}] == 0)} {
      lappend arg_set ${var}
      incr i
      set value [lindex ${args} ${i}]
      lappend arg_set ${value}
    } else {
      if {[string first "-" ${var}] != 0} {
        foreach pin ${var} {
          lappend pins_to_connect "\[get_bd_pins ${pin}\]"
          lappend pins_to_connect_str ${pin}
        }
      } else {
        lappend arg_set ${var}
      }
    }
  }


# need work around a bug only if:
# 1. pins are outputs
# 2. one of them inside parent of another
  # 3. if fin
  set work_around_connection 0
  if {[llength ${pins_to_connect}] == 2} {
    lassign ${pins_to_connect_str} pina pinb
# Remove in release:
# puts "set pina \[get_bd_pins $pina\]"
# puts "set pinb \[get_bd_pins $pinb\]"
    set pina [vsi::connected_out_if_in ${pina}]
    set pinb [vsi::connected_out_if_in ${pinb}]
# Remove in release:
# puts "0xa084bf44"
    set pina_parent [par_cell ${pina}]
    set pinb_parent [par_cell ${pinb}]
    set pina_is_output [is_output ${pina}]
    set pinb_is_output [is_output ${pinb}]
    #try to get input vsi::find_connected_orself
    set pina_in_b_hier [is_in_target_hier ${pina} ${pinb_parent}]
    set pinb_in_a_hier [is_in_target_hier ${pinb} ${pina_parent}]
# Remove in release:
# puts "0xa56ac0b7 ${pina_in_b_hier}"
# puts "0x7bb8b945 ${pinb_in_a_hier}"
    if {([is_output ${pina}] && [is_output ${pinb}]) &&
        (${pina_in_b_hier} || ${pinb_in_a_hier})} {
      set work_around_connection 1
    }
  }

  if {${work_around_connection} != 1} {
    eval "::connect_bd_net [flatten ${arg_set}] [flatten ${pins_to_connect}]"
  } else {
    # work around
# Remove in release:
# puts "0xd84e036c : work around"
    set pins_to_connect_str [get_end_poin_pins ${pina} ${pinb}]
    lassign ${pins_to_connect_str} source_pin destination_pin
    connect_in_hier $source_pin $destination_pin [list ${arg_set}]
  }

}
}
proc vsi::find_connected_orself {pin} {
  set pin [get_bd_pins -quiet ${pin}]
  set connected [find_connected ${pin}]
  if {[llength ${connected}] == 1} {
    return ${connected}
  }
  return ${pin}
}

# ------------------------------------------------------------------------------
# connected_out_if_in -- get pin end point pin in case if target is input
# ------------------------------------------------------------------------------
proc vsi::connected_out_if_in {pin} {
  set connected_to_pin [vsi::find_connected_orself ${pin}]
  if {[is_input ${pin}] && ${connected_to_pin} != ""} {
    return ${connected_to_pin}
  }
  return ${pin}
}

# ------------------------------------------------------------------------------
# same_signal_pin_list -- get list of pins which is has
#  the same logical connection
# ------------------------------------------------------------------------------
proc same_signal_pin_list {pin} {
    set pin [get_bd_pins ${pin}]
    set stop_at_ip "0"
    set stop_at_intcnct "0"
    set direction "AUTO"
    set return_pairs 0
    set reverse "0"
    set pin_path_strait [get_pin_path ${pin}]
    set pin_path_reverse [get_reverse_pin_path ${pin}]
    set path ""
    set joined ""
    foreach cur_pin_path_strait $pin_path_strait {
      foreach cur_pin_path_reverse $pin_path_reverse {
        set joined "${pin} ${cur_pin_path_reverse} ${cur_pin_path_strait}"
        lappend path [flatten $joined]
      }
    }
    set path [flatten $joined]
    set path [lsort -unique ${path}]
    return ${path}
}

# ------------------------------------------------------------------------------
# connect_on_hier --
# ------------------------------------------------------------------------------
proc connect_in_hier {source_pin destination_pin {extra_args ""}} {
  startgroup
  if { [is_intf $source_pin] } {
    set connect_proc vsi::xil_connect_bd_intf_net
    set build_unique_proc build_unique_get_bd_intf_pins
    set create_pin_proc create_bd_intf_pin
    set get_pin_proc get_bd_intf_pins
  } else {
    set connect_proc vsi::xil_connect_bd_net
    set build_unique_proc build_unique_get_bd_pins
    set create_pin_proc create_bd_pin
    set get_pin_proc get_bd_pins
  }

  set source_pin [ ${get_pin_proc} ${source_pin}]
  set destination_pin [ ${get_pin_proc} ${destination_pin}]

  set name_of_pin [get_property NAME ${destination_pin}]
  if { [is_intf $source_pin] } {
    set vlnv [get_property VLNV ${destination_pin}]
    set mode [get_property Mode ${destination_pin}]
  } else {
    set dir_of_pin [get_property DIR ${destination_pin}]
  }

  # Just to avoid stucking if aper some bug
  set i 100
  set dest_par [par_cell ${destination_pin}]
  while {$i > 0} {
    set source_pin_cell [par_cell ${source_pin}]
    set current_dest_cell [par_cell ${source_pin_cell}]
    if { ${current_dest_cell} == "/" || ${current_dest_cell} == "" ||
         ${current_dest_cell} == ${dest_par} } {
      # Remove in release:
      ${connect_proc} ${source_pin} ${destination_pin} ${extra_args}

      break
    }
    set possible_dest_pin ${current_dest_cell}/${name_of_pin}
    #check if pin exist and already connected to destination
    set current_dest_pin [ ${get_pin_proc} -quiet ${possible_dest_pin}]
    if {${current_dest_pin} != ""} {
        if {[find_connected ${current_dest_pin}] == ""} {
          set current_dest_pin ${current_dest_pin}
        } else {
           set current_dest_pin ""
        }
    }

    if { ${current_dest_pin} == "" } {
      if { [is_intf $source_pin] } {
        set current_dest_pin [build_unique_get_bd_pins ${possible_dest_pin}]
        set current_dest_pin [create_bd_intf_pin -mode ${mode} \
                                  -vlnv ${vlnv} ${current_dest_pin}]        
      } else {
        set current_dest_pin [build_unique_get_bd_pins ${possible_dest_pin}]
        set current_dest_pin [create_bd_pin -dir ${dir_of_pin} ${current_dest_pin}]
      }

    }

    set source_pin [ ${get_pin_proc} ${source_pin} ]
    ${connect_proc} ${source_pin} ${current_dest_pin} ${extra_args}
    set source_pin ${current_dest_pin}
    incr i -1
  }
  endgroup
}

proc vsi::xil_connect_bd_net {source_pin dest_pin extra_args} {
  set source_pin "\[get_bd_pins ${source_pin}\]"
  set dest_pin "\[get_bd_pins ${dest_pin}\]"
  set args [flatten ${extra_args}]
  eval "::connect_bd_net ${source_pin} ${dest_pin} ${args}"
}

proc vsi::xil_connect_bd_intf_net {source_pin dest_pin extra_args} {
  set source_pin "\[get_bd_intf_pins ${source_pin}\]"
  set dest_pin "\[get_bd_intf_pins ${dest_pin}\]"
  set args [flatten ${extra_args}]
  eval "::connect_bd_intf_net ${source_pin} ${dest_pin} ${args}"
}

#return path from comare_path_list which is closest to target_path
proc closest_path {comare_path_list target_path {delim "/"}} {
  set longest_common ""
  # Take first element by default
  set closest [lindex ${comare_path_list} 0]
  foreach comare_path $comare_path_list {
    set common "[common_string_part $comare_path $target_path]"
    set split_common [split $common  ${delim}]
    if {([llength ${split_common}] > [llength ${longest_common}])} {
      set longest_common ${split_common}
      set closest ${comare_path}
    }
  }
  return ${closest}
}

# ------------------------------------------------------------------------------
# Search closest pin's --
# ------------------------------------------------------------------------------
proc get_end_poin_pins {pina pinb} {
  set delim "/"
  set pin_list_a [same_signal_pin_list $pina]
  set pin_list_b [same_signal_pin_list $pinb]
  set longest_common ""
  # Search deepest common path in which pin_a & pin_b
  #    and not in the same level of hierarchy
  foreach cur_pin_a $pin_list_a {
    set split_pin_a [split $pina  ${delim}]
    foreach cur_pin_b $pin_list_b {
      set common "[common_string_part $cur_pin_a $cur_pin_b]"
      set split_pin_b [split $pinb  ${delim}]
      set split_common [split $common  ${delim}]
      if {([llength ${split_common}] > [llength ${longest_common}]) &&
          [llength ${split_pin_b}] != [llength ${split_pin_a}]
      } {
        set longest_common ${split_common}
      }
    }
  }

  set common "[join ${longest_common} ${delim}]/"
  set common_len [string len ${common}]
  set filtred_pin_a [filter_list_get_remain ${pin_list_a} ${common}]
  set filtred_pin_b [filter_list_get_remain ${pin_list_b} ${common}]
  set shortest_path_len -1
  set deepest_path 0
  set pair "NULL"
  # Search closest pins (not in the same hierarchy), and deepest in hierarchy
  foreach cur_pin_a $filtred_pin_a {
    set split_pin_a [split $cur_pin_a ${delim}]
    set len_pin_a [llength ${split_pin_a}]
    foreach cur_pin_b $filtred_pin_b {
      set split_pin_b [split $cur_pin_b ${delim}]
      set len_pin_b [llength ${split_pin_b}]
      set total_path_len [expr ${len_pin_b} + ${len_pin_a}]
      set deeper_pin [expr max(${len_pin_b}, ${len_pin_a})]
      if {((${total_path_len} < ${shortest_path_len}) &&
           (${deeper_pin} > ${deepest_path})) ||
           (${shortest_path_len} == -1)} {
        set deepest_path ${deeper_pin}
        set shortest_path_len ${total_path_len}
        # set deeper as target
        set fullpath_a "${common}${cur_pin_a}"
        set fullpath_b "${common}${cur_pin_b}"

        set pair [list ${fullpath_a} ${fullpath_b}]
        # pin which is more deeper is target
        if {${len_pin_a} < ${len_pin_b}} {
          set pair [lreverse ${pair}]
        }
      }
    }
  }
# Remove in release:
# puts "0xd06f0097 : ${pair} "
  return ${pair}
}

# ------------------------------------------------------------------------------
# filter_list_get_remain --
# ------------------------------------------------------------------------------
proc filter_list_get_remain {target_string_list compare_str} {
  set filtred_string_list ""
  foreach target_string $target_string_list {
    if {[regexp ${compare_str}(.*) ${target_string} {} remain]} {
      lappend filtred_string_list $remain
    }
  }
  return ${filtred_string_list}
}

# Utils
# function to build unique name
# get_function - function to get object name of which try to get
# default_name - default name for name which will returned
# propose_name - name on which based returned string
proc build_unique_prototype {get_function default_name {propose_name ""}} {
  if { ${propose_name} == "" } {
    set propose_name ${default_name}
  }
  set ret_name ${propose_name}

  set name_patern "${propose_name}_%d"
  set inst_number 0
  while {([lsearch [${get_function}] ${ret_name}] != -1) ||
    [${get_function} ${ret_name}] != ""} {
      set ret_name [format ${name_patern} ${inst_number}]
      incr inst_number
  }
  return ${ret_name}
}

proc build_unique_bd_name {{bd_name ""}} {
  set unique_bd_name [build_unique_prototype get_bd_design default_bd ${bd_name}]
  return ${unique_bd_name}
}

proc build_unique_partition_defs_name {{name ""}} {
  return [build_unique_prototype get_partition_defs part_def_block ${name}]
}

proc build_unique_reconfig_module_name {{name ""}} {
  return [build_unique_prototype get_reconfig_module rec_module_n ${name}]
}

proc build_unique_bd_cell_name {{name ""}} {
  return [build_unique_prototype get_bd_cells inst_0 ${name}]
}

proc build_unique_get_bd_pins {{name ""}} {
  return [build_unique_prototype get_bd_pins "" ${name}]
}

proc build_unique_get_bd_intf_pins {{name ""}} {
  return [build_unique_prototype get_bd_intf_pins "" ${name}]
}

# ------------------------------------------------------------------------------
# connection_list --
# ------------------------------------------------------------------------------
proc get_connection_list {target_cell} {
  set mixed_pins [list [get_bd_pins -of_objects ${target_cell}] \
                       [get_bd_intf_pins -of_objects ${target_cell}]]
  set connection_list ""
  foreach pin_list ${mixed_pins} {
    foreach pin ${pin_list} {
      set connected_pin [find_bd_objs -relation connected_to ${pin}]
      if {${connected_pin} != ""} {
        set class [get_property CLASS ${pin}]
        if {${class} == ""} {
          error "\[id: 0x2510398d\] Brocken class for pin: $pin"
        }
        set connection [list ${pin} ${connected_pin} ${class}]
        push connection_list ${connection}
      }
    }
  }
  return ${connection_list}
}

# ------------------------------------------------------------------------------
# reconnection_by_lists --
# ------------------------------------------------------------------------------
proc reconnection_by_lists {connections} {
  set connections [flatten ${connections}]
  foreach {pin connected_pin class} ${connections} {
    set get_function [format "get_%s" ${class}]
    set pin [${get_function} ${pin}]
    set connected_pin [${get_function} ${connected_pin}]
    puts "${get_function} ${pin} ${connected_pin}"
    set connect_function "connect_bd_net"
    if {(${class} == "bd_intf_pin") || (${class} == "bd_intf_port")} {
      set connect_function "connect_bd_intf_net"
    }
    ${connect_function} -quiet ${pin} ${connected_pin}
  }
}

# ------------------------------------------------------------------------------
# is_input --
# ------------------------------------------------------------------------------
proc is_input {pin} {
  set pin [get_bd_pins ${pin}]
  set direction [get_property -quiet DIR ${pin}]
  if {${direction} == "I"} {
    return 1
  }
  return 0
}

# ------------------------------------------------------------------------------
# is_intf --
# ------------------------------------------------------------------------------
proc is_intf {pin} {
  set pin [get_bd_intf_pin -quiet ${pin}]
  if { ${pin} == "" } {
    return 0
  }
  return 1
}

# ------------------------------------------------------------------------------
# is_pin --
# ------------------------------------------------------------------------------
proc is_pin {pin} {
  set pin [get_bd_pin -quiet ${pin}]
  if { ${pin} == "" } {
    return 0
  }
  return 1
}

# ------------------------------------------------------------------------------
# is_output --
# ------------------------------------------------------------------------------
proc is_output {pin} {
  set pin [get_bd_pins ${pin}]
  set direction [get_property -quiet DIR ${pin}]
  if {${direction} == "O"} {
    return 1
  }
  return 0
}

# ------------------------------------------------------------------------------
# is_master -- Check if target interface is master
# ------------------------------------------------------------------------------
proc is_master { interface } {
  set class [get_property -quiet Mode ${interface}]
  if { ${class} == "Master" } {
    return 1
  }
  return 0
}

# ------------------------------------------------------------------------------
# is_slave -- Check if target interface is slave
# ------------------------------------------------------------------------------
proc is_slave {interface} {
	set mode [get_property -quiet MODE ${interface}]
	if {${mode} == "Slave"} { return 1 }
	return 0
}

# ------------------------------------------------------------------------------
# getPropertyForceValue -- get property variable and set default value
#    if property value is empty.
#  property_name - property name
#  target_object - target object
#  force_to_value - which value should be set if returned value is empty
# ------------------------------------------------------------------------------
proc getPropertyForceValue {property_name target_object {force_to_value 0}} {
	set property_value [get_property -quiet ${property_name} ${target_object}]
	if {${property_value} == ""} {
		set property_value ${force_to_value}
	}
	return ${property_value}
}

namespace eval vsi {
namespace eval project_fingerprint {

# ------------------------------------------------------------------------------
# exclude_regexp_str -- Build regular expression to exclude
#   properties from report.
# extra_exclude_l: list of optional properties to exclude
# ------------------------------------------------------------------------------
proc exclude_regexp_str { {extra_exclude_l ""} } {
    # Defaul properties which contain a paths
    set exclude_prop [list IP_DIR IP_FILE SCOPE SCREENSIZE \
                           LOCATION ROOT_DIRECTORY XML_FILE_NAME ]
    # append user option to exclude into list
    foreach extra_exclude ${extra_exclude_l} {
        lappend exclude_prop $extra_exclude
    }
    # Build regext string
    append exclude_regexp "^("
    foreach prop ${exclude_prop} {
        append exclude_regexp [format "(?!%s)" ${prop}]
    }
    append exclude_regexp ".)*\$"

    return ${exclude_regexp}
}

# ------------------------------------------------------------------------------
# is_vsi_hls -- Check if input objec is HLS
# ------------------------------------------------------------------------------
proc is_vsi_hls { object } {
    set ipdef [get_property -quiet IPDEF $object]
    set vlnv [get_property -quiet VLNV $object]
    if { [string first "vsi.com:hls" ${ipdef}] == 0 || 
         [string first "vsi.com:hls" ${vlnv}] == 0  } {
        return 1
    }
    return 0
}

# ------------------------------------------------------------------------------
# report_props_to_file -- Write properties of object into a file
# ------------------------------------------------------------------------------
proc report_props_to_file { object finger_print_file } {
    # Generate regexp to remove some of the options
    if { [ is_vsi_hls $object ] } {
        # Remove Core revision for HLS blocks
        set exclude_regexp [exclude_regexp_str "CORE_REVISION" ]
    } else {
        set exclude_regexp [exclude_regexp_str]
    }
    # Write properties to file
    report_property -quiet ${object} \
                    -regexp ${exclude_regexp} \
                    -file ${finger_print_file} -append; list
   
}

# ------------------------------------------------------------------------------
# collect_properties -- Generate file which contain conections, settings,
#   parameters, e.t.c. for objects in the current project
# ------------------------------------------------------------------------------
proc collect_properties { finger_print_file } {
    # List of functions which use for getting objects in current project
    set get_functions [list \
        get_bd_addr_segs get_bd_intf_ports get_bd_designs get_bd_nets \
        get_bd_intf_pins get_bd_ports get_bd_intf_nets get_bd_cells \
        get_bd_addr_spaces get_bd_pins get_ips]
    # Iterate through functions
    foreach function $get_functions {
        set invalid_proc 0
        # Try to get object hierarchicaly
        set invalid_proc [catch {
            set objects_list [${function} -quiet -hierarchical]
        }]

        # Some of the getting functions cannot be called with option "hier"
        # try to call it only if previous acquire fail
        if { ${invalid_proc} } {
            set invalid_proc [
                catch {
                    set objects_list [${function} -quiet]
                } 
            ]
        }

        if { !${invalid_proc} } {
            # Build report for each object and write into a file
            foreach object ${objects_list} {
                report_props_to_file ${object} ${finger_print_file}
            }
        }
    }
}

# ------------------------------------------------------------------------------
# project_id_file_path -- Generate path to id file
# ------------------------------------------------------------------------------
proc project_id_file_path { } {
  set project_path [get_property DIRECTORY [current_project]]
  return [format "%s/%s.fpf" $project_path  [current_project] ]
}

# ------------------------------------------------------------------------------
# project_id_file_path -- Generate id file. Returns file which was generated
# ------------------------------------------------------------------------------
proc generate_project_id_file { } {
  set finger_print_file [project_id_file_path]
  file delete ${finger_print_file}
  vsi::project_fingerprint::collect_properties ${finger_print_file}
  return ${finger_print_file}
}

}}; # namespace vsi::project_fingerprint

# ------------------------------------------------------------------------------
# hier_ip_name -- Split string into two elements: path to ip and ip name.
#  returns list of strings: path to ip and ip name 
# ------------------------------------------------------------------------------
proc vsi::utils::hier_ip_name { ip_location } {
  # Didnot using built in file command to avoid returns not IPI pathes ("." etc)
  set splited_path [split $ip_location "/"]
  # Peek up to last element and join as IPI path
  set require_hier [join [lrange $splited_path 0 end-1] "/"]
  if { $require_hier == "" } {
    set require_hier "/"
  }

  # Peek the last element and assume as IP name
  set require_name [lindex $splited_path end]
  if { $require_name == "" } {
    error "Broken ip path: $ip_location"
  }

  return [list $require_hier $require_name]
}

# ------------------------------------------------------------------------------
# hier_ip_name -- Place AI-e IP in to right place.
#    script which contain all AI-e information should be sourced before
#    calls this function.
# ------------------------------------------------------------------------------
proc vsi::aie::place_ai { ip_location } {
  lassign [vsi::utils::hier_ip_name $ip_location] require_hier require_name
  # Instatiate AI-e IP
  set ai_ip [ai_engine_0::creat_ai_core]
  # Move ai-e to requre hierarcy
  move_bd_cell [get_bd_cells ${require_hier}] ${ai_ip}
  set ai_ip [get_bd_cells ${ai_ip}]
  set current_ai_ip_name [get_property name $ai_ip]
  # Rename if ip was plase with not reqiered name
  if {$current_ai_ip_name != $require_name} {
    set_property name ${require_name} $ai_ip
  }
}

# ------------------------------------------------------------------------------
# Generate interface properties of noc cell
# ------------------------------------------------------------------------------
proc store_noc_intf_option { chan noc_bd_cell } {
	set pins_proc_list ""
	set pins_and_intf_list [list \
			[get_bd_pins -of $noc_bd_cell -filter {INTF!~"TRUE" && TYPE=="clk"}] \
			[get_bd_intf_pins -of $noc_bd_cell -filter {CONFIG.PROTOCOL=="AXI4"}]]
	foreach pins_or_intf_list ${pins_and_intf_list} {
		foreach pin_intf ${pins_or_intf_list} {
			# Filter pins and intf_pins Heare
			lappend pins_proc_list ${pin_intf}
		}
	}
	
	foreach noc_interface ${pins_proc_list} {
		if { [is_pin $noc_interface] } {
			set get_function "get_bd_pins"
			set property_list [list ASSOCIATED_BUSIF]
		} else {
			set get_function "get_bd_intf_pins"
			if { [is_master $noc_interface] } {
				set property_list [list CATEGORY ]
			} else {
				set property_list [list CATEGORY CONNECTIONS]
			}
		}
		set noc_interface_name [get_property NAME $noc_interface]
		set interface_props [::vsi::__::property_list_of $noc_interface $property_list]

		plat_tcl_puts $chan  "set_property -dict \[list $interface_props \] \[${get_function} \$vsi_temp/${noc_interface_name}\]"
	}
}

# Check if interface is axi4 mm
proc is_axi_mm { interface } {
  set vlnv [get_property -quiet VLNV ${interface}] 
  if { [string first xilinx.com:interface:aximm_rtl: ${vlnv} ] == 0 } {
    return 1
  }
  return 0
}

# Check if interface is axi4 stream
proc is_axi_stream { interface } {
  set vlnv [get_property -quiet VLNV ${interface}] 
  if { [string first xilinx.com:interface:axis_rtl: ${vlnv} ] == 0 } {
    return 1
  }
  return 0
}

# Get an interface connected outside of a hierarchy to target interface.
# Returns himself if the target interface does not have out connection 
# or not if the target interface not on the edge of hierarchy.
proc on_edge_connected_intf { interface } {
  set parent [par_cell ${interface}]
  # Check if interface on the edge of an hierarchy
  if { ![is_ip ${parent}] && ${parent} != "/" } {
    set start_from_interface [find_bd_objs \
         -thru_hier -stop_at_interconnec -relation connected_to ${interface} ]
  } else {
    set start_from_interface ${interface}  
  }
  
  if { ![llength ${start_from_interface}] } {
    set start_from_interface ${interface}
  }
  return ${start_from_interface}
}

# ------------------------------------------------------------------------------
# Getting the line number of executing code
#
# Could use in pair:
## ------------------------------------------------------------------------------
## Stop system build on trigger
## ------------------------------------------------------------------------------
## proc detect_some_ip { } {
## 	set call_from_frame [info frame ]
## 	set condition [get_bd_cell -quiet /some/ip]
## 	if { $condition != "" } {
## 		puts "Detected at: [linenumber ${call_from_frame}]"
## 	}
## }
# ------------------------------------------------------------------------------
proc linenumber { {frame_info ""} } {
	set result "{Error in line deffinition}"
	catch {
		# Could be call from plain script execution
		if { ${frame_info} == "" } {
			set frame_info [info frame ]
			# Up from if frame
			incr frame_info -1
      # Up from catch frame
      incr frame_info -1			
		}
    # Up from parrent or this proc if frame is not define
		incr frame_info -1
		set result [dict get [info frame $frame_info] line] 
	}

	return $result
}

# ------------------------------------------------------------------------------
# include_common_intf_ddr -- include DDR address segment into commn interface 
#     address spaces. Assume the DDR address segment has offset 0.
# ------------------------------------------------------------------------------
proc include_common_intf_ddr {} {
    foreach common_ip [get_common_interface] {
        # Obtain DMA interfaces
        set intfs [get_bd_intf_pins -of ${common_ip} -filter {NAME=~DMA_*}]
        foreach intf ${intfs} {
            set intf_addr_spaces [get_bd_addr_spaces -quiet -of ${intf}]
            # Only segments with offset 0
            set ddr_segment [get_bd_addr_segs -quiet -of ${intf_addr_spaces} \
                    -excluded -filter {OFFSET==0}]
            include_bd_addr_seg -quiet ${ddr_segment}
        }
    }
}