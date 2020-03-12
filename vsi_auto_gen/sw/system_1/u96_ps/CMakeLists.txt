cmake_minimum_required (VERSION 2.6)

project (u96_ps)

# RT_LIB_GUI_CODE pulled from VSI
set(RT_LIB_GUI_CODE 1)
if(RT_LIB_GUI_CODE STREQUAL "1")
set(RT_LINK_LIB "vsi_rt_release")
else()
set(RT_LINK_LIB "vsi_rt_debug")
endif()
#set(RT_LINK_LIB "vsi_rt_debug")


set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

set(VSI_TARGET_SDK $ENV{VSI_INSTALL}/target/ARM64)
set(CMAKE_PREFIX_PATH ${VSI_TARGET_SDK})
string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}.x86_64" HOST_VAR)
set(VSI_HOST_DIR $ENV{VSI_INSTALL}/host/${HOST_VAR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


set(CMAKE_SYSROOT /home/dwq/Documents/u96_image/rootfs/)
set(CMAKE_C_FLAGS "${COMPILE_FLAGS} ${CMAKE_C_FLAGS}-std=c11  -g   -DDEBUG -O0")
set(CMAKE_CXX_FLAGS "${COMPILE_FLAGS} ${CMAKE_CXX_FLAGS}-std=c++11 -g  -DDEBUG -O0 -fpermissive")

include_directories(
	include
	public
	$ENV{VSI_INSTALL}/target/common/include
	
	
	/home/dwq/Documents/Xilinx/Vivado/2019.2/include
	/home/dwq/Documents/u96_image/rootfs//../
	
	${VSI_TARGET_SDK}/include
	$ENV{XILINX_VIVADO}/include
)

link_directories(
	${VSI_TARGET_SDK}/lib
	
)

add_executable(u96_ps
	src/main.cxx
	src/u96_ps.cxx
	/home/dwq/Documents/Systemview/VSI/target/common/hls_examples/webcam/webcam.cc
	/home/dwq/Documents/Systemview/VSI/target/common/hls_examples/webcam/webcam.h
	/home/dwq/Documents/Systemview/VSI/target/common/hls_examples/webcam/webcam.cc
	/home/dwq/Documents/Systemview/VSI/target/common/hls_examples/webcam/webcam.h
)
target_link_libraries(u96_ps   opencv_aruco  opencv_bgsegm  opencv_bioinspired  opencv_calib3d  opencv_ccalib  opencv_core  opencv_dpm  opencv_face  opencv_features2d  opencv_flann  opencv_fuzzy  opencv_highgui  opencv_imgcodecs  opencv_imgproc  opencv_line_descriptor  opencv_ml  opencv_objdetect  opencv_optflow  opencv_photo  opencv_plot  opencv_reg  opencv_rgbd  opencv_saliency  opencv_shape  opencv_stereo  opencv_stitching  opencv_structured_light  opencv_superres  opencv_surface_matching  opencv_tracking  opencv_videoio  opencv_video  opencv_videostab  opencv_xfeatures2d  opencv_ximgproc  opencv_xobjdetect  opencv_xphoto.so  v4l2  v4l2subdev  v4l2convert  ${RT_LINK_LIB} protobuf-c ssl crypto dl -Wl,--whole-archive -lpthread -Wl,--no-whole-archive)

add_executable(
	p_u96_pl_zynq_ultra_ps_e_0_init
	${CMAKE_CURRENT_SOURCE_DIR}/../../../.platform/ultra96_platform/p_u96_pl_zynq_ultra_ps_e_0_init.cxx
)
target_link_libraries(p_u96_pl_zynq_ultra_ps_e_0_init ${RT_LINK_LIB} pthread)
