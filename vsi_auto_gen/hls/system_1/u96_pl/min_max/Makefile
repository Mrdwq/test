SOLUTION_NUM ?= 1
RUN_SYNTH ?= n
MAX_SOLUTIONS ?= 4
PIPELINE_LOOP_DEPTH ?= 0
OUT_FILE_PATH := /solution$(SOLUTION_NUM)/impl/ip/component.xml
IP := min_max
IP_SRC := $(wildcard /home/dwq/Documents/Systemview/VSI/target/common/hls_examples/image_algos/*.c* )
IP_OUT := $(IP)$(OUT_FILE_PATH)
YAML_DIR := /home/dwq/Documents/Workspace/vsi_dfx_lab/vsi_auto_gen/yaml/kernels
YAML_REPORT := $(IP).$(SOLUTION_NUM).yaml
POWER_REPORT := power_solution.$(SOLUTION_NUM).xml
UTIL_REPORT := utilization_solution.$(SOLUTION_NUM).xml

null :=
space := $(null) #
comma := ,
define set_xml_files
xml_files=$(subst $(space),$(comma),$(wildcard ./$(IP)/solution$(SOLUTION_NUM)/syn/report/*_csynth.xml))
endef

all: $(IP_OUT) gen_report

$(IP_OUT): $(IP_SRC)
	@$(foreach file,$(IP_SRC),annotate_loops.sh $(file);)
	@env SOLUTION_NUM=$(SOLUTION_NUM) vivado_hls -f $(IP).tcl
ifeq ($(RUN_SYNTH),y)
	@vivado -mode batch -source ./gen_power_report.tcl -tclargs xczu3eg-sbva484-1-e $(SOLUTION_NUM) $(IP)
endif

gen_report: $(IP_OUT)
	@$(eval $(call set_xml_files))
	@hls_report_yaml -o $(YAML_DIR) --file $(xml_files) --out_file $(YAML_REPORT) --top min_max_shmem -s $(SOLUTION_NUM)
ifeq ($(RUN_SYNTH),y)
	@convert_synth_report -y $(YAML_DIR)/$(YAML_REPORT) -p $(POWER_REPORT) -u $(UTIL_REPORT) -t min_max_shmem
endif

explore:
	@hls_explore.sh `pwd` $(MAX_SOLUTIONS) min_max_shmem $(IP) $(PIPELINE_LOOP_DEPTH) $(YAML_DIR)

clean:
	rm -rf $(IP) ./annotated_src $(YAML_DIR)/$(IP).*.yaml
