.PHONY: help
help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make tsp_program "
	$(ECHO) "      Command to compile tsp-program"
	$(ECHO) ""
	$(ECHO) "  make tsp_host "
	$(ECHO) "      Command to compile tsp-host"
	$(ECHO) ""
	$(ECHO) "  make run-tsp-program "
	$(ECHO) "      Command to execute tsp-program"
	$(ECHO) ""
	$(ECHO) "  make run-tsp-host "
	$(ECHO) "      Command to execute tsp-host"
	$(ECHO) ""
	$(ECHO) "  make clean "
	$(ECHO) "      Command to remove tsp-host tsp-program and xrt tracing files"
	$(ECHO) ""
	$(ECHO) "  make clean-run "
	$(ECHO) "      Command to remove tsp-host tsp-program"
	$(ECHO) ""
	$(ECHO) "  make clean-xrt-report "
	$(ECHO) "      Command to remove xrt tracing files"

include $(HOME)/Desktop/TSP.temp/config/setting.mk
MYARGS = $(TEXTCSV) $(KEYCSV) $(LANGUAGE) $(SEARCHMODE) $(OUTPUTMODE) $(HOME)

CURRENT_DIR := $(shell pwd)
TEMP_DIR := $(HOME)/Desktop/TSP.temp/
RUN_DIR = $(TEMP_DIR)exe/
RESULT_HIT_DIR =  $(TEMP_DIR)result.hit/

PROGRAMHOST := tsp-program
TSPHOST := tsp-host
DEVICE := xilinx_u50_gen3x16_xdma_5_202210_1
XCLBINFILE := $(HOME)/Desktop/TSP.temp/bin/tsp_20221019.xclbin
CXX := g++
RM = rm -f
RMDIR = rm -rf
ECHO:= @echo

###################################################################
# G++ COMPILER FLAGS
######################################################################


# The below are linking flags for C++ Comnpiler
xrt_LDFLAGS += -L$(XILINX_XRT)/lib -lxrt_coreutil -pthread
LDFLAGS += $(xrt_LDFLAGS)
LDFLAGS += -lrt -lstdc++

# Host compiler global settings
host_CXXFLAGS += -g -I./ -I$(XILINX_XRT)/include -I$(XILINX_VIVADO)/include -Wall -O2 -g -std=c++1y
CXXFLAGS += -fmessage-length=0
CXXFLAGS += $(host_CXXFLAGS)

#  Host source and xclbin
HOST_SRCS_DIR = ./src/
PROGRAMHOST_SCRS += $(HOST_SRCS_DIR)tsp-program.cpp $(HOST_SRCS_DIR)utils.cpp $(HOST_SRCS_DIR)utils.h $(HOST_SRCS_DIR)tsp.h
TSPHOST_SCRS += $(HOST_SRCS_DIR)tsp-host.cpp $(HOST_SRCS_DIR)utils.cpp $(HOST_SRCS_DIR)utils.h $(HOST_SRCS_DIR)tsp.h


$(PROGRAMHOST): $(PROGRAMHOST_SCRS)
	$(CXX) $(CXXFLAGS) $(PROGRAMHOST_SCRS) -o '$@' $(LDFLAGS)
	cp -f $(PROGRAMHOST) $(RUN_DIR)

$(TSPHOST): $(TSPHOST_SCRS)
	$(CXX) $(CXXFLAGS) $(TSPHOST_SCRS) -o '$@' $(LDFLAGS)
	cp -f $(TSPHOST) $(RUN_DIR)

run-tsp-program:
	./$(PROGRAMHOST) $(XCLBINFILE) $(MYARGS)

run-tsp-host:
	rm -rf $(RESULT_HIT_DIR)
	mkdir $(RESULT_HIT_DIR)
	./$(TSPHOST) $(XCLBINFILE) $(MYARGS)

clean:
	$(RM) $(PROGRAMHOST) $(TSPHOST) native_trace.csv summary.csv xrt.run_summary

clean-run:
	$(RM) $(PROGRAMHOST) $(TSPHOST)
	
clean-xrt-report:
	$(RM) native_trace.csv summary.csv xrt.run_summary
	
print:
	$(ECHO) $(RUN_DIR)
	$(ECHO) $(HOME)
	cd .. && pwd
	

