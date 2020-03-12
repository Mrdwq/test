/*
* 
*/
#include <vsi/include.hh>
const char *ctx_name = "u96_ps";
namespace vsi_system {

// sub blocks

		
namespace u96_pl {
namespace pr_set_0_1 {
	class speedometer {
		public:
			static const vsi::runtime::Inout done;
			static const vsi::runtime::Inout io_frame;
			static const vsi::runtime::Inout start;
	};
	const vsi::runtime::Inout speedometer::done(vsi::runtime::OUTPUT);
	const vsi::runtime::Inout speedometer::io_frame(vsi::runtime::INOUT);
	const vsi::runtime::Inout speedometer::start(vsi::runtime::INPUT);
		
}
}
		
namespace u96_pl {
namespace pr_set_0_0 {
	class min_max {
		public:
			static const vsi::runtime::Inout done;
			static const vsi::runtime::Inout io_frame;
			static const vsi::runtime::Inout start;
	};
	const vsi::runtime::Inout min_max::done(vsi::runtime::OUTPUT);
	const vsi::runtime::Inout min_max::io_frame(vsi::runtime::INOUT);
	const vsi::runtime::Inout min_max::start(vsi::runtime::INPUT);
		
}
}
// blocks for this context
namespace u96_ps {
  	class display_0 : public vsi::runtime::vsi_gen_ip {
		public:
		display_0 ();
		void exec_user_func ();

	   protected:
		static constexpr char *Component_Name = (char*)"display_0";
		static constexpr float EXEC_TIMER = (float)1;
		static constexpr long CPU_THREAD = (long)0;
		static constexpr long EXEC_TRIGGER = (long)1;
		static constexpr long THREAD_PRIORITY = (long)1;
		static constexpr long CPU_NUMBER = (long)1;
		static constexpr char* P00_param_name = (char*)"control";
		static constexpr long P00_param_size = (long)-2;
		static constexpr long P00_param_type = (long)3;
		static constexpr char* P00_param_ctype = (char*)"hls::stream<int> &";
		static constexpr long P00_param_dir = (long)2;
		static constexpr long P00_param_access = (long)1;
		static constexpr char* P00_sideband = (char*)"";
		static constexpr long P00_fifo_size = (long)0;
		static constexpr bool P00_pack_data = (bool)0;
		static constexpr bool P00_var_length = (bool)0;
		static constexpr bool P00_change_trigger = (bool)0;
		static constexpr long P00_out_delay = (long)0;

	   public:
		// Interfaces
		static const vsi::runtime::Inout control;
		// Local Connections
		// Cross Context Connections
	} display_0_inst;
	const vsi::runtime::Inout display_0::control(vsi::runtime::OUTPUT);
  	class fcorner_shmem : public vsi::runtime::vsi_mem {
		public:
		fcorner_shmem ();
		void init();
		virtual ~fcorner_shmem();
		void init_mem();

	   protected:
		static constexpr char *Component_Name = (char*)"fcorner_shmem";
		static constexpr long MEM_SIZE_KB = (long)1024;
		static constexpr long MEM_WIDTH_BYTES = (long)4;
		static constexpr long num_ports = (long)2;

	   public:
		// Interfaces
		static const vsi::runtime::Inout port_0;
		static const vsi::runtime::Inout port_1;
		// Local Connections
		static const vsi::runtime::Connect Connect_port_1;
		// Cross Context Connections
		static const vsi::runtime::Connect Connect_port_0;
	} fcorner_shmem_inst;
	void vsi_system::u96_ps::fcorner_shmem::init () {
		vsi::runtime::vsi_mem::init();
	}
	vsi_system::u96_ps::fcorner_shmem::~fcorner_shmem() {
		vsi::runtime::vsi_mem::port_0->munmap_connection();
	}
	void vsi_system::u96_ps::fcorner_shmem::init_mem() {
		mem = vsi::runtime::vsi_mem::port_0->mmap_connection();
	}
	const vsi::runtime::Inout fcorner_shmem::port_0(vsi::runtime::INPUT);
	const vsi::runtime::Inout fcorner_shmem::port_1(vsi::runtime::INPUT);
  	class minmax_shmem : public vsi::runtime::vsi_mem {
		public:
		minmax_shmem ();
		void init();
		virtual ~minmax_shmem();
		void init_mem();

	   protected:
		static constexpr char *Component_Name = (char*)"minmax_shmem";
		static constexpr long MEM_SIZE_KB = (long)1024;
		static constexpr long MEM_WIDTH_BYTES = (long)4;
		static constexpr long num_ports = (long)2;

