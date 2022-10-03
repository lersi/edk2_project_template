cmake_minimum_required(VERSION 3.20)
##
# Globals
##
set(BUILD_SCRIPT build.bat) # the name og the build script script to create
set(BUILD_ENV_VARIABLES PACKAGES_PATH) # list containing all enviroment variables needed for configuration and build
string(JOIN ":" PACKAGES_PATH ${PACKAGES_PATH})
set(DEFAULT_NASM_PATH "C:\\nasm")

##
# Helper functions
##
function(_set_variable_to_native_path var_name)
    cmake_path(CONVERT ${${var_name}} TO_NATIVE_PATH_LIST result NORMALIZE)
    set(${var_name} ${result} PARENT_SCOPE)
endfunction()

##
# set esential data
##
set(EDK_TOOLS_PATH ${EDK2_SOURCE}/BaseTools)
set(WORKSPACE ${CMAKE_CURRENT_BINARY_DIR})
list(APPEND BUILD_ENV_VARIABLES WORKSPACE EDK_TOOLS_PATH)

##
# find python
##
if(NOT DEFINED PYTHON_COMMAND)
    # searching for python command location
    find_package (Python3 3.7 QUIET COMPONENTS Interpreter)
    if(NOT ${Python3_Interpreter_FOUND})
    # python location was not found
        string(CONCAT error_msg
            "could not find the location of the python command (or your python is older than 3.7), \n"
            "please use `-DPYTHON_COMMAND=<path to your python interperter>`\n"
            "to declare the python interperter for use"
        )
        message(SEND_ERROR ${error_msg})
    else()
    # show python loocation to user, and save to cache
        message(NOTICE "found python command at: ${Python3_EXECUTABLE}")
        set(PYTHON_COMMAND ${Python3_EXECUTABLE} CACHE FILEPATH "path to python interperter" FORCE)
    endif()
endif()
list(APPEND BUILD_ENV_VARIABLES PYTHON_COMMAND)

##
# find visual studio (toolchain)
##
# detects vs environment configuration script and the tool chain tag
include(cmake_files/detect_visual_studio.cmake)
set(TOOL_CHAIN ${_VS_TAG})

message(NOTICE "using toolchain: ${TOOL_CHAIN}")

##
# find nasm
##
if(DEFINED NASM_PATH)
    set(NASM_PREFIX ${NASM_PATH} CACHE INTERNAL "path to nasm insall dir" FORCE)
elseif(NOT DEFINED CACHE{NASM_PREFIX})
    # setting up for the first time
    set(default_nasm_exec "${DEFAULT_NASM_PATH}\\nasm.exe")
    # check for default location first
    if(EXISTS default_nasm_exec)
        set(NASM_PREFIX ${DEFAULT_NASM_PATH} CACHE INTERNAL "path to nasm insall dir" FORCE)
    else()
    # try to find nasm from path
        execute_process(
            COMMAND cmd /C where nasm
            OUTPUT_VARIABLE output
            ERROR_QUIET
            RESULT_VARIABLE run_result
        )
        if(${run_result} EQUAL 0)
            # found nasm
            string(STRIP ${output} nasm_cmd_path)
            get_filename_component(nasm_path ${nasm_cmd_path} DIRECTORY)
            set(NASM_PREFIX ${nasm_path} CACHE INTERNAL "path to nasm insall dir" FORCE)
        else()
            message(WARNING "cound not find nasm, components that uses nasm will fail to compile")
            message(WARNING "you can specify nasm's directory by setting `NASM_PATH`")
        endif()
    endif()
endif()

list(APPEND BUILD_ENV_VARIABLES NASM_PREFIX)

##
# find clang
##


##
# make sure that edk2 build system is configured
##
set(CONF_PATH ${CMAKE_BINARY_DIR}/conf CACHE PATH "where to save configuration for EDK build tools")
list(APPEND BUILD_ENV_VARIABLES CONF_PATH)

if((NOT EXISTS ${CONF_PATH}) OR (NOT EXISTS ${CONF_PATH}/tools_def.txt))
    make_directory(${CONF_PATH})
    set(ENV{RECONFIG} "TRUE")
    foreach(var_name ${BUILD_ENV_VARIABLES})
        _set_variable_to_native_path(${var_name})
        set(ENV{${var_name}} "${${var_name}}")
        message(NOTICE "${var_name} = ${${var_name}}")
    endforeach()

    message("configuration does not exist, generating it")
    execute_process(
        COMMAND  "${EDK_TOOLS_PATH}\\toolsetup.bat" Reconfig ${TOOL_CHAIN}
        OUTPUT_VARIABLE conf_result
        ERROR_VARIABLE conf_error
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY
        COMMAND_ECHO STDOUT
    )
endif()

##
# make sure base tools is compiled
##
set(BASE_TOOLS_ARTIFACTS ${EDK_TOOLS_PATH}/Bin/Win32)
if(NOT EXISTS ${BASE_TOOLS_ARTIFACTS})
    foreach(var_name ${BUILD_ENV_VARIABLES})
        _set_variable_to_native_path(${var_name})
        set(ENV{${var_name}} "${${var_name}}")
        message(NOTICE "${var_name} = ${${var_name}}")
    endforeach()

    # set(ENV{PYTHON_COMMAND} ${PYTHON_COMMAND})
    message(NOTICE "building base tools...")
    string(CONCAT build_tools_cmd "cmd /C \"${VS_ENVIRONMENT_SCRIPT}\""
        " && ${EDK_TOOLS_PATH}\\toolsetup.bat ForceRebuild ${TOOL_CHAIN}"
    )
    separate_arguments(build_tools_cmd WINDOWS_COMMAND ${build_tools_cmd})
    execute_process(
        # COMMAND "${EDK_TOOLS_PATH}\\toolsetup.bat" ForceRebuild ${TOOL_CHAIN}
        COMMAND ${build_tools_cmd}
        RESULT_VARIABLE build_result
        COMMAND_ECHO STDOUT
    )
    # if the artifacts still does not exist, then the build must have failed
    if(NOT EXISTS ${BASE_TOOLS_ARTIFACTS})
        message(FATAL_ERROR "base tools build failed!")
    endif()
endif()

##
# check which bin dir to use
##
if(NOT DEFINED EDK_BIN_WRAPPERS)
    execute_process(
        COMMAND ${PYTHON_COMMAND} -c "import edk2basetools" 
        RESULT_VARIABLE python_result
        OUTPUT_QUIET
        ERROR_QUIET
    )
    if(${python_result} EQUAL 0)
        set(EDK_BIN_WRAPPERS ${EDK_TOOLS_PATH}/BinPipWrappers/WindowsLike CACHE INTERNAL "")
    else()
        set(EDK_BIN_WRAPPERS ${EDK_TOOLS_PATH}/BinWrappers/WindowsLike CACHE INTERNAL "")
    endif()
endif()

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
        _set_variable_to_native_path(var_value)
        string(APPEND EXPORTED_ENV "\n" "set ${var_name}=\"${var_value}\"")
    endforeach()
    
    string(JOIN "\n" script_content
        "${EXPORTED_ENV}"
        "set PATH=${EDK_BIN_WRAPPERS}:$PATH"
        "echo build $@"
        "build $@"
    )
    set(SCRIPT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_SCRIP})
    file(GENERATE OUTPUT ${SCRIPT_PATH}
        CONTENT ${script_content}
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
