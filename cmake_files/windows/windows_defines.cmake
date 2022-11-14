cmake_minimum_required(VERSION 3.20)
##
# Globals
##
set(BUILD_SCRIPT _build.bat) # the name og the build script script to create
set(BUILD_ENV_VARIABLES PACKAGES_PATH) # list containing all enviroment variables needed for configuration and build
string(JOIN ";" PACKAGES_PATH ${PACKAGES_PATH})
set(DEFAULT_NASM_PATH "C:\\nasm")
set(DEFAULT_CLANG_PATH "C:\\Program Files\\LLVM\\bin")


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
# description: this function creates a Cmake target for a package.
# 
# arg1: PKG_NAME  the name of the package to create a target for
# arg2: BUILD_ARGS  list of argument to pass to edk's build system
##
function(internal_add_package PKG_NAME BUILD_ARGS)
    # list all files in our pkg
    file(GLOB_RECURSE PKG_SOURCE_FILES
        LIST_DIRECTORIES false
        ${PACKAGE_DIR}/${PKG_NAME}/**
    )

    # generate build script
    set(EXPORTED_ENV "")
    foreach(var_name ${BUILD_ENV_VARIABLES})
        set(var_value "${${var_name}}")
        set_variable_to_native_path(var_value)
        string(FIND "${var_value}" " " has_space)
        if(${has_space} GREATER_EQUAL 0)
            string(APPEND EXPORTED_ENV "\n" "set ${var_name}=\"${var_value}\"")
        else()
            string(APPEND EXPORTED_ENV "\n" "set ${var_name}=${var_value}")
        endif()
    endforeach()
    
    string(JOIN "\n" script_content
        "@echo off"
        "set PYTHONHASHSEED=1"
        "@set CLANG_HOST_BIN=n"
        # "if not defined DevEnvDir ("
        "call \"${VS_ENVIRONMENT_SCRIPT}\""
        # ")"
        "call \"${BASE_TOOLS_PATH}\\set_vsprefix_envs.bat\""
        "${EXPORTED_ENV}"
        "set PATH=${EDK_TOOLS_BIN};${EDK_BIN_WRAPPERS};\%PATH\%"
        "set PYTHONPATH=${BASETOOLS_PYTHON_SOURCE};%PYTHONPATH%"
        "echo build \%*"
        "build \%*"
    )
    set(SCRIPT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_SCRIPT})
    file(GENERATE OUTPUT ${SCRIPT_PATH}
        CONTENT "${script_content}"
        FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        NEWLINE_STYLE WIN32
    )
    # create the target
    add_custom_target(${PKG_NAME}
        ${SCRIPT_PATH} ${BUILD_ARGS} 
        SOURCES ${PKG_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} 
        USES_TERMINAL
    )
endfunction()

function(add_package PKG_NAME BUILD_ARGS)
    set(BUILD_LIST "")
    list(APPEND BUILD_LIST ${BUILD_ARGS})
    list(APPEND BUILD_LIST ${ARGN})
    internal_add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()
