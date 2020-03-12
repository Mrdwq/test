#include <vsi_dfx_lab_u96_ps.cxx>
// Generating default code for display_0
// vsi_system:u96_ps:display_0
vsi_system::u96_ps::display_0::display_0 () {
	vsi::runtime::vsi_gen_ip::Component_Name = Component_Name;
	vsi::runtime::vsi_gen_ip::EXEC_TIMER = EXEC_TIMER;
	vsi::runtime::vsi_gen_ip::CPU_THREAD = CPU_THREAD;
	vsi::runtime::vsi_gen_ip::EXEC_TRIGGER = EXEC_TRIGGER;
	vsi::runtime::vsi_gen_ip::THREAD_PRIORITY = THREAD_PRIORITY;
	vsi::runtime::vsi_gen_ip::CPU_NUMBER = CPU_NUMBER;
	vsi::runtime::vsi_gen_ip::P00_param_name = P00_param_name;
	vsi::runtime::vsi_gen_ip::P00_param_size = P00_param_size;
	vsi::runtime::vsi_gen_ip::P00_param_type = P00_param_type;
	vsi::runtime::vsi_gen_ip::P00_param_ctype = P00_param_ctype;
	vsi::runtime::vsi_gen_ip::P00_param_dir = P00_param_dir;
	vsi::runtime::vsi_gen_ip::P00_param_access = P00_param_access;
	vsi::runtime::vsi_gen_ip::P00_sideband = P00_sideband;
	vsi::runtime::vsi_gen_ip::P00_fifo_size = P00_fifo_size;
	vsi::runtime::vsi_gen_ip::P00_pack_data = P00_pack_data;
	vsi::runtime::vsi_gen_ip::P00_var_length = P00_var_length;
	vsi::runtime::vsi_gen_ip::P00_change_trigger = P00_change_trigger;
	vsi::runtime::vsi_gen_ip::P00_out_delay = P00_out_delay;
}
#include "webcam.h"
#include <webcam.h>
extern void display_image(hls::stream<int> & control);

void vsi_system::u96_ps::display_0::exec_user_func() {
	hls::stream_base *control_base = const_cast<vsi::runtime::Inout&>(control).stream();
	hls::stream<int> & control_local = static_cast<hls::stream<int> &>(*control_base);
	// read input parameters 
// read input parameters 
	// call the user code 
	_ap_start:
	display_image(control_local);
	// update the outputs 
}

  // Generating default code for fcorner_shmem
// vsi_system:u96_ps:fcorner_shmem
vsi_system::u96_ps::fcorner_shmem::fcorner_shmem () {
	vsi::runtime::vsi_mem::Component_Name = Component_Name;
	vsi::runtime::vsi_mem::MEM_SIZE_KB = MEM_SIZE_KB;
	vsi::runtime::vsi_mem::MEM_WIDTH_BYTES = MEM_WIDTH_BYTES;
	vsi::runtime::vsi_mem::num_ports = num_ports;
	vsi::runtime::vsi_mem::port_0 = &const_cast<vsi::runtime::Inout&>(port_0);
	vsi::runtime::vsi_mem::port_1 = &const_cast<vsi::runtime::Inout&>(port_1);
}
  // Generating default code for minmax_shmem
// vsi_system:u96_ps:minmax_shmem
vsi_system::u96_ps::minmax_shmem::minmax_shmem () {
	vsi::runtime::vsi_mem::Component_Name = Component_Name;
	vsi::runtime::vsi_mem::MEM_SIZE_KB = MEM_SIZE_KB;
	vsi::runtime::vsi_mem::MEM_WIDTH_BYTES = MEM_WIDTH_BYTES;
	vsi::runtime::vsi_mem::num_ports = num_ports;
	vsi::runtime::vsi_mem::port_0 = &const_cast<vsi::runtime::Inout&>(port_0);
	vsi::runtime::vsi_mem::port_1 = &const_cast<vsi::runtime::Inout&>(port_1);
}
  // Generating default code for webcam_0
