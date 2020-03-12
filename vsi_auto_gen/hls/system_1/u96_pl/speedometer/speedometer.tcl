# ==============================================================================
# This file is generated by VSI compiler
# ILANG version:V2019.2_Release_1.0-149-g78d8f9a
# Build Date:2020-02-28T14:57:19
# ==============================================================================

open_project speedometer

set annotated_src_path ./annotated_src/[exec hashed_folder_path.sh /home/dwq/Documents/Systemview/VSI/target/common/hls_examples/image_algos]
set files [glob -directory ${annotated_src_path} *.c*]
foreach file $files {
	add_files -cflags "-std=c++11 \
	-I /home/dwq/Documents/u96_image/xfopencv//include \
	-I /home/dwq/Documents/u96_image/xfopencv//include \
	-I /home/dwq/Documents/Systemview/VSI/target/common/hls_examples/image_algos \
	-I $::env(VSI_INSTALL)/target/common/include/vsi  \
	-D__VSI_HLS_SYN__" $file
}

set_top draw_speedometer
open_solution "solution${::env(SOLUTION_NUM)}"
set_directive_inline "draw_speedometer"
set_directive_interface -mode axis draw_speedometer start


set_directive_interface -mode axis draw_speedometer done


set_directive_interface -latency 110 -mode m_axi -depth 76800 -offset slave draw_speedometer io_frame



for {set sn 1} {$sn <= $::env(SOLUTION_NUM)} {incr sn} {
	source "directives_${sn}.tcl"
}

#ensure M-AXI write are delayed until data is ready
config_rtl -enable_maxiConservative
set_part xczu3eg-sbva484-1-e
config_rtl -reset all -reset_level low -reset_async
create_clock -period 10.0 -name default
config_bind -effort low
config_schedule -effort medium
csynth_design
export_design -format ip_catalog -vendor "vsi.com" -version "$::env(SOLUTION_NUM).0"
exit