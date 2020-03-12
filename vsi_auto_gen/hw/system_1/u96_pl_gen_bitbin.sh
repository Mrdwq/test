#!/bin/bash
echo "all: { [destination_device = pl] $1 }" > tmp.bif
bootgen -w -image tmp.bif -arch zynqmp -o $1.bin