	   public:
		// Interfaces
		static const vsi::runtime::Inout port_0;
		static const vsi::runtime::Inout port_1;
		// Local Connections
		static const vsi::runtime::Connect Connect_port_1;
		// Cross Context Connections
		static const vsi::runtime::Connect Connect_port_0;
	} minmax_shmem_inst;
	void vsi_system::u96_ps::minmax_shmem::init () {
		vsi::runtime::vsi_mem::init();
	}
	vsi_system::u96_ps::minmax_shmem::~minmax_shmem() {
		vsi::runtime::vsi_mem::port_0->munmap_connection();
	}
	void vsi_system::u96_ps::minmax_shmem::init_mem() {
		mem = vsi::runtime::vsi_mem::port_0->mmap_connection();
	}
	const vsi::runtime::Inout minmax_shmem::port_0(vsi::runtime::INPUT);
	const vsi::runtime::Inout minmax_shmem::port_1(vsi::runtime::INPUT);
  	class webcam_0 : public vsi::runtime::vsi_gen_ip {
		public:
		webcam_0 ();
		void exec_user_func ();

	   protected:
		static constexpr char *Component_Name = (char*)"webcam_0";
		static constexpr float EXEC_TIMER = (float)1;
		static constexpr long CPU_THREAD = (long)0;
		static constexpr long EXEC_TRIGGER = (long)1;
		static constexpr long THREAD_PRIORITY = (long)1;
		static constexpr long CPU_NUMBER = (long)1;
		static constexpr char* P00_param_name = (char*)"control";
		static constexpr long P00_param_size = (long)-2;
		static constexpr long P00_param_type = (long)3;
		static constexpr char* P00_param_ctype = (char*)"hls::stream<int> &";
		static constexpr long P00_param_dir = (long)1;
		static constexpr long P00_param_access = (long)1;
		static constexpr char* P00_sideband = (char*)"";
		static constexpr long P00_fifo_size = (long)0;
		static constexpr bool P00_pack_data = (bool)0;
		static constexpr bool P00_var_length = (bool)0;
		static constexpr bool P00_change_trigger = (bool)0;
		static constexpr long P00_out_delay = (long)0;
		static constexpr char* P01_param_name = (char*)"mem_mm";
		static constexpr long P01_param_size = (long)8;
		static constexpr long P01_param_type = (long)3;
		static constexpr char* P01_param_ctype = (char*)"vsi::device &";
		static constexpr long P01_param_dir = (long)3;
		static constexpr long P01_param_access = (long)3;
		static constexpr char* P01_sideband = (char*)"";
		static constexpr long P01_fifo_size = (long)0;
		static constexpr bool P01_pack_data = (bool)0;
		static constexpr bool P01_var_length = (bool)0;
		static constexpr bool P01_change_trigger = (bool)0;
		static constexpr long P01_out_delay = (long)0;
		static constexpr char* P02_param_name = (char*)"start_mm";
		static constexpr long P02_param_size = (long)-2;
		static constexpr long P02_param_type = (long)3;
		static constexpr char* P02_param_ctype = (char*)"hls::stream<st> &";
		static constexpr long P02_param_dir = (long)2;
		static constexpr long P02_param_access = (long)1;
		static constexpr char* P02_sideband = (char*)"data last";
		static constexpr long P02_fifo_size = (long)0;
		static constexpr bool P02_pack_data = (bool)0;
		static constexpr bool P02_var_length = (bool)0;
		static constexpr bool P02_change_trigger = (bool)0;
		static constexpr long P02_out_delay = (long)0;
		static constexpr char* P03_param_name = (char*)"done_mm";
		static constexpr long P03_param_size = (long)-2;
		static constexpr long P03_param_type = (long)3;
		static constexpr char* P03_param_ctype = (char*)"hls::stream<st> &";
		static constexpr long P03_param_dir = (long)1;
		static constexpr long P03_param_access = (long)1;
		static constexpr char* P03_sideband = (char*)"data last";
		static constexpr long P03_fifo_size = (long)0;
		static constexpr bool P03_pack_data = (bool)0;
		static constexpr bool P03_var_length = (bool)0;
		static constexpr bool P03_change_trigger = (bool)0;
		static constexpr long P03_out_delay = (long)0;
		static constexpr char* P04_param_name = (char*)"mem_fc";
		static constexpr long P04_param_size = (long)8;
		static constexpr long P04_param_type = (long)3;
		static constexpr char* P04_param_ctype = (char*)"vsi::device &";
		static constexpr long P04_param_dir = (long)3;
		static constexpr long P04_param_access = (long)3;
		static constexpr char* P04_sideband = (char*)"";
		static constexpr long P04_fifo_size = (long)0;
		static constexpr bool P04_pack_data = (bool)0;
		static constexpr bool P04_var_length = (bool)0;
		static constexpr bool P04_change_trigger = (bool)0;
		static constexpr long P04_out_delay = (long)0;
		static constexpr char* P05_param_name = (char*)"start_fc";
		static constexpr long P05_param_size = (long)-2;
		static constexpr long P05_param_type = (long)3;
		static constexpr char* P05_param_ctype = (char*)"hls::stream<st> &";
		static constexpr long P05_param_dir = (long)2;
		static constexpr long P05_param_access = (long)1;
		static constexpr char* P05_sideband = (char*)"data last";
		static constexpr long P05_fifo_size = (long)0;
		static constexpr bool P05_pack_data = (bool)0;
		static constexpr bool P05_var_length = (bool)0;
		static constexpr bool P05_change_trigger = (bool)0;
		static constexpr long P05_out_delay = (long)0;
		static constexpr char* P06_param_name = (char*)"done_fc";
		static constexpr long P06_param_size = (long)-2;
		static constexpr long P06_param_type = (long)3;
		static constexpr char* P06_param_ctype = (char*)"hls::stream<st> &";
		static constexpr long P06_param_dir = (long)1;
		static constexpr long P06_param_access = (long)1;
		static constexpr char* P06_sideband = (char*)"data last";
		static constexpr long P06_fifo_size = (long)0;
		static constexpr bool P06_pack_data = (bool)0;
		static constexpr bool P06_var_length = (bool)0;
		static constexpr bool P06_change_trigger = (bool)0;
		static constexpr long P06_out_delay = (long)0;