// vsi_system:u96_ps:webcam_0
vsi_system::u96_ps::webcam_0::webcam_0 () {
	vsi::runtime::vsi_gen_ip::Component_Name = Component_Name;
	vsi::runtime::vsi_gen_ip::EXEC_TIMER = EXEC_TIMER;
	vsi::runtime::vsi_gen_ip::CPU_THREAD = CPU_THREAD;
	vsi::runtime::vsi_gen_ip::EXEC_TRIGGER = EXEC_TRIGGER;
	vsi::runtime::vsi_gen_ip::THREAD_PRIORITY = THREAD_PRIORITY;
	vsi::runtime::vsi_gen_ip::CPU_NUMBER = CPU_NUMBER;
	vsi::runtime::vsi_gen_ip::P00_param_name = P00_param_name;
	vsi::runtime::vsi_gen_ip::P00_param_size = P00_param_size;
	vsi::runtime::vsi_gen_ip::P00_param_type = P00_param_type;
	vsi::runtime::vsi_gen_ip::P00_param_ctype = P00_param_ctype;
	vsi::runtime::vsi_gen_ip::P00_param_dir = P00_param_dir;
	vsi::runtime::vsi_gen_ip::P00_param_access = P00_param_access;
	vsi::runtime::vsi_gen_ip::P00_sideband = P00_sideband;
	vsi::runtime::vsi_gen_ip::P00_fifo_size = P00_fifo_size;
	vsi::runtime::vsi_gen_ip::P00_pack_data = P00_pack_data;
	vsi::runtime::vsi_gen_ip::P00_var_length = P00_var_length;
	vsi::runtime::vsi_gen_ip::P00_change_trigger = P00_change_trigger;
	vsi::runtime::vsi_gen_ip::P00_out_delay = P00_out_delay;
	vsi::runtime::vsi_gen_ip::P01_param_name = P01_param_name;
	vsi::runtime::vsi_gen_ip::P01_param_size = P01_param_size;
	vsi::runtime::vsi_gen_ip::P01_param_type = P01_param_type;
	vsi::runtime::vsi_gen_ip::P01_param_ctype = P01_param_ctype;
	vsi::runtime::vsi_gen_ip::P01_param_dir = P01_param_dir;
	vsi::runtime::vsi_gen_ip::P01_param_access = P01_param_access;
	vsi::runtime::vsi_gen_ip::P01_sideband = P01_sideband;
	vsi::runtime::vsi_gen_ip::P01_fifo_size = P01_fifo_size;
	vsi::runtime::vsi_gen_ip::P01_pack_data = P01_pack_data;
	vsi::runtime::vsi_gen_ip::P01_var_length = P01_var_length;
	vsi::runtime::vsi_gen_ip::P01_change_trigger = P01_change_trigger;
	vsi::runtime::vsi_gen_ip::P01_out_delay = P01_out_delay;
	vsi::runtime::vsi_gen_ip::P02_param_name = P02_param_name;
	vsi::runtime::vsi_gen_ip::P02_param_size = P02_param_size;
	vsi::runtime::vsi_gen_ip::P02_param_type = P02_param_type;
	vsi::runtime::vsi_gen_ip::P02_param_ctype = P02_param_ctype;
	vsi::runtime::vsi_gen_ip::P02_param_dir = P02_param_dir;
	vsi::runtime::vsi_gen_ip::P02_param_access = P02_param_access;
	vsi::runtime::vsi_gen_ip::P02_sideband = P02_sideband;
	vsi::runtime::vsi_gen_ip::P02_fifo_size = P02_fifo_size;
	vsi::runtime::vsi_gen_ip::P02_pack_data = P02_pack_data;
	vsi::runtime::vsi_gen_ip::P02_var_length = P02_var_length;
	vsi::runtime::vsi_gen_ip::P02_change_trigger = P02_change_trigger;
	vsi::runtime::vsi_gen_ip::P02_out_delay = P02_out_delay;
	vsi::runtime::vsi_gen_ip::P03_param_name = P03_param_name;
	vsi::runtime::vsi_gen_ip::P03_param_size = P03_param_size;
	vsi::runtime::vsi_gen_ip::P03_param_type = P03_param_type;
	vsi::runtime::vsi_gen_ip::P03_param_ctype = P03_param_ctype;
	vsi::runtime::vsi_gen_ip::P03_param_dir = P03_param_dir;
	vsi::runtime::vsi_gen_ip::P03_param_access = P03_param_access;
	vsi::runtime::vsi_gen_ip::P03_sideband = P03_sideband;
	vsi::runtime::vsi_gen_ip::P03_fifo_size = P03_fifo_size;
	vsi::runtime::vsi_gen_ip::P03_pack_data = P03_pack_data;
	vsi::runtime::vsi_gen_ip::P03_var_length = P03_var_length;
	vsi::runtime::vsi_gen_ip::P03_change_trigger = P03_change_trigger;
	vsi::runtime::vsi_gen_ip::P03_out_delay = P03_out_delay;
	vsi::runtime::vsi_gen_ip::P04_param_name = P04_param_name;
	vsi::runtime::vsi_gen_ip::P04_param_size = P04_param_size;
	vsi::runtime::vsi_gen_ip::P04_param_type = P04_param_type;
	vsi::runtime::vsi_gen_ip::P04_param_ctype = P04_param_ctype;
	vsi::runtime::vsi_gen_ip::P04_param_dir = P04_param_dir;
	vsi::runtime::vsi_gen_ip::P04_param_access = P04_param_access;
	vsi::runtime::vsi_gen_ip::P04_sideband = P04_sideband;
	vsi::runtime::vsi_gen_ip::P04_fifo_size = P04_fifo_size;
	vsi::runtime::vsi_gen_ip::P04_pack_data = P04_pack_data;
	vsi::runtime::vsi_gen_ip::P04_var_length = P04_var_length;
	vsi::runtime::vsi_gen_ip::P04_change_trigger = P04_change_trigger;
	vsi::runtime::vsi_gen_ip::P04_out_delay = P04_out_delay;
	vsi::runtime::vsi_gen_ip::P05_param_name = P05_param_name;
	vsi::runtime::vsi_gen_ip::P05_param_size = P05_param_size;
	vsi::runtime::vsi_gen_ip::P05_param_type = P05_param_type;
	vsi::runtime::vsi_gen_ip::P05_param_ctype = P05_param_ctype;
	vsi::runtime::vsi_gen_ip::P05_param_dir = P05_param_dir;
	vsi::runtime::vsi_gen_ip::P05_param_access = P05_param_access;
	vsi::runtime::vsi_gen_ip::P05_sideband = P05_sideband;
	vsi::runtime::vsi_gen_ip::P05_fifo_size = P05_fifo_size;
	vsi::runtime::vsi_gen_ip::P05_pack_data = P05_pack_data;
	vsi::runtime::vsi_gen_ip::P05_var_length = P05_var_length;
	vsi::runtime::vsi_gen_ip::P05_change_trigger = P05_change_trigger;
	vsi::runtime::vsi_gen_ip::P05_out_delay = P05_out_delay;
	vsi::runtime::vsi_gen_ip::P06_param_name = P06_param_name;
	vsi::runtime::vsi_gen_ip::P06_param_size = P06_param_size;
	vsi::runtime::vsi_gen_ip::P06_param_type = P06_param_type;
	vsi::runtime::vsi_gen_ip::P06_param_ctype = P06_param_ctype;
	vsi::runtime::vsi_gen_ip::P06_param_dir = P06_param_dir;
	vsi::runtime::vsi_gen_ip::P06_param_access = P06_param_access;
	vsi::runtime::vsi_gen_ip::P06_sideband = P06_sideband;
	vsi::runtime::vsi_gen_ip::P06_fifo_size = P06_fifo_size;
	vsi::runtime::vsi_gen_ip::P06_pack_data = P06_pack_data;
	vsi::runtime::vsi_gen_ip::P06_var_length = P06_var_length;
	vsi::runtime::vsi_gen_ip::P06_change_trigger = P06_change_trigger;
	vsi::runtime::vsi_gen_ip::P06_out_delay = P06_out_delay;
}
#include "webcam.h"
#include <webcam.h>
extern void webcam0(hls::stream<int> & control,vsi::device & mem_mm,hls::stream<st> & start_mm,hls::stream<st> & done_mm,vsi::device & mem_fc,hls::stream<st> & start_fc,hls::stream<st> & done_fc);
namespace hls {
	template <> st stream<st >::read() {
		st elem;
		const int d_w = (elem.data.width+7)/8; 
		if (stream_base::peek()->size() < d_w) {
			unsigned char t_data[d_w];
			for (int i = 0 ; i < d_w ; i++)
				stream_base::read(&t_data[i],1);
			memcpy(&elem.data,t_data,d_w);
		} else {
			stream_base::read(&elem.data,d_w);
		}
		elem.last = stream_base::is_endofpacket;
		return elem;
	}
}
namespace hls {
	template<> void  stream<st >::write(st data) {
		if (stream_base::sbuff == 0) stream_base::sbuff = new hls::VsiBuffer();
		stream_base::sbuff->add(&data.data,(data.data.width+7)/8);
		if (data.last) { // buffer up till last
			spBuffer buf1 = mkSPBuf(stream_base::sbuff->get(),stream_base::sbuff->size());
			stream_base::write(buf1);
			delete stream_base::sbuff;
			stream_base::sbuff = 0;
		}
	}
}

