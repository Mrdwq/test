
# ! Should be apply only for interfaces !
# Place termination IP, set parameters for interfaces based on requiers and connect it.
proc terminate_interfaces { interface_list { parent_hierarchy ""} } {
    set terminated_decoupler_path "${parent_hierarchy}/terminate_intf_ip"
    set termin_ip [create_bd_cell -quiet -type ip -vlnv xilinx.com:ip:pr_decoupler ${terminated_decoupler_path}]
    set cdc_stages 2
    set decoup_params [vsi::decoupler::get_properties_dic_list ${interface_list} ${cdc_stages}]
    set_property -dict ${decoup_params} ${termin_ip}

    foreach interface ${interface_list} {
        set connect_to ""

        set intf_name [get_property NAME ${interface}]
        if { [vsi::decoupler::is_pin ${interface}] } {
            set pin_type [get_property TYPE ${interface}]
            set post_fix "_[vsi::decoupler::type_to_signal ${pin_type}]"
        } else {
            set post_fix ""
        }

        set parent ${termin_ip}
        # Use interface to which termination IP will be connected #
        #  pin/interface on hierarchy lead to an error becouse master to master
        #  connection not allow in Vivado.
        set source_intf [vsi::decoupler::get_param_source ${interface}]
        if { [is_master ${source_intf}] } {
            set connect_to "${parent}/rp_${intf_name}${post_fix}"
        } elseif { [is_slave ${source_intf}] } {
            set connect_to "${parent}/s_${intf_name}${post_fix}"
        } elseif { [is_input ${source_intf}] } {
            set connect_to "${parent}/s_${intf_name}${post_fix}"
        } elseif { [is_output ${source_intf}] } {
            set connect_to "${parent}/rp_${intf_name}${post_fix}"
        } else {
            error "Current type cannot be terminated ${interface}"
        }

        if { ${connect_to} != "" } {
            if { [vsi::decoupler::is_pin ${interface}] } {
                connect_bd_net ${interface} [get_bd_pins ${connect_to}]
            } else {
                set connect_to [get_bd_intf_pins ${connect_to}]
                connect_bd_intf_net ${interface} ${connect_to}
                set target_interface_clk [associated_pin ${interface} clk]
                set dest_interface_clk [associated_pin ${connect_to} clk]
                safe_connect_bd_net ${target_interface_clk} ${dest_interface_clk}
            }
        }
        connect_open_clocks ${termin_ip}
    }
}

# Try to connect all clocks together to prevent validation error
proc connect_open_clocks { ip_cell } {
  set clocks [get_bd_pins -filter TYPE==clk -of_objects ${ip_cell}]
  set ref_clk [lindex ${clocks} 0]
  foreach pin ${clocks} {
    connect_bd_net -quiet ${pin} ${ref_clk}
  }
}
# hier_to_pr -- procedure to convert input hierarchy into pr.
# returns partition definition which was created or into which hierarchy was added
# hier_to_pr ${system} zynq_pl vsi_system_zynq_pl_gpio_hir1
proc hier_to_pr {hier_name {partition_defs_name ""} {input_bd_name ""}} {
  enable_pr
  set hier [get_bd_cells ${hier_name}]
  # pass required bd name because previews bd not visible after converting it to PR cell
  set new_bd_design [hier_to_bd ${hier} ${input_bd_name}]
  set new_bd_file ${new_bd_design}.bd
  set_property synth_checkpoint_mode None [get_files ${new_bd_file}]
  # target partition_defs not exist
  set partition_defs [get_partition_defs ${partition_defs_name}]
  set defs_num [llength ${partition_defs}]
  if {!${defs_num}} {
    set partition_defs [build_unique_partition_defs_name ${partition_defs_name}]
    set partition_defs [create_partition_def -name ${partition_defs} \
        -module ${new_bd_design}]
  }

  set reconfig_module_name [build_unique_reconfig_module_name ${new_bd_design}]
  set new_reconfig_module [create_reconfig_module -name ${reconfig_module_name} \
      -partition_def ${partition_defs} -define_from ${new_bd_design}]
  return ${partition_defs}
}

# intf_prop_transfer ${system_bd} ${hier_in_system} ${ported_bd}
proc intf_prop_transfer {system_bd hier_in_system ported_bd} {
  ### Debug ###
  puts "
set system_bd $system_bd \n
set hier_in_system $hier_in_system \n
set ported_bd $ported_bd \n
  "
  #############
  open_bd_design ${ported_bd}
  set ported_intf_port_list [get_bd_intf_ports]
  open_bd_design ${system_bd}
  set intf_dict_list ""
  foreach ported_intf ${ported_intf_port_list} {
    set orig_interface [get_bd_intf_pins ${hier_in_system}/${ported_intf}]
    set connected_to [find_bd_objs -relation connected_to \
        ${orig_interface} -stop_at_interconnect -thru_hier]
    set prop_list [list_property -quiet ${connected_to} -regexp "CONFIG.*"]
    set property_dict_list ""
    foreach property ${prop_list} {
      set propvalue [get_property ${property} ${connected_to}]
      lappend property_dict_list [list ${property}] [list ${propvalue}]
    }
    lappend intf_dict_list ${property_dict_list}
  }
  open_bd_design ${ported_bd}
  set i 0
  foreach ported_intf ${ported_intf_port_list} {
    set ported_intf_prop [lindex ${intf_dict_list} $i]
    if {${ported_intf_prop} != ""} {
      puts "try!!"
      puts "${ported_intf_prop} ${ported_intf}"
      set_property -dict ${ported_intf_prop} ${ported_intf}
    }
    incr i
  }
  save_bd_design
}

# ------------------------------------------------------------------------------
# set_offset_range --
# ------------------------------------------------------------------------------
proc set_offset_range {target_segment_name orig_offset orig_range} {
  set target_segment [get_bd_addr_segs ${target_segment_name}]
  if {[llength ${target_segment}] && [llength ${target_segment}] &&
      [llength ${target_segment}]} {
    # set minimal memory range
    set min_range 4K
    assign_bd_address ${target_segment} -range ${min_range} \
      -offset ${orig_offset}
    assign_bd_address ${target_segment} -range ${orig_range} \
      -offset ${orig_offset}
  }
}

