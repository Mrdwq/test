__soa_out = ""
__soa_out += """
SUBDIRS := $(wildcard */.)
EXPLOREDIRS := $(SUBDIRS:%=explore-%)
CLEANDIRS := $(SUBDIRS:%=clean-%)
SOLUTION_NUM ?= 1
RUN_SYNTH ?= n
MAX_SOLUTIONS ?= 4
PIPELINE_LOOP_DEPTH ?= 0

.PHONY: all clean $(SUBDIRS)

all: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@

clean: $(CLEANDIRS)
$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean

explore: $(EXPLOREDIRS)
$(EXPLOREDIRS):
	$(MAKE) -C $(@:explore-%=%) explore RUN_SYNTH=$(RUN_SYNTH) MAX_SOLUTIONS=$(MAX_SOLUTIONS) PIPELINE_LOOP_DEPTH=$(PIPELINE_LOOP_DEPTH)
"""
if __soa_last_callback:__soa_last_callback(__soa_state(), {**globals(), **locals()})
