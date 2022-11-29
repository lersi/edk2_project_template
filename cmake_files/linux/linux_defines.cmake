cmake_minimum_required(VERSION 3.20)
##
# Globals
##
set(BUILD_ENV_VARIABLES PACKAGES_PATH)
set(BUILD_SCRIPT _build.sh)
string(JOIN ":" PACKAGES_PATH ${PACKAGES_PATH})
set(SHELL_CMD "/bin/bash")
set(SHELL_EXECUTE_ARG "-c")

##
# decide which tool chain to use
##
include(cmake_files/linux/detect_tool_chain.cmake)
list(APPEND BUILD_ENV_VARIABLES TARGET_TOOLS)

##
# set esential data
##
set(EDK_TOOLS_PATH ${EDK2_SOURCE}/BaseTools)
set(WORKSPACE ${CMAKE_CURRENT_BINARY_DIR})
include(cmake_files/generic/detect_python.cmake)
list(APPEND BUILD_ENV_VARIABLES WORKSPACE PYTHON_COMMAND EDK_TOOLS_PATH)

##
# make sure that edk2 build system is configured
##
set(CONF_PATH ${CMAKE_BINARY_DIR}/conf CACHE PATH "where to save configuration for EDK build tools")
list(APPEND BUILD_ENV_VARIABLES CONF_PATH)
include(cmake_files/unix/configure_build_system.cmake)

##
# make sure base tools is compiled
##
include(cmake_files/unix/ensure_basetools.cmake)

##
# select which bin dir to use
##
include(cmake_files/unix/select_edk_bin_dir.cmake)

##
# define interface functions for the build abi
##
include(cmake_files/unix/build_abi.cmake) 

##
# define architecture related staff
##
# arm 64
set(AARCH64_PREFIX "aarch64-linux-gnu-" CACHE STRING "the prefix for gcc command for arm64 compilation")
set("${TOOL_CHAIN}_AARCH64_PREFIX" ${AARCH64_PREFIX})
# arm (32 bit)
set(ARM_PREFIX "arm-linux-gnueabi-" CACHE STRING "the prefix for gcc command for arm compilation")
set("${TOOL_CHAIN}_ARM_PREFIX" ${ARM_PREFIX})
list(APPEND BUILD_ENV_VARIABLES "${TOOL_CHAIN}_AARCH64_PREFIX" "${TOOL_CHAIN}_ARM_PREFIX")
