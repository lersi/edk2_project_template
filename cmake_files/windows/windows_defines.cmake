cmake_minimum_required(VERSION 3.20)
##
# Globals
##
set(BUILD_SCRIPT _build.bat) # the name og the build script script to create
set(BUILD_ENV_VARIABLES PACKAGES_PATH) # list containing all enviroment variables needed for configuration and build
string(JOIN ";" PACKAGES_PATH ${PACKAGES_PATH})
set(DEFAULT_NASM_PATH "C:\\nasm")
set(DEFAULT_CLANG_PATH "C:\\Program Files\\LLVM\\bin")
set(SHELL_CMD "cmd")
set(SHELL_EXECUTE_ARG "/C")

##
# Helper functions
##
include(cmake_files/generic/helper_functions.cmake)

##
# set esential data
##
set(EDK_TOOLS_PATH ${EDK2_SOURCE}/BaseTools)
set_variable_to_native_path(EDK_TOOLS_PATH)
set(BASE_TOOLS_PATH ${EDK_TOOLS_PATH})
set(WORKSPACE_TOOLS_PATH ${EDK_TOOLS_PATH})
set(BASETOOLS_PYTHON_SOURCE ${BASE_TOOLS_PATH}\\Source\\Python)
set(WORKSPACE ${CMAKE_CURRENT_BINARY_DIR})
list(APPEND BUILD_ENV_VARIABLES WORKSPACE EDK_TOOLS_PATH BASE_TOOLS_PATH WORKSPACE_TOOLS_PATH)

##
# find python
##
include(cmake_files/generic/detect_python.cmake)
list(APPEND BUILD_ENV_VARIABLES PYTHON_COMMAND)

##
# find visual studio (toolchain)
##
# detects vs environment configuration script and the tool chain tag
include(cmake_files/windows/detect_visual_studio.cmake)
set(TOOL_CHAIN ${_VS_TAG})
message(NOTICE "using toolchain: ${TOOL_CHAIN}")

##
# find nasm
##
include(cmake_files/windows/detect_nasm.cmake)
if(DEFINED NASM_PREFIX)
    list(APPEND BUILD_ENV_VARIABLES NASM_PREFIX)
endif()

##
# find clang
##
include(cmake_files/windows/detect_clang.cmake)
if(DEFINED CLANG_BIN)
    list(APPEND BUILD_ENV_VARIABLES CLANG_BIN)
endif()

##
# make sure that edk2 build system is configured
##
set(CONF_PATH ${CMAKE_BINARY_DIR}\\conf CACHE PATH "where to save configuration for EDK build tools")
list(APPEND BUILD_ENV_VARIABLES CONF_PATH)
include(cmake_files/windows/configure_build_system.cmake)

##
# make sure base tools is compiled
##
include(cmake_files/windows/ensure_base_tools.cmake)
list(APPEND BUILD_ENV_VARIABLES EDK_TOOLS_BIN)

##
# check which bin dir to use
##
include(cmake_files/windows/select_edk_bin_dir.cmake)

##
# define interface functions for the build abi
##
include(cmake_files/windows/build_abi.cmake) 
