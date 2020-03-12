#!/bin/sh
# ------------------------------------------------------------------------------
# Generation time: 2020-03-12 04:16:47
# ------------------------------------------------------------------------------
major_number_u96_pl=241


 


 
# device node for vsi_system/u96_ps/fcorner_shmem/port_0
rm -f /dev/u96_pl_pr_set_0_1_speedometer_io_frame
mknod /dev/u96_pl_pr_set_0_1_speedometer_io_frame c ${major_number_u96_pl} 0
chown root /dev/u96_pl_pr_set_0_1_speedometer_io_frame
chmod 666 /dev/u96_pl_pr_set_0_1_speedometer_io_frame

 
# device node for vsi_system/u96_ps/minmax_shmem/port_0
rm -f /dev/u96_pl_pr_set_0_0_min_max_io_frame
mknod /dev/u96_pl_pr_set_0_0_min_max_io_frame c ${major_number_u96_pl} 1
chown root /dev/u96_pl_pr_set_0_0_min_max_io_frame
chmod 666 /dev/u96_pl_pr_set_0_0_min_max_io_frame

 
# device node for vsi_system/u96_ps/webcam_0/done_fc
rm -f /dev/u96_pl_pr_set_0_1_speedometer_done
mknod /dev/u96_pl_pr_set_0_1_speedometer_done c ${major_number_u96_pl} 2
chown root /dev/u96_pl_pr_set_0_1_speedometer_done
chmod 666 /dev/u96_pl_pr_set_0_1_speedometer_done

 
# device node for vsi_system/u96_ps/webcam_0/done_mm
rm -f /dev/u96_pl_pr_set_0_0_min_max_done
mknod /dev/u96_pl_pr_set_0_0_min_max_done c ${major_number_u96_pl} 3
chown root /dev/u96_pl_pr_set_0_0_min_max_done
chmod 666 /dev/u96_pl_pr_set_0_0_min_max_done

 
# device node for vsi_system/u96_ps/webcam_0/start_fc
rm -f /dev/u96_pl_pr_set_0_1_speedometer_start
mknod /dev/u96_pl_pr_set_0_1_speedometer_start c ${major_number_u96_pl} 4
chown root /dev/u96_pl_pr_set_0_1_speedometer_start
chmod 666 /dev/u96_pl_pr_set_0_1_speedometer_start

 
# device node for vsi_system/u96_ps/webcam_0/start_mm
rm -f /dev/u96_pl_pr_set_0_0_min_max_start
mknod /dev/u96_pl_pr_set_0_0_min_max_start c ${major_number_u96_pl} 5
chown root /dev/u96_pl_pr_set_0_0_min_max_start
chmod 666 /dev/u96_pl_pr_set_0_0_min_max_start


# Copy firmware for u96_pl
cp u96_pl.bit.bin /lib/firmware/ 
cp vsi_system_u96_pl_pr_set_0_1.bit.bin /lib/firmware/u96_pl_pr_set_0_1.bit.bin
cp vsi_system_u96_pl_pr_set_0_0.bit.bin /lib/firmware/u96_pl_pr_set_0_0.bit.bin

# Download default bitstream
echo u96_pl.bit.bin > /sys/class/fpga_manager/fpga0/firmware

# Initialize processing system
./p_u96_pl_zynq_ultra_ps_e_0_init

# Loading FPGA Driver
# Driver type: zynq
rmmod -s vsi_driver.ko 2> /dev/null
insmod vsi_driver.ko \
  axi2pcie_bar0_size=2097152 \
  back_pressure=1 \
  cdma_address=0x80001000 \
  device_id=0x7028 \
  dma_byte_width=8 \
  dma_file_size=4096 \
  dma_system_size=1048576 \
  driver_type=2 \
  int_ctlr_address=2147483648 \
  lod_ctlr_address=2147524608 \
  major=${major_number_u96_pl} \
  pcie_bar_address=0x80000000 \
  pcie_ctl_address=2281701376 \
  pcie_use_xdma=0 \
  vendor_id=0x10ee \
  keyhole_prohibited=0
# check if module intall corectly
if [ ! $? = 0 ]; then
	echo "Error: Kernel module did not load properly."
	echo "FAILED"
	exit 1
fi