void vsi_system::u96_ps::webcam_0::exec_user_func() {
	hls::stream_base *control_base = const_cast<vsi::runtime::Inout&>(control).stream();
	hls::stream<int> & control_local = static_cast<hls::stream<int> &>(*control_base);
	vsi::device  mem_mm_local( &const_cast<vsi::runtime::Inout&> (mem_mm));
	hls::stream_base *start_mm_base = const_cast<vsi::runtime::Inout&>(start_mm).stream();
	hls::stream<st> & start_mm_local = static_cast<hls::stream<st> &>(*start_mm_base);
	hls::stream_base *done_mm_base = const_cast<vsi::runtime::Inout&>(done_mm).stream();
	hls::stream<st> & done_mm_local = static_cast<hls::stream<st> &>(*done_mm_base);
	vsi::device  mem_fc_local( &const_cast<vsi::runtime::Inout&> (mem_fc));
	hls::stream_base *start_fc_base = const_cast<vsi::runtime::Inout&>(start_fc).stream();
	hls::stream<st> & start_fc_local = static_cast<hls::stream<st> &>(*start_fc_base);
	hls::stream_base *done_fc_base = const_cast<vsi::runtime::Inout&>(done_fc).stream();
	hls::stream<st> & done_fc_local = static_cast<hls::stream<st> &>(*done_fc_base);
	// read input parameters 
// read input parameters 
	// call the user code 
	_ap_start:
	webcam0(control_local, mem_mm_local, start_mm_local, done_mm_local, mem_fc_local, start_fc_local, done_fc_local);
	// update the outputs 
}

  #include "init_hw_u96_ps.cxx"

