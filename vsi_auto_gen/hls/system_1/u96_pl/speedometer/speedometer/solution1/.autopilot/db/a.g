#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/dwq/Documents/Workspace/vsi_dfx_lab/vsi_auto_gen/hls/system_1/u96_pl/speedometer/speedometer/solution1/.autopilot/db/a.g.bc ${1+"$@"}
