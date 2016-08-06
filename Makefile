#
# Immutable-Cpp Makefile
#
# A handy script for building/installing/running the 'immutable' c++ library
#

TARGET ?= debug
CXX ?= g++
AR ?= ar
CURL ?= curl

CXX_EXE = ${CXX} ${CXXFLAGS_${TARGET}}

CXXFLAGS += -Wall -std=c++1y
CXXFLAGS_debug := -O0 -g ${CXXFLAGS}
CXXFLAGS_release := -O3 ${CXXFLAGS}


HEADERS = $(subst immutable/,,$(shell find -X immutable -name *.h))
SRCS = $(subst immutable/,,$(shell find -X immutable -name *.cc))

OBJECTS = $(addprefix build/${TARGET}/obj/,$(subst /,_,$(patsubst %.cc,%.o,${SRCS})))

DEPS := $(OBJS:.o=.d)
-include $(OBJECTS:.o=.d)

.PHONY: help all build build_debug build_release get-deps test clean

help:
	@echo ''
	@echo '*'
	@echo '* This is a makefile to automate building and testing of the immutable c++ library.'
	@echo '*'
	@echo ''
	@echo 'To build:'
	@echo '   $ make all'
	@echo ''
	@echo 'To test:'
	@echo '   $ make test'
	@echo '  - Note: this will download the bandit testing framework'
	@echo ''
	@echo 'To clean bulid directory:'
	@echo '   $ make clean'
	@echo ''
	@echo 'To fetch and compile dependencies:'
	@echo '   $ make get-deps'
	@echo ''
	@echo 'Environment Variables'
	@echo '====================='
	@echo '  TARGET (release|debug) - select compiler flags and output directory, build/$${TARGET}'
	@echo "   - currently: ${TARGET}\n"
	@echo '  CXX - Select c++ compiler'
	@echo "   - currently: ${CXX}\n"
	@echo '  CXXFLAGS - Override flags for compiler'
	@echo "   - currently: ${CXXFLAGS}\n"
	@echo '  CURL - Command used to fetch remote dependencies'
	@echo "   - currently: ${CURL}\n"

all: build

build: build_${TARGET}

build_debug: build/debug/lib/libimmutable.a
build_release: build/release/lib/libimmutable.a


%/bin/test: %/obj/test.o %/lib/libimmutable.a
	@mkdir -p $(shell dirname $@)
	${CXX_EXE} -o $@ $^

build/${TARGET}/obj/test.o: tests/test.cc tests/test.h
	@mkdir -p $(shell dirname $@)
	${CXX_EXE} -MM -MT $@ -MF $(patsubst %.o,%.d,$@) $<
	${CXX_EXE} -c -o build/${TARGET}/obj/test.o $<

build/${TARGET}/obj/%.o: immutable/%.cc
	@mkdir -p $(shell dirname $@)
	${CXX_EXE} -MM -MT $@ -MF $(patsubst %.o,%.d,$@) $<
	${CXX_EXE} -c -o $@ $<

build/${TARGET}/lib/libimmutable.a: ${OBJECTS}
	@mkdir -p $(shell dirname $@)
	${AR} cr $@ ${OBJECTS}

test: build/${TARGET}/bin/test
	@echo "## Running tests in '${TARGET}' mode ##\n"
	$<

get-deps: get-deps-test
get-deps-test: vendor/bandit-${BANDIT_VERSION}


BANDIT_VERSION = 2.0.0
BANDIT_TGZ_URL = https://github.com/joakimkarlsson/bandit/archive/v${BANDIT_VERSION}.tar.gz
vendor/bandit-%:
	@if [[ ! -d vendor ]]; then mkdir vendor; fi
	${CURL} -L ${BANDIT_TGZ_URL} | tar -xz -C vendor

clean:
	rm -rf build/debug
	rm -rf build/release
