export INSTALL_PREFIX?=/home/sdowney/install
export PROJECT?=$(shell basename $(CURDIR))
export BUILD_DIR?=../cmake.bld/${PROJECT}
export CONFIGURATION_TYPES?=RelWithDebInfo;Debug;Tsan;Asan
export DEST?=../install
export CMAKE_FLAGS?=
export CONFIG?=RelWithDebInfo
export USE_DOCKER_FILE>=.use-docker

ifeq ($(strip $(TOOLCHAIN)),)
	_build_name?=build
	_build_dir?=../cmake.bld/${PROJECT}
	_configuration_types?="RelWithDebInfo;Debug;Tsan;Asan"
	_cmake_args=-DCMAKE_TOOLCHAIN_FILE=$(CURDIR)/etc/toolchain.cmake
else
	_build_name?=build-$(TOOLCHAIN)
	_build_dir?=../cmake.bld/${PROJECT}
	_configuration_types?="RelWithDebInfo;Debug;Tsan;Asan"
	_cmake_args=-DCMAKE_TOOLCHAIN_FILE=$(CURDIR)/etc/$(TOOLCHAIN)-toolchain.cmake
endif


_build_path?=$(_build_dir)/$(_build_name)

define run_cmake =
	cmake \
	-G "Ninja Multi-Config" \
	-DCMAKE_CONFIGURATION_TYPES=$(_configuration_types) \
	-DCMAKE_INSTALL_PREFIX=$(abspath $(INSTALL_PREFIX)) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	$(_cmake_args) \
	$(CURDIR)
endef

default: compile

$(_build_path):
	mkdir -p $(_build_path)

$(_build_path)/CMakeCache.txt: | $(_build_path) .gitmodules
	cd $(_build_path) && $(run_cmake)
	-rm compile_commands.json
	ln -s $(_build_path)/compile_commands.json

compile: $(_build_path)/CMakeCache.txt ## Compile the project
	cmake --build $(_build_path)  --config $(CONFIG) --target all -- -k 0

install: $(_build_path)/CMakeCache.txt ## Install the project
	DESTDIR=$(abspath $(DEST)) ninja -C $(_build_path) -k 0  install

ctest: $(_build_path)/CMakeCache.txt ## Run CTest on current build
	cd $(_build_path) && ctest

ctest_ : compile
	cd $(_build_path) && ctest

test: ctest_ ## Rebuild and run tests

cmake: |  $(_build_path)
	cd $(_build_path) && ${run_cmake}

clean: $(_build_path)/CMakeCache.txt ## Clean the build artifacts
	cmake --build $(_build_path)  --config $(CONFIG) --target clean

realclean: ## Delete the build directory
	rm -rf $(_build_path)