# ------------------------------------------------------------------------------
# addres_transfer --
# transfer addresses from original hierarchy on which based new bd
# addres_transfer ${system_bd} ${hier_in_system} ${ported_bd}
#  set system_bd zynq_pl
#  set hier_in_system /zynq_pl
#  set ported_bd bd_zynq_pl
# ------------------------------------------------------------------------------
proc addres_transfer {system_bd hier_in_system ported_bd} {
  open_bd_design ${system_bd}
  set hier_in_system [get_bd_cells ${hier_in_system}]
  set main_system_adr_segments [get_addr_property ${hier_in_system}]
  open_bd_design ${ported_bd}
  assign_bd_address -quiet
  set top [get_bd_cells /]
  set ported_adr_segments [get_addr_property ${top}]
  # delete addresses before assigning to avoid overlapping
  delete_bd_objs [get_bd_addr_segs]
  foreach original_segment ${main_system_adr_segments} {
    lassign ${original_segment} orig_interface orig_segment orig_offset orig_range
    foreach ported_segment ${ported_adr_segments} {
      lassign ${ported_segment} port_interface port_segment port_offset port_range
      set port_name_recreate "${hier_in_system}${port_interface}"
      if {${orig_interface} == ${port_name_recreate}} {
        set_offset_range ${ported_segment} ${orig_offset} ${orig_range}
      }
    }
  }
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

# get_addr_property --
# returned list of values list as {interface_name segment_name offset range}
proc get_addr_property {target_hier} {
  set addr_config_list ""
  # get adrress space for selected IP
  set interface_list [get_bd_intf_pins -of_objects ${target_hier} -hierarchical]
  foreach interface ${interface_list} {
    set cell [get_bd_cells -quiet -of_objects ${interface}]
    if {[is_ip ${cell}]} {
      set addr_seg [get_bd_addr_segs -of_objects ${interface}]
      if {![is_master ${interface}]} {
      set addr_seg [get_bd_addr_segs -of_objects ${addr_seg}]
      }
      foreach segment $addr_seg {
        if {[llength ${segment}]} {
          set offset [get_property OFFSET ${segment}]
          set range [get_property RANGE ${segment}]
          lappend addr_config_list [list ${interface} \
              ${segment} ${offset} ${range}]
        }
      }
    }
  }
  return ${addr_config_list}
}

# hier_to_bd -- procedure to convert input hierarchy into new block diagram
proc hier_to_bd {hier_name {input_bd_name ""}} {
  set hier [get_bd_cells ${hier_name}]
  if {${input_bd_name} == ""} {
    set bd_name [string map {"/" "_" \{ "" \{ "" } ${hier}]
    set bd_name "bd_[string range ${bd_name} 1 end]"
    set bd_name [build_unique_bd_name ${bd_name}]
  } else {
    set bd_name ${input_bd_name}
  }

  set bd_name_copy ${bd_name}
  save_bd_design
  validate_bd_design -force
  set system_bd [current_bd_design .]
  create_bd_design -cell ${hier} ${bd_name}
  set ported_bd [current_bd_design .]
### Debug ###
puts "
set system_bd $system_bd \n
set hier $hier \n
set ported_bd $ported_bd \n
lassign \[list ${system_bd} ${hier} ${ported_bd}\] system_bd hier_in_system ported_bd
"
#############
  intf_prop_transfer ${system_bd} ${hier} ${ported_bd}
  addres_transfer ${system_bd} ${hier} ${ported_bd}
  save_bd_design
  validate_bd_design -force
  save_bd_design
  close_bd_design ${ported_bd}
  open_bd_design ${system_bd}
  return ${bd_name_copy}
}

proc enable_pr {} {
  if {[get_param project.enablePRFlowIPI] != 1} {
    set_param project.enablePRFlowIPI 1
    #PR HD parameters
    set_param bitstream.enablePR 2341
    if { [version -short] == "2019.2" } {
      set_param hd.enablePR 2591
    } else {
      set_param hd.enablePR 1234
    }

  }
  set_property PR_FLOW true [current_project]
}

# ------------------------------------------------------------------------------
# pr_replace --
# ------------------------------------------------------------------------------
proc pr_replace {target_hierarchy partial_definition} {
  set pr_cell_name [build_unique_cell_name ${target_hierarchy}]
  set system_cell [create_bd_cell -type module \
    -reference ${partial_definition} ${pr_cell_name}]
  replace_bd_cell -quiet ${target_hierarchy} ${system_cell}
  set cell_name [get_property NAME ${target_hierarchy}]
  delete_bd_objs -quiet [get_bd_cells ${target_hierarchy}]
  set_property NAME ${cell_name} ${system_cell}
}

# ------------------------------------------------------------------------------
# write_pr_bitstream --
# ------------------------------------------------------------------------------
proc write_pr_bitstream {impl_name bitstream_dir} {
  set configuration [get_property PR_CONFIGURATION ${impl_name}]
  set configuration [get_pr_configurations ${configuration}]
  set cell_rms [get_property PARTITION_CELL_RMS ${configuration}]

  open_impl_design ${impl_name}
  # Generate wrapper if not exist yet
  set bitstream_name [current_project]
  set bitstream_path [format "%s/%s.bit" ${bitstream_dir} ${bitstream_name}]
  set bitstream_exist [file exist ${bitstream_path}]
  if {${bitstream_exist} == 0} {
    write_bitstream -force -no_partial_bitfile ${bitstream_path}
  }
  foreach parttition_cell ${cell_rms} {
    lassign [split ${parttition_cell} ":"] partial_reconfig_cell current_module
    # Remove top cell name and hierarchy name which placed in build time
    # set partial_reconfig_cell_split [split ${partial_reconfig_cell} "/"]
    # set system_path_in_vsi_list [lrange ${partial_reconfig_cell_split} 1 end-1]
    # set system_path_in_vsi [join ${system_path_in_vsi_list} "_"]
    set bitstream_name "${current_module}"
    set bitstream_path [format "%s/%s.bit" ${bitstream_dir} ${bitstream_name}]
    set bitstream_exist [file exist ${bitstream_path}]
    if {${bitstream_exist} == 0} {
      write_bitstream -force -cell ${partial_reconfig_cell} ${bitstream_path}
    }
  }

  return ""
}

# namespace eval vsi::generation {
  # ------------------------------------------------------------------------------
  # bif_generate --
  # ------------------------------------------------------------------------------
  proc bin_generate {bitstream_path arch} {
    set splitChar "/"
    # Hard coded for LINUX.
    set bitstream_path_as_list [split ${bitstream_path} ${splitChar}]
    set bitstream_dir_as_list [lrange ${bitstream_path_as_list} 0 end-1]
    set bitstream_dir [join ${bitstream_dir_as_list} ${splitChar}]
    set bitstream_name [lindex ${bitstream_path_as_list} end]

    set bif_file_path [bif_generate ${bitstream_dir} ${bitstream_name}]
    #-image %s -arch zynqmp -process_bitstream bin
    set gen_command_format "bootgen -image %s -arch %s -o ${bitstream_dir}${bitstream_name}.bin -w"
    set bin_gen_command "[format ${gen_command_format} ${bif_file_path} ${arch}]"
    set current_dir [pwd]
    cd ${bitstream_dir}
    set gen_result [catch {
          eval "exec ${bin_gen_command}"

        }]
    cd ${current_dir}
    if {${gen_result}} {
      error "Fail in generation bit file. Try to generate it manually."
    }
    # file delete ${bif_file_path}
  }

  # ------------------------------------------------------------------------------
  # bif_generate --
  # ------------------------------------------------------------------------------
  proc bif_generate {bitstream_dir bitstream_name} {
    set bitstream_name_split [split ${bitstream_name} "."]
    set root_name [join [lrange ${bitstream_name_split} 0 end-1] "."]
    set bif_file_name "[format "%s.bif" ${root_name}]"
    set bif_file_path "[format "%s/%s" ${bitstream_dir} ${bif_file_name}]"

    set bif_file_descriptor [open ${bif_file_path} w]
    puts ${bif_file_descriptor} [bif_content ${bitstream_name}]
    close ${bif_file_descriptor}
    return ${bif_file_path}
  }

  proc bif_content {bit_file_name} {
      set bif_content_template "all: \{\n\t\[destination_device=pl\]%s\n\}"
    return [format ${bif_content_template} ${bit_file_name}]
  }
# }

# ------------------------------------------------------------------------------
# mk_bitstream_dir --
# ------------------------------------------------------------------------------
proc mk_bitstream_dir {{output_dir_name "out"}} {
  set current_project [current_project]
  set project_path [get_property DIRECTORY ${current_project}]
  set bitstream_dir "${project_path}/${output_dir_name}"
  set timestamp [exec date +%s]
  # Make backups if directory exist
  if {[file isdirectory ${bitstream_dir}]} {
    set new_name ${bitstream_dir}_${timestamp}
    file rename ${bitstream_dir} ${new_name}
  }

  file mkdir ${bitstream_dir}
  return ${bitstream_dir}
}

# ------------------------------------------------------------------------------
# get_partial_cells_list --
#  Returns Partial Reconfiguration Cell List
# ------------------------------------------------------------------------------
proc get_partial_cells_list {bd_design} {
  set partial_reconfig_cell_list ""
  set impl_top_inst "[format "%s_i" ${bd_design}]"
  foreach partition_def [get_partition_defs] {
    set modules [get_reconfig_modules -of_objects ${partition_def}]
    set partial_reconfig_bd_cell [vsi::get_bd_cells_of_module ${modules}]
    set partial_reconfig_cell "${impl_top_inst}${partial_reconfig_bd_cell}"
    lappend partial_reconfig_cell_list ${partial_reconfig_cell}
  }
  return ${partial_reconfig_cell_list}
}

# ------------------------------------------------------------------------------
# make_xdc_constarin -- create constrain file for current pr system
# ------------------------------------------------------------------------------
proc make_xdc_constarin { } {
  # Using of current, shouldn't changed in HW generation time.
  set bd_design [current_bd_design]
  set current_project [current_project]
  set project_path [get_property DIRECTORY ${current_project}]
  set project_name [get_property NAME ${current_project}]
  set xdcfile_folder "${project_path}/${project_name}.srcs/constrs_1/new"
  # Create xdc
  exec mkdir -p ${xdcfile_folder}
  set xdcfile_name "${xdcfile_folder}/${bd_design}_pblock_region.xdc"
  set xdcfile [open ${xdcfile_name} "w"]
  #
  set pd_pblocks_cell_list [get_partial_cells_list ${bd_design}]
  set partial_cell_number 1
  foreach pd_block $pd_pblocks_cell_list {
    set pblock_name "[join [split ${pd_block} "/"] "_"]_pblock"
    puts ${xdcfile} "create_pblock ${pblock_name}"
    puts ${xdcfile} "set_property CONTAIN_ROUTING 1 \[get_pblocks ${pblock_name}\]"
    puts ${xdcfile} "set_property EXCLUDE_PLACEMENT 1 \[get_pblocks ${pblock_name}\]"
    puts ${xdcfile} "add_cells_to_pblock \[get_pblocks ${pblock_name}] \[get_cells -quiet ${pd_block}]"
    set clocks_regions [vsi_get_pr_region_clocks ${partial_cell_number}]
    if {${clocks_regions} == ""} {
      error "id: \[0xc5e69bd2\] Number of clock region for current pblock - not specified."
    }

    foreach clocks_region $clocks_regions {
      puts ${xdcfile} "resize_pblock \[get_pblocks ${pblock_name}\] -add \{${clocks_region}\}"
    }
    puts ${xdcfile} "set_property RESET_AFTER_RECONFIG true \[get_pblocks ${pblock_name}\]"
    puts ${xdcfile} "# [string repeat "=" 78]"
    incr partial_cell_number
  }

  close ${xdcfile}
  puts ${xdcfile_name}
  add_files -fileset constrs_1 ${xdcfile_name}
  set_property target_constrs_file ${xdcfile_name} [current_fileset -constrset]
}

# ------------------------------------------------------------------------------
# bitstream_pr_flow --
# Usage:
#   Name                   Description
#   ----------------------------------
#   [-jobs]                Number of jobs
#                          Default: 1
#   [-arch]                Xilinx Architecture [zynq, zynqmp, fpga]
#                          Default: fpga
proc bitstream_pr_flow {args} {
  set jobs_num [dict_get_quiet $args "-jobs" 1]
  set arch [dict_get_quiet $args "-arch" fpga]
  set bitstream_dir [mk_bitstream_dir]

  set result ""
  set jobs_param ""
  if {${jobs_num} != ""} {
    set jobs_param " -jobs ${jobs_num}"
  }

  set proj_pr_flow [get_property PR_FLOW [current_project]]
  if {$proj_pr_flow == 1} {
     setup_pr_configuration -force -v
  }

  #implementation
  set implementation_run [get_runs impl_1]
  set child_impl_runs [get_runs -filter "PARENT==${implementation_run}"]
  set run_list ${implementation_run}
  foreach child_impl $child_impl_runs {
    lappend run_list $child_impl
  }

  foreach impl_run $run_list {
    eval "launch_runs $impl_run -to_step route_design ${jobs_param}"
    wait_on_run $impl_run
    write_pr_bitstream ${impl_run} ${bitstream_dir}
  }

  # bin_generate_list ${bitstream_path} ${arch}

  puts "Bit stream(s) paths : $${bitstream_dir}"
  # puts "[join ${bitstream_path} \n]"
}

# ------------------------------------------------------------------------------
# decoupler_cover -- place decoupler's on a line between static and pr cell
# ------------------------------------------------------------------------------
proc decoupler_cover {target_pr_cell {disable_number 0}} {
  set disable_out_decoupler 0
  set target_bd_cell [get_bd_cells /${target_pr_cell}]
  if {${target_pr_cell} == "/"} {
    error "Target cell error"
  }
  set pr_cel [cower_in_hier ${target_bd_cell}]
  # input part
  set decoupler_hier [par_cell ${pr_cel}]
  set decoupler_name input_decoupler
  set decoupler_path "${decoupler_hier}/${decoupler_name}"
  set decoupler [create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler ${decoupler_path}]
  set pr_input_pins [get_bd_pins -of_objects ${pr_cel} -filter {DIR==I && INTF!=TRUE}]
  set pr_slave_intf [get_bd_intf_pins -of_objects ${pr_cel} -filter {MODE==Slave}]
  set pr_pins [list ${pr_input_pins} ${pr_slave_intf}]
  set decoup_params [vsi::decoupler::get_properties_dic_list ${pr_pins}]
  lappend decoupler_list ${decoupler}
  set_property -dict ${decoup_params} ${decoupler}
  vsi::decoupler::intf_reconnect ${pr_pins} ${decoupler} "s_" "rp_"
  # output part
  if {!${disable_out_decoupler}} {
    set decoupler_hier [par_cell ${pr_cel}]
    set decoupler_name output_decoupler
    set decoupler_path "${decoupler_hier}/${decoupler_name}"
    set decoupler [create_bd_cell -type ip -vlnv xilinx.com:ip:pr_decoupler ${decoupler_path}]
    set pr_input_pins [get_bd_pins -of_objects ${pr_cel} -filter {DIR==O && INTF!=TRUE}]
    set pr_slave_intf [get_bd_intf_pins -of_objects ${pr_cel} -filter {MODE==Master}]
    set pr_pins [list ${pr_input_pins} ${pr_slave_intf}]
    set decoup_params [vsi::decoupler::get_properties_dic_list ${pr_pins}]
    set_property -dict ${decoup_params} ${decoupler}
    lappend decoupler_list ${decoupler}
    vsi::decoupler::intf_reconnect ${pr_pins} ${decoupler} "s_" "rp_"
  }
  # connect decoupler control
  vsi::decoupler::handle_decoupler_en ${decoupler_list}

  return ${pr_cel}
}

# ------------------------------------------------------------------------------
# cower_in_hier -- Place target cell into hierarchy with a same path as target
#     cell. Returns new place for bd_cell
# ------------------------------------------------------------------------------
proc cower_in_hier {bd_cell} {
  set bd_cell [get_bd_cells /${bd_cell}]
  set bp_cell_name [get_property NAME ${bd_cell}]
  set temporary_path_name [build_unique_bd_cell_name ${bd_cell}]
  set splited_temporary_name [split ${temporary_path_name} '/']
  set temporary_name [lindex ${splited_temporary_name} end]
  set_property NAME ${temporary_name} ${bd_cell}
  group_bd_cells -quiet ${bp_cell_name} [get_bd_cells ${bd_cell}]
  # target ip in hierarchy which has the same name as it has with a temporary name
  set pr_cell_in_hier [get_bd_cells ${bd_cell} ]
  set_property NAME ${bp_cell_name} ${pr_cell_in_hier}
  return ${pr_cell_in_hier}
}

namespace eval vsi {
  namespace eval decoupler {

    # --------------------------------------------------------------------------
    # get_common_intf_dec_en -- get decoupler control pin from common interface
    # --------------------------------------------------------------------------
    proc get_common_intf_dec_en {} {
      set common_interface [get_bd_cells -hierarchical \
          -filter {VLNV=~"vsi.com:ip:*common_interface*"}]
      set decoupler_pin_name "decoup_en"
      set decoupler_pin [get_bd_pins ${common_interface}/${decoupler_pin_name}]
      if {![llength ${decoupler_pin}]} {
        error "control port not found :\n \
          common_interface: ${common_interface}\n \
          decoupler_pin_name: ${decoupler_pin_name}"
      }
      return ${decoupler_pin}
    }

    # --------------------------------------------------------------------------
    # place_slicer --
    # --------------------------------------------------------------------------
    proc place_slicer {decoupler pin_number} {
      # For case if passed several decouplers
      set decoupler [lindex ${decoupler} 0]
      set target_hier [::par_cell ${decoupler}]
      set slicer_name "decoup_en_slicer"
      set slicer [create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice \
                                 ${target_hier}/${slicer_name}]
      set setings [list CONFIG.DIN_TO ${pin_number} \
                        CONFIG.DIN_FROM ${pin_number} \
                        CONFIG.DIN_FROM ${pin_number} \
                        CONFIG.DIN_WIDTH {32} \
                        CONFIG.DOUT_WIDTH {1}]
      set_property -dict ${setings} ${slicer}
      set dec_control [get_common_intf_dec_en]
      set slice_input [get_bd_pins ${slicer}/Din]
      connect_bd_net -quiet ${slice_input} ${dec_control}
      return ${slicer}
    }

    # ------------------------------------------------------------------------------
    # allocate_enable --
    # ------------------------------------------------------------------------------
    proc allocate_enable {decoupler pin_number} {
      set slicer [place_slicer ${decoupler} ${pin_number}]
      set enable_control [get_bd_pins ${slicer}/Dout]
      return ${enable_control}
    }

    # --------------------------------------------------------------------------
    # handle_decoupler_en --
    # --------------------------------------------------------------------------
    proc handle_decoupler_en {decoupler_list {pin_number 0}} {
      set en_control_pin [allocate_enable ${decoupler_list} ${pin_number}]
      foreach decoupler ${decoupler_list} {
        set decoupler_pin_name "${decoupler}/decouple"
        set decoupe_pin [get_bd_pins ${decoupler_pin_name}]
        connect_bd_net -quiet ${decoupe_pin} ${en_control_pin}
      }
    }

    # --------------------------------------------------------------------------
    # get_properties --
    # --------------------------------------------------------------------------
    proc get_properties_dic_list {intf_pin_lists {cdc_stages 0}} {
      set params [dict create]
      dict set params CONFIG.ALL_PARAMS HAS_SIGNAL_STATUS 0
      set interfaces [build_intf_prop ${intf_pin_lists} ${cdc_stages}]
      dict set params CONFIG.ALL_PARAMS INTF ${interfaces}
      return ${params}
    }

    proc intf_reconnect {intf_pin_lists decoupler_cell pin_prefix
                         correspond_pin_prefix} {
      foreach bd_pin_objs_list ${intf_pin_lists} {
        foreach pin_obj ${bd_pin_objs_list} {
          if { [is_pin ${pin_obj}] } {
            set get_net_function get_bd_nets
            set get_pin_function get_bd_pins
            set connect_functiont connect_bd_net
            set pin_type [get_property TYPE ${pin_obj}]
            set post_fix "_[type_to_signal ${pin_type}]"
          } else {
            set get_net_function get_bd_intf_nets
            set get_pin_function get_bd_intf_pins
            set connect_functiont connect_bd_intf_net
            set post_fix ""
          }

          set connected_to [find_bd_objs -relation connected_to ${pin_obj}]
          set connected_net [${get_net_function} -of_objects ${pin_obj}]
          delete_bd_objs -quiet ${connected_net}
          set intf_name [get_property NAME ${pin_obj}]
          set decoupler_pin_path ${decoupler_cell}/${pin_prefix}${intf_name}${post_fix}
          set decoupler_pin [${get_pin_function} ${decoupler_pin_path}]
          ${connect_functiont}  -quiet ${decoupler_pin} ${pin_obj}
          set correspond_pin_path ${decoupler_cell}/${correspond_pin_prefix}${intf_name}${post_fix}
          set correspond_pin [${get_pin_function} ${correspond_pin_path}]
          ${connect_functiont} -quiet ${connected_to} ${correspond_pin}
        }
      }
    }

    # --------------------------------------------------------------------------
    # get_param_source --
    # get interface pin from which can be taken parameters for decoupler
    # --------------------------------------------------------------------------
    proc get_param_source {of_interface} {
      set parameter_source ${of_interface}
      if { [is_hierarchy ${of_interface}] } {
        set parameter_source [find_bd_objs -relation connected_to \
                                            -thru_hier ${of_interface}]
        set parameter_source [lindex ${parameter_source} 0]
        if {[is_pin ${of_interface}]} {
            set parameter_source [get_bd_pins ${parameter_source}]
        } elseif {[is_intf_pin ${of_interface}]} {
            set parameter_source [get_bd_intf_pins ${parameter_source}]
        }
      }
      return ${parameter_source}
    }

    # --------------------------------------------------------------------------
    # build_intf --
    # intf_pin_lists: list of interfaces and pins
    # --------------------------------------------------------------------------
    proc build_intf_prop {intf_pin_lists {cdc_stages 0}} {
      set interfaces [dict create]
      set id 0
      # make a list if passed one element
      if {[is_obj ${intf_pin_lists}] && [llength ${intf_pin_lists}] == 1} {
        set intf_pin_lists [list ${intf_pin_lists}]
      }
      foreach bd_pin_objs_list ${intf_pin_lists} {
        foreach bd_object ${bd_pin_objs_list} {
          if {[is_pin ${bd_object}]} {
              set bd_object [get_bd_pins ${bd_object}]
          } elseif {[is_intf_pin ${bd_object}]} {
              set bd_object [get_bd_intf_pins ${bd_object}]
          }

          set parameter_source [get_param_source ${bd_object}]

          set pin_vlnv [get_object_vlnv ${parameter_source}]
          # save name of target interface
          set bd_object_name [get_property NAME ${bd_object}]
          # set interface_definition [dict create ${bd_object_name}]
          dict set interfaces ${bd_object_name} ID ${id}
          if {${pin_vlnv} != "undef"} {
            dict set interfaces ${bd_object_name} VLNV ${pin_vlnv}
          }
          set mode [get_unify_mode ${parameter_source} 1]
          dict set interfaces ${bd_object_name} MODE ${mode}
          if {[is_pin ${parameter_source}]} {
            set pin_type [get_property -quiet TYPE ${parameter_source}]
            if {${pin_type} == "undef"} {
              set signal [dict create [undef_signal] {}]
              dict set interfaces ${bd_object_name} SIGNALS ${signal}
            }

          } elseif {[is_intf_pin ${parameter_source}]} {
            set protocol [get_property -quiet CONFIG.PROTOCOL ${parameter_source}]
            dict set interfaces ${bd_object_name} PROTOCOL ${protocol}
            set signals [signals_props_of_interface ${parameter_source}]
            dict set interfaces ${bd_object_name} SIGNALS ${signals}
            dict set interfaces ${bd_object_name} CDC_STAGES ${cdc_stages}
          }
        }
      }
      return ${interfaces}
    }

    # --------------------------------------------------------------------------
    # signals_props_of_interface --
    # Build settings dictionary for target interface
    # --------------------------------------------------------------------------
    proc signals_props_of_interface { current_interface } {
        set signals [dict create]
        set vlnv [get_object_vlnv ${current_interface}]
        set ipfile [lindex [ipx::get_ipfiles -type busabs ${vlnv}] 0]

        foreach abstraction_port [ipx::get_bus_abstraction_ports -of ${ipfile} ] {
            set name [get_property NAME ${abstraction_port}]
            set pin_name ${current_interface}_${name}
            set exist_pin [ get_bd_pins -quiet ${pin_name} ]
            set pin_parameter [dict create]
            if { ${exist_pin} != "" } {
                set left [getPropertyForceValue LEFT  ${exist_pin} 0]
                set right [getPropertyForceValue RIGHT ${exist_pin} 0]
                set hier [expr max($right, $left)]
                set lover [expr min($right, $left)]
                set with [ expr ${hier} - ${lover} + 1 ]
                dict set pin_parameter PRESENT 1
                dict set pin_parameter WIDTH ${with}
            } else {
                dict set pin_parameter PRESENT 0
                dict set pin_parameter WIDTH 0
            }
            dict set signals $name ${pin_parameter}
        }

        return ${signals}
    }

    # --------------------------------------------------------------------------
    # get_unify_mode -- get mode of pin_object "slave" for inputs or
    #   Slave interfaces. "master" for outputs or Master interfaces
    #   Inversed if applied inverse as 1.
    # --------------------------------------------------------------------------
    proc get_unify_mode {pin_object {inverse 0}} {
      set pin_object_mode [get_property -quiet MODE ${pin_object}]
      set pin_object_dir [get_property -quiet DIR ${pin_object}]
      set mode_lower [string tolower ${pin_object_mode}]
      set dir_lower [string tolower ${pin_object_dir}]
      if {${mode_lower} == "slave" || ${dir_lower} == "i"} {
        set mode "Slave"
      } elseif {${mode_lower} == "master" || ${dir_lower} == "o"} {
        set mode "Master"
      } else {
        return ""
      }

      if {${inverse}} {
        return [inverse_mode ${mode}]
      }

      return ${mode}
    }

    # get_unify_inverse_mode -- get inverse mode of pin_object
    proc get_unify_inverse_mode {pin_object} {
      set inverse 1
      return [get_unify_mode ${pin_object} ${inverse}]
    }
    # --------------------------------------------------------------------------
    # inverse_mode -- invert input mode
    # --------------------------------------------------------------------------
    proc inverse_mode {input_mode} {
      set mode_lower_case [string tolower ${input_mode}]
      if {${mode_lower_case} == "slave"} {
        return "Master"
      } elseif {${mode_lower_case} == "master"} {
        return "Slave"
      } else {
        return ""
      }
    }

    # ------------------------------------------------------------------------------
    # is_pin -- check if object is pin
    # ------------------------------------------------------------------------------
    proc is_pin {pin_object} {
      set pin_object [get_bd_pins -quiet ${pin_object}]
      set object_class [get_property -quiet CLASS ${pin_object}]
      if {${object_class} == "bd_pin"} {
        return 1
      }
      return 0
    }

    # is_obj -- Check if input is bd object
    proc is_obj {obj} {
      if {[get_property -quiet CLASS ${obj}] != ""} { return 1 }
      return 0
    }
    # ------------------------------------------------------------------------------
    # is_intf_pin -- check if object is interface
    # ------------------------------------------------------------------------------
    proc is_intf_pin {pin_object} {
      set pin_object [get_bd_intf_pins -quiet ${pin_object}]
      set object_class [get_property -quiet CLASS ${pin_object}]
      if {${object_class} == "bd_intf_pin"} {
        return 1
      }
      return 0
    }

    # --------------------------------------------------------------------------
    # get_object_vlnv -- get vlnv of pin/interface_pin
    # --------------------------------------------------------------------------
    proc get_object_vlnv {pin_object} {
      set pin_object_vlnv "undef"
      if {[is_pin ${pin_object}]} {
        set pin_object [get_bd_pins ${pin_object}]
        set pin_type [get_property TYPE ${pin_object}]
        set pin_object_vlnv [get_vlnv_pin ${pin_type}]
      } elseif {[is_intf_pin ${pin_object}]} {
        set pin_object [get_bd_intf_pins ${pin_object}]
        set pin_object_vlnv [get_property VLNV ${pin_object}]
      } else {
        error "Err:\[0x674e865a\] Object is not pin or interface: ${pin_object}"
      }

      return ${pin_object_vlnv}
    }

    # --------------------------------------------------------------------------
    # get_vlnv -- for interface is usual approach, for pins: should be build
    # --------------------------------------------------------------------------
    proc get_vlnv_pin {pin_type} {
      set vlnv_pin_map {
          ce   xilinx.com:signal:clockenable_rtl:1.0
          clk  xilinx.com:signal:clock_rtl:1.0
          intr xilinx.com:signal:interrupt_rtl:1.0
          rst  xilinx.com:signal:reset_rtl:1.0
          data xilinx.com:signal:data_rtl:1.0
      }
      set pin_type_defined [dict exist ${vlnv_pin_map} ${pin_type}]
      if {${pin_type_defined}} {
          set correspond_vlnv [dict get ${vlnv_pin_map} ${pin_type}]
          return ${correspond_vlnv}
      }
      return "undef"
    }

    # --------------------------------------------------------------------------
    # get_pin_name --
    # --------------------------------------------------------------------------
    proc type_to_signal {pin_type} {
      set type_signal_map {
          ce   CE
          clk  CLK
          data DATA
          intr INTERRUPT
          rst  RST
      }
      set pin_type_defined [dict exist ${type_signal_map} ${pin_type}]
      if {${pin_type_defined}} {
          set correspond_vlnv [dict get ${type_signal_map} ${pin_type}]
          return ${correspond_vlnv}
      }
      return [undef_signal]
    }

    proc undef_signal {} { return "undefsig" }
  }
}

# ------------------------------------------------------------------------------
# vsi::get_bd_cells_of_module --
# ------------------------------------------------------------------------------
proc vsi::get_bd_cells_of_module {reconfig_modules_list} {
  set first_module [lindex $reconfig_modules_list 0]
  set first_module [get_reconfig_modules $first_module]
  set current_pr_def [get_property PARTITION_DEF ${first_module}]
  set cells_in_bd [get_bd_cells -hier -filter "VLNV=~*${current_pr_def}*"]
  return ${cells_in_bd}
}

# ------------------------------------------------------------------------------
# pr_config_wizard --
# ------------------------------------------------------------------------------
proc pr_config_wizard {bd_design} {
  set i 0
  set reconfig_modules ""
  set size_index ""
  # Get reconfigurable module(s) for each partition definition
  #  and build list which contain number of modules and correspond index
  #  for sort it on a next step.
  foreach partition_def [get_partition_defs] {
    set partition_def [get_partition_defs ${partition_def}]
    set modules [get_reconfig_modules -of_objects ${partition_def}]
    set current_size_index [list [llength ${modules}] $i]
    set modules_number [llength ${modules}]
    set partition_struct [list ${modules_number} ${partition_def} ${modules}]
    lappend reconfig_modules $partition_struct
    incr i
  }

  # sort list of module indexes by number of modules
  set reconfig_modules [lsort -decreasing ${reconfig_modules}]
  set max_partitions [lindex [lindex ${reconfig_modules} 0] 0]

  set configs ""
  # top instance of synthesis
  set impl_top_inst "[format "%s_i" ${bd_design}]"
  set i 1
  while {${i} <= ${max_partitions}} {
    set current_config [dict create]
    foreach reconfig_struct $reconfig_modules {
      lassign  $reconfig_struct modules_number partition_def module_list
      set module [lindex ${module_list} ${i}-1]
      if { ${module} != "" } {
        set module ${module}
        set pr_bd_cell [vsi::get_bd_cells_of_module ${module}]
        set partial_reconfig_cell "${impl_top_inst}${pr_bd_cell}"
        set partitions "${partial_reconfig_cell}:${module}"
        dict lappend current_config -partitions ${partitions}
      } else {
        dict lappend current_config -greyboxes ${partial_reconfig_cell}
      }
    }
    dict lappend current_config -name "config_${i}"
    lappend configs ${current_config}
    incr i
  }

  # # generation of pr configuration for each parameter set
  foreach configuration $configs {
    eval "create_pr_configuration ${configuration}"
  }

  # Create design run for each configuration
  set first_config [lindex $configs 0]
  set parant_config [dict_get_quiet ${first_config} -name]
  set parent_run [get_runs impl_1]
  set_property PR_CONFIGURATION ${parant_config} ${parent_run}
  set child_impl_format "child_%s_%s"
  set child_num 0
  foreach configuration [lrange $configs 1 end] {
    set config_name [dict_get_quiet ${configuration} -name]
    set chield_run [format ${child_impl_format} ${child_num} ${parent_run}]
    create_run "${chield_run}" \
        -parent_run ${parent_run} \
        -pr_config ${config_name} \
        -flow {Vivado Implementation 2018}
    incr child_num
  }
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


################################################################################
# In develop..
################################################################################


proc to_file { content path } {
  set project_path [get_property DIRECTORY [get_projects]]; list;   # << Debug
  set inft_sets_dir "${project_path}/inft_sets"; list;              # << Debug
  catch { file mkdir ${inft_sets_dir} }; list;                      # << Debug
  set file_path "${inft_sets_dir}/${path}"; list;     # << Debug
  set fp [open ${file_path} w+]; list; # << Debug
  puts ${fp} ${content}; list;  # << Debug
  close $fp; list;  # << Debug
}

proc dictree { d {indent 0}} {
    set ret ""
    set indent_str [string repeat "\t" $indent ]
    set first_pair 1
    dict for {key val} $d {
        if {[isdict $val]} {
            # Avoid of key with the previes  brecket
            if { ${indent} == 0 && ${first_pair} == 0 } {
              set ret "${ret}\n${indent_str}${key} \{\n"
            } else {
              set first_pair 0
              set ret "${ret}${indent_str}${key} \{\n"
            }

            incr indent
            set ret "${ret}[dictree $val ${indent}]"
            incr indent -1

            if {${indent} == 0} {
              set ret "${ret}${indent_str}\}"
            } else {
              set ret "${ret}${indent_str}\}\n"
            }

        } else {
            if { ![string length $val] } {
                set val "\{\}"
            }
            set ret "${ret}${indent_str}$key $val\n"
        }
    }
    return $ret
}

proc isdict { target_list } {
    set dict_get_res ""
    catch { set dict_get_res [dict get $target_list]; list }
    if { $dict_get_res == $target_list && $target_list != "" } {
        return 1
    }
    return 0
}



proc file_name_from_intf { interface {intf_file_prefix ""} } {
  set file_name [ format "%s%s_%s.intf" \
                         ${intf_file_prefix}  \
                         [get_property NAME [get_bd_cells -of ${interface}] ] \
                         [get_property NAME ${interface}] \
                ]
}

proc file_name_from_design {   } {
  set file_name [ format "%s.intf" \
                         [current_bd_design] \
                ]
}


proc bd_modules_of_partition_defs { partition_def } {
  set modules [get_reconfig_modules -of_objects ${partition_def}]
  set bd_modules_list ""
  foreach module ${modules} {
    set bd_of_module [get_files -of_objects $module -filter {FILE_TYPE == "Block Designs"}]
    if { ${bd_of_module} != "" } {
      lappend bd_modules_list ${bd_of_module}
    }
  }
  return ${bd_modules_list}
}

proc collect_intf_info_to_file { bd_path } {
  set came_from_bd_design [current_bd_design .]
  open_bd_design -q ${bd_path}

  set project_path [get_property DIRECTORY [get_projects]]; list
  set inft_sets_dir "${project_path}/inft_sets"; list
  catch { file mkdir ${inft_sets_dir} }; list

  if { ![ file exist ${inft_sets_dir} ] } {
    error "Folder ${inft_sets_dir} was not created. "
  }

  # set inft_sets_file_path "${inft_sets_dir}/[file_name_from_intf ${parameter_source} ${intf_file_prefix}]"; list
  set inft_sets_file_path "${inft_sets_dir}/[file_name_from_design]"; list
  set fp [open ${inft_sets_file_path} w+]; list

  set intf_list [lsort [get_bd_intf_ports ]]
  foreach intf ${intf_list} {
    set parameter_source [find_bd_objs -relation connected_to -thru_hier -boundary_type all ${intf}]
    puts "source intf: ${parameter_source}"
    set intf_name [get_property NAME ${intf}]
    set signals [vsi::decoupler::signals_props_of_interface ${parameter_source}]; list
    set INTF "${intf_name} \{SIGNALS \{${signals}\}\}"
    puts ${fp} [dictree ${INTF}]
  }

  close $fp; list
  # close_bd_design  [current_bd_design .]
  open_bd_design -q ${came_from_bd_design}

  puts $inft_sets_file_path; list
}

proc collect_valuable_intf { {bd_path ""} {collected ""} } {
  if { $bd_path != "" } {
    set came_from_bd_design [current_bd_design .]
    open_bd_design -q ${bd_path}
  }

  set intf_list [get_intf_list_not_terminated]
  foreach intf ${intf_list} {
    set parameter_source [find_bd_objs -relation connected_to -thru_hier -boundary_type all ${intf}]
    # Use port as a source of parameters
    set intf_name [get_property NAME ${intf}]
    set signals [vsi::decoupler::signals_props_of_interface ${parameter_source}]; list
    # set INTF "${intf_name} \{SIGNALS \{${signals}\}\}"
    # puts ${fp} [dictree ${INTF}]
    if {![dict exist $collected ${intf_name}]} {
      lappend collected ${intf_name} ${signals}
    } else {
      # TODO check if parameters values the same
      puts "{0xB48AfE17} Interface ${intf_name} already collected."
    }

  }

  if { $bd_path != "" } {
  #  close_bd_design  [current_bd_design .]
    open_bd_design -q ${came_from_bd_design}
  }
  return $collected
}

proc is_termination_ip { cell } {
  set cell_vlnv [get_property -quiet VLNV ${cell}]
  if { [string first xilinx.com:ip:pr_decoupler ${cell_vlnv} ] == 0 } {
    return 1
  }
  return 0
}

proc get_intf_list_terminated { } {
  set result_list ""
  foreach intf_ports [get_bd_intf_ports] {
    set parameter_source [find_bd_objs -relation connected_to -thru_hier -boundary_type all ${intf_ports}]
    set cell_of_source [get_bd_cells -quiet -of_objects $parameter_source]
  #  puts "are you? ${cell_of_source}"
    if { [is_termination_ip ${cell_of_source}] } {
  #    puts "Yes I'am"
     lappend result_list ${intf_ports}
    }
  }
  return ${result_list}
}

proc get_intf_list_not_terminated { } {
  set result_list ""
  foreach intf_ports [get_bd_intf_ports] {
    set parameter_source [find_bd_objs -relation connected_to -thru_hier -boundary_type all ${intf_ports}]
    set cell_of_source [get_bd_cells -quiet -of_objects $parameter_source]
    if { ![is_termination_ip ${cell_of_source}] && ${cell_of_source} != "" } {
     lappend result_list ${intf_ports}
    }
  }
  return ${result_list}
}

proc clone_config_properties { source_bd_object destination_bd_object } {
  puts "0xCREEE: ${source_bd_object} ->>> $destination_bd_object"
  set property_list [list_property ${source_bd_object} CONFIG.*]
  set prop_dict [dict create]
  foreach property $property_list {
    set value [get_property ${property} ${source_bd_object}]
    dict lappend prop_dict ${property} ${value}
  }

  # to_file [report_property $destination_bd_object] "clone_config_[current_bd_design .]_[get_property name $destination_bd_object].inf_before"
  # to_file $prop_dict "clone_config_[current_bd_design .]_[get_property name $destination_bd_object].try"

  set_property -dict $prop_dict ${destination_bd_object}
  # to_file [report_property $destination_bd_object] "clone_config_[current_bd_design .]_[get_property name $destination_bd_object].inf_after"
}

proc reset_terminate_intf_parameters { bd_path p_defs_intf } {
  set came_from_bd_design [current_bd_design .]
  open_bd_design -q ${bd_path}

  set terminate_ip [get_bd_cells -filter {VLNV=~xilinx.com:ip:pr_decoupler:*} -hierarchical]
  if { [llength ${terminate_ip}] > 1 } {
    error "Multiple termination IP found :\n\t [join ${terminate_ip} "\n\t"]"
  } elseif { ![llength ${terminate_ip}] } {
    puts "DBG: 0x46829864 No terminate ip"
    save_bd_design
    close_bd_design [current_bd_design .]
    open_bd_design -q ${came_from_bd_design}
    return
  }
  set current_settings [get_property CONFIG.ALL_PARAMS ${terminate_ip}]
  # to_file [dictree $current_settings] "terminate_ip_[current_bd_design .].inf_before"

  # Update settings of termination ip based on collected settings
  dict for {reference_interface signals} $p_defs_intf {
    if { [dict exists  $current_settings INTF $reference_interface] } {
      puts "Exter set of: ${reference_interface}"

      dict set current_settings INTF $reference_interface SIGNALS $signals
    }
  }

  set_property CONFIG.ALL_PARAMS $current_settings ${terminate_ip}
  # to_file [dictree $current_settings] "terminate_ip_[current_bd_design .].settings_after"
  # NMS # foreach terminated_port [get_intf_list_terminated] {
  # NMS #   set source_of_config [find_bd_objs -relation connected_to -thru_hier -boundary_type all ${terminated_port}]
  # NMS #   if { ${source_of_config} != "" &&  ${terminated_port} != "" } {
  # NMS #     # puts "clone_config_properties ${source_of_config} ${terminated_port}"
  # NMS #     # clone_config_properties ${source_of_config} ${terminated_port}
  # NMS #   }
  # NMS # }
  save_bd_design
  close_bd_design [current_bd_design .]
  open_bd_design -q ${came_from_bd_design}
}

proc store_modules_intf_info {} {
  foreach partition_def [get_partition_defs] {
    set bd_modules_list [bd_modules_of_partition_defs ${partition_def}]
    foreach bd_of_module $bd_modules_list {
      puts "run : collect_intf_info_to_file $bd_of_module"
      collect_intf_info_to_file $bd_of_module
      puts "== DONE =="
    }
  }
}

proc propagate_intf_settings_to_module {} {
  foreach partition_def [get_partition_defs] {

    # set project_path [get_property DIRECTORY [get_projects]]; list;   # << Debug
    # set inft_sets_dir "${project_path}/inft_sets"; list;              # << Debug
    # catch { file mkdir ${inft_sets_dir} }; list;                      # << Debug
    # set file_path "${inft_sets_dir}/${partition_def}.dict"; list;     # << Debug
    # set fp [open ${file_path} w+]; list; # << Debug


    # TODO : separate for each p_defs
    set bd_modules_list [bd_modules_of_partition_defs ${partition_def}]
    set p_defs_intf ""
    # Collect interface settings for module
    foreach bd_of_module $bd_modules_list {
      set p_defs_intf [collect_valuable_intf ${bd_of_module} ${p_defs_intf}]
    }
    # puts ${fp} [dictree ${p_defs_intf}];                              # << Debug
    # close $fp; list;                                                  # << Debug
    # puts $file_path; list;                                  # << Debug
    # puts "what?"
    # puts "[dict keys $p_defs_intf]"

    # Set collected interface settings for each module
    foreach bd_of_module $bd_modules_list {
      puts "####### ####### #######"
      puts " Re set parameters in module : ${bd_of_module}"
      reset_terminate_intf_parameters ${bd_of_module} ${p_defs_intf}
    }

    # Find PR cell of current module and upgrade it
    puts "Updating of $partition_def"
    set partition_module_name [get_property NAME $partition_def]
    set vlnv_filter [format "%s:%s:%s:*" "xilinx.com" "module_ref" ${partition_module_name}]
    set pr_cell_of_def [get_bd_cells -filter VLNV=~${vlnv_filter} -hierarchical]
    upgrade_bd_cells $pr_cell_of_def
    save_bd_design
  }
}
