#!/bin/bash

TARGET_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

env VSI_LOG_LVL=info VSI_LOG_COMPS=all ${TARGET_DIR}/u96_ps