	   public:
		// Interfaces
		static const vsi::runtime::Inout control;
		static const vsi::runtime::Inout done_fc;
		static const vsi::runtime::Inout done_mm;
		static const vsi::runtime::Inout mem_fc;
		static const vsi::runtime::Inout mem_mm;
		static const vsi::runtime::Inout start_fc;
		static const vsi::runtime::Inout start_mm;
		// Local Connections
		static const vsi::runtime::Connect Connect_control;
		// Cross Context Connections
		static const vsi::runtime::Connect Connect_done_fc;
		static const vsi::runtime::Connect Connect_done_mm;
		static const vsi::runtime::Connect Connect_start_fc;
		static const vsi::runtime::Connect Connect_start_mm;
	} webcam_0_inst;
	const vsi::runtime::Inout webcam_0::control(vsi::runtime::INPUT);
	const vsi::runtime::Inout webcam_0::done_fc(vsi::runtime::INPUT);
	const vsi::runtime::Inout webcam_0::done_mm(vsi::runtime::INPUT);
	const vsi::runtime::Inout webcam_0::mem_fc(vsi::runtime::INOUT);
	const vsi::runtime::Inout webcam_0::mem_mm(vsi::runtime::INOUT);
	const vsi::runtime::Inout webcam_0::start_fc(vsi::runtime::OUTPUT);
	const vsi::runtime::Inout webcam_0::start_mm(vsi::runtime::OUTPUT);
   	// Local connections
	const vsi::runtime::Connect fcorner_shmem::Connect_port_1(fcorner_shmem::port_1, webcam_0::mem_fc, false, 0, false);
	const vsi::runtime::Connect minmax_shmem::Connect_port_1(minmax_shmem::port_1, webcam_0::mem_mm, false, 0, false);
	const vsi::runtime::Connect webcam_0::Connect_control(webcam_0::control, display_0::control, false, 0, false);
	// Interconnect connections
 
	// Connection to devices
    	const vsi::runtime::Connect fcorner_shmem::Connect_port_0(fcorner_shmem::port_0, vsi_system::u96_pl::pr_set_0_1::speedometer::io_frame, false, 0, false);
  	const vsi::runtime::Connect minmax_shmem::Connect_port_0(minmax_shmem::port_0, vsi_system::u96_pl::pr_set_0_0::min_max::io_frame, false, 0, false);
  	const vsi::runtime::Connect webcam_0::Connect_done_fc(webcam_0::done_fc, vsi_system::u96_pl::pr_set_0_1::speedometer::done, false, 0, false);
	const vsi::runtime::Connect webcam_0::Connect_done_mm(webcam_0::done_mm, vsi_system::u96_pl::pr_set_0_0::min_max::done, false, 0, false);
	const vsi::runtime::Connect webcam_0::Connect_start_fc(webcam_0::start_fc, vsi_system::u96_pl::pr_set_0_1::speedometer::start, false, 0, false);
	const vsi::runtime::Connect webcam_0::Connect_start_mm(webcam_0::start_mm, vsi_system::u96_pl::pr_set_0_0::min_max::start, false, 0, false);
   	// initialize the trace server for main context
	const vsi::runtime::Interconnect trace_server("Trace Server", "localhost", 7896, INTERCONNECT_MASTER);
 }
}
                  