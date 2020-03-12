void init_hardware_io() {
	vsi::runtime::Runtime::Get().add_lodgroup("hardware", "xczu3eg-sbva484-1-e", "u96_pl", "pr_set_0");
	vsi::runtime::Runtime::Get().add_lodgroup("hardware", "xczu3eg-sbva484-1-e", "u96_pl", "pr_set_0");
	// connect to the trace server for main context
	vsi::runtime::Trace::Get().set_data_out(const_cast<vsi::runtime::Interconnect&>(vsi_system::u96_ps::trace_server).default_link());

                 
	// Device Interconnect for u96_pl_pr_set_0_1_speedometer_io_frame
	vsi::runtime::Inout &u96_pl_pr_set_0_1_speedometer_io_frame = const_cast<vsi::runtime::Inout&>(vsi_system::u96_pl::pr_set_0_1::speedometer::io_frame);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_device("/dev/u96_pl_pr_set_0_1_speedometer_io_frame", O_RDWR);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_address(0x0, 4294967296);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_dma_size(76800);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_mem_connection();
	u96_pl_pr_set_0_1_speedometer_io_frame.set_device_control_address(0x88010000, 65536);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_decoupler(0);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_device_mode(2);
	u96_pl_pr_set_0_1_speedometer_io_frame.set_vsi_device();
	u96_pl_pr_set_0_1_speedometer_io_frame.init_device();
	vsi::runtime::Runtime::Get().add_lodgroup_activation("pr_set_0", 1, [&] {
	u96_pl_pr_set_0_1_speedometer_io_frame.activate();
	}, [&] {
	u96_pl_pr_set_0_1_speedometer_io_frame.deactivate();
	});
                     
	// Device Interconnect for u96_pl_pr_set_0_0_min_max_io_frame
	vsi::runtime::Inout &u96_pl_pr_set_0_0_min_max_io_frame = const_cast<vsi::runtime::Inout&>(vsi_system::u96_pl::pr_set_0_0::min_max::io_frame);
	u96_pl_pr_set_0_0_min_max_io_frame.set_device("/dev/u96_pl_pr_set_0_0_min_max_io_frame", O_RDWR);
	u96_pl_pr_set_0_0_min_max_io_frame.set_address(0x0, 4294967296);
	u96_pl_pr_set_0_0_min_max_io_frame.set_dma_size(76800);
	u96_pl_pr_set_0_0_min_max_io_frame.set_mem_connection();
	u96_pl_pr_set_0_0_min_max_io_frame.set_device_control_address(0x88000000, 65536);
	u96_pl_pr_set_0_0_min_max_io_frame.set_decoupler(0);
	u96_pl_pr_set_0_0_min_max_io_frame.set_device_mode(2);
	u96_pl_pr_set_0_0_min_max_io_frame.set_vsi_device();
	u96_pl_pr_set_0_0_min_max_io_frame.init_device();
	vsi::runtime::Runtime::Get().add_lodgroup_activation("pr_set_0", 0, [&] {
	u96_pl_pr_set_0_0_min_max_io_frame.activate();
	}, [&] {
	u96_pl_pr_set_0_0_min_max_io_frame.deactivate();
	});
                 
	const_cast<vsi::runtime::Connect&>(vsi_system::u96_ps::webcam_0::Connect_start_mm).set_load_on_demand("pr_set_0", 0);
	// Device Interconnect for u96_pl_pr_set_0_0_min_max_start
	vsi::runtime::Inout &u96_pl_pr_set_0_0_min_max_start = const_cast<vsi::runtime::Inout&>(vsi_system::u96_pl::pr_set_0_0::min_max::start);
	u96_pl_pr_set_0_0_min_max_start.set_device("/dev/u96_pl_pr_set_0_0_min_max_start", O_RDWR);
	u96_pl_pr_set_0_0_min_max_start.set_address(0x300000000, 4096);
	u96_pl_pr_set_0_0_min_max_start.set_dma_size(4096);
	u96_pl_pr_set_0_0_min_max_start.set_device_control_address(0x88030000, 65536);
	u96_pl_pr_set_0_0_min_max_start.set_decoupler(0);
	u96_pl_pr_set_0_0_min_max_start.set_device_mode(4);
	u96_pl_pr_set_0_0_min_max_start.init_device();
	vsi::runtime::Runtime::Get().add_lodgroup_activation("pr_set_0", 0, [&] {
	u96_pl_pr_set_0_0_min_max_start.activate();
	}, [&] {
	u96_pl_pr_set_0_0_min_max_start.deactivate();
	});
         
	const_cast<vsi::runtime::Connect&>(vsi_system::u96_ps::webcam_0::Connect_start_fc).set_load_on_demand("pr_set_0", 1);
	// Device Interconnect for u96_pl_pr_set_0_1_speedometer_start
	vsi::runtime::Inout &u96_pl_pr_set_0_1_speedometer_start = const_cast<vsi::runtime::Inout&>(vsi_system::u96_pl::pr_set_0_1::speedometer::start);
	u96_pl_pr_set_0_1_speedometer_start.set_device("/dev/u96_pl_pr_set_0_1_speedometer_start", O_RDWR);
	u96_pl_pr_set_0_1_speedometer_start.set_address(0x300010000, 4096);
	u96_pl_pr_set_0_1_speedometer_start.set_dma_size(4096);
	u96_pl_pr_set_0_1_speedometer_start.set_device_control_address(0x88050000, 65536);
	u96_pl_pr_set_0_1_speedometer_start.set_decoupler(0);
	u96_pl_pr_set_0_1_speedometer_start.set_device_mode(4);
	u96_pl_pr_set_0_1_speedometer_start.init_device();
	vsi::runtime::Runtime::Get().add_lodgroup_activation("pr_set_0", 1, [&] {
	u96_pl_pr_set_0_1_speedometer_start.activate();
	}, [&] {
	u96_pl_pr_set_0_1_speedometer_start.deactivate();
	});
               
	// Device Interconnect for u96_pl_pr_set_0_1_speedometer_done
	vsi::runtime::Inout &u96_pl_pr_set_0_1_speedometer_done = const_cast<vsi::runtime::Inout&>(vsi_system::u96_pl::pr_set_0_1::speedometer::done);
	u96_pl_pr_set_0_1_speedometer_done.set_device("/dev/u96_pl_pr_set_0_1_speedometer_done", O_RDWR);
	u96_pl_pr_set_0_1_speedometer_done.set_address(0x200010000, 32768);
	u96_pl_pr_set_0_1_speedometer_done.set_dma_size(4096);
	u96_pl_pr_set_0_1_speedometer_done.set_interrupt(4);
	u96_pl_pr_set_0_1_speedometer_done.set_device_control_address(0x88040000, 65536);
	u96_pl_pr_set_0_1_speedometer_done.set_decoupler(0);
	u96_pl_pr_set_0_1_speedometer_done.set_device_mode(4);
	u96_pl_pr_set_0_1_speedometer_done.init_device();
	vsi::runtime::Runtime::Get().add_lodgroup_activation("pr_set_0", 1, [&] {
	u96_pl_pr_set_0_1_speedometer_done.activate();
	}, [&] {
	u96_pl_pr_set_0_1_speedometer_done.deactivate();
	});
         
	// Device Interconnect for u96_pl_pr_set_0_0_min_max_done
	vsi::runtime::Inout &u96_pl_pr_set_0_0_min_max_done = const_cast<vsi::runtime::Inout&>(vsi_system::u96_pl::pr_set_0_0::min_max::done);
	u96_pl_pr_set_0_0_min_max_done.set_device("/dev/u96_pl_pr_set_0_0_min_max_done", O_RDWR);
	u96_pl_pr_set_0_0_min_max_done.set_address(0x200000000, 32768);
	u96_pl_pr_set_0_0_min_max_done.set_dma_size(4096);
	u96_pl_pr_set_0_0_min_max_done.set_interrupt(3);
	u96_pl_pr_set_0_0_min_max_done.set_device_control_address(0x88020000, 65536);
	u96_pl_pr_set_0_0_min_max_done.set_decoupler(0);
	u96_pl_pr_set_0_0_min_max_done.set_device_mode(4);
	u96_pl_pr_set_0_0_min_max_done.init_device();
	vsi::runtime::Runtime::Get().add_lodgroup_activation("pr_set_0", 0, [&] {
	u96_pl_pr_set_0_0_min_max_done.activate();
	}, [&] {
	u96_pl_pr_set_0_0_min_max_done.deactivate();
	});
               
 vsi::runtime::Trace::Get().init();
}