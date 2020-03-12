__soa_out = ""
import os
import systemview as sv
vsiautogen_dir = sv.get_dir(sv.VSI_DIRS.VSIAUTOGEN)
yaml_dir = os.path.join(str(vsiautogen_dir),"yaml","kernels")
if not os.path.exists(yaml_dir):
    os.makedirs(yaml_dir)
if "soft_ip" in str(b.vlnv):
    dirs = utils.expand_env(b.ENV_SOURCE_DIR).split(',')
else:
    enc_base_data = str([x.value for x in b.params if x.name == "BASE_DATA"][0])
    import base64, json; base_data = json.loads(base64.b64decode(enc_base_data).decode())
    dirs = [os.path.dirname(base_data['file'])]
func_name = b.vlnv.name if b.vlnv.library == "vsi_model_composer" else str(b.c_func_name).split()[0]
__soa_out += """
SOLUTION_NUM ?= 1
RUN_SYNTH ?= n
MAX_SOLUTIONS ?= 4
PIPELINE_LOOP_DEPTH ?= 0
OUT_FILE_PATH := /solution$(SOLUTION_NUM)/impl/ip/component.xml
IP := """
__soa_nodes[31].val = str(b.name)
__soa_out += __soa_nodes[31].val
__soa_out += """
IP_SRC := $(wildcard"""
for d in dirs:
    if d:
        __soa_out += """ """
        __soa_nodes[36].val = str(d)
        __soa_out += __soa_nodes[36].val
        __soa_out += """/*.c*"""
__soa_out += """ )
IP_OUT := $(IP)$(OUT_FILE_PATH)
YAML_DIR := """
__soa_nodes[41].val = str(yaml_dir)
__soa_out += __soa_nodes[41].val
__soa_out += """
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
	@vivado -mode batch -source ./gen_power_report.tcl -tclargs """
__soa_nodes[43].val = str(str(b.ctx.fpga_part))
__soa_out += __soa_nodes[43].val
__soa_out += """ $(SOLUTION_NUM) $(IP)
endif

gen_report: $(IP_OUT)
	@$(eval $(call set_xml_files))
	@hls_report_yaml -o $(YAML_DIR) --file $(xml_files) --out_file $(YAML_REPORT) --top """
__soa_nodes[45].val = str(str(b.c_func_name).split()[0])
__soa_out += __soa_nodes[45].val
__soa_out += """ -s $(SOLUTION_NUM)
ifeq ($(RUN_SYNTH),y)
	@convert_synth_report -y $(YAML_DIR)/$(YAML_REPORT) -p $(POWER_REPORT) -u $(UTIL_REPORT) -t """
__soa_nodes[47].val = str(str(b.c_func_name).split()[0])
__soa_out += __soa_nodes[47].val
__soa_out += """
endif

explore:
	@hls_explore.sh `pwd` $(MAX_SOLUTIONS) """
__soa_nodes[49].val = str(str(b.c_func_name).split()[0])
__soa_out += __soa_nodes[49].val
__soa_out += """ $(IP) $(PIPELINE_LOOP_DEPTH) $(YAML_DIR)

clean:
	rm -rf $(IP) ./annotated_src $(YAML_DIR)/$(IP).*.yaml
"""
if __soa_last_callback:__soa_last_callback(__soa_state(), {**globals(), **locals()})
