cmake_minimum_required(VERSION 3.20)
##
# Globals
##
set(BUILD_ENV_VARIABLES PACKAGES_PATH)
set(BUILD_SCRIP _build.sh)
string(JOIN ":" PACKAGES_PATH ${PACKAGES_PATH})

##
# decide which tool chain to use
##
if(NOT DEFINED TOOL_CHAIN)
    # executing these commands in pipe will get darwin major version
    execute_process(
        COMMAND gcc --version
        COMMAND head -n 1
        COMMAND awk "{print $4}"
        OUTPUT_VARIABLE GCC_VERSION
    )

    
    if(${GCC_VERSION} VERSION_LESS 4.8)
    # edk2 requires gcc 4.8 and later
        message(FATAL_ERROR "EDK2 required gcc version of 4.8 or later")
    elseif(${GCC_VERSION} VERSION_LESS 4.9)
    # gcc is version 4.8.x
        set(TOOL_CHAIN "GCC48" CACHE INTERNAL "")
    elseif(${GCC_VERSION} VERSION_LESS 5.0)
    # gcc is version 4.9.x
        set(TOOL_CHAIN "GCC49" CACHE INTERNAL "")
    else()
    # gcc is version 5.0 or later
        set(TOOL_CHAIN "GCC5" CACHE INTERNAL "")
    endif()
    
endif()
message(NOTICE "using toolchain: ${TOOL_CHAIN}")
set(TARGET_TOOLS "${TOOL_CHAIN}")
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
        string(APPEND EXPORTED_ENV "\n" "export ${var_name}=\"${var_value}\"")
    endforeach()
    
    string(JOIN "\n" script_content
        "#!/bin/bash"
        "${EXPORTED_ENV}"
        "export PATH=${EDK_BIN_WRAPPERS}:$PATH"
        "echo build $@"
        "build $@"
    )
    set(SCRIPT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_SCRIP})
    file(GENERATE OUTPUT ${SCRIPT_PATH}
        CONTENT ${script_content}
        FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        NEWLINE_STYLE UNIX
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
