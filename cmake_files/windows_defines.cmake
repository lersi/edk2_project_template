cmake_minimum_required(VERSION 3.20)
##
# Globals
##
set(BUILD_SCRIPT _build.bat) # the name og the build script script to create
set(BUILD_ENV_VARIABLES PACKAGES_PATH) # list containing all enviroment variables needed for configuration and build
string(JOIN ";" PACKAGES_PATH ${PACKAGES_PATH})
set(DEFAULT_NASM_PATH "C:\\nasm")
set(DEFAULT_CLANG_PATH "C:\\Program Files\\LLVM\\bin")
set(_PYTHON_3_COMMANDS 
        "py -3" 
        "python" 
        "python3"
        "python3.8"
        "python3.9"
        "python3.10"
)

##
# Helper functions
##
function(_set_variable_to_native_path var_name)
    cmake_path(CONVERT "${${var_name}}" TO_NATIVE_PATH_LIST result NORMALIZE)
    set(${var_name} ${result} PARENT_SCOPE)
endfunction()

##
# set esential data
##
set(EDK_TOOLS_PATH ${EDK2_SOURCE}/BaseTools)
_set_variable_to_native_path(EDK_TOOLS_PATH)
set(BASE_TOOLS_PATH ${EDK_TOOLS_PATH})
set(WORKSPACE_TOOLS_PATH ${EDK_TOOLS_PATH})
set(BASETOOLS_PYTHON_SOURCE ${BASE_TOOLS_PATH}\\Source\\Python)
set(WORKSPACE ${CMAKE_CURRENT_BINARY_DIR})
list(APPEND BUILD_ENV_VARIABLES WORKSPACE EDK_TOOLS_PATH BASE_TOOLS_PATH WORKSPACE_TOOLS_PATH)

##
# find python
##
if(NOT DEFINED PYTHON_COMMAND)
    # first try to find default python command names in path
    set(python_found FALSE)
    foreach(python_command_name ${_PYTHON_3_COMMANDS})
        if(NOT ${python_found})
            string(REPLACE " " ":" _command ${python_command_name})
            execute_process(
                COMMAND ${_command} --version
                RESULT_VARIABLE result
                OUTPUT_VARIABLE output
                ERROR_QUIET
            )
            if(result EQUAL 0)
                string(REPLACE " " ";" outputs ${output})
                list(GET outputs 1 version)
                if(${version} VERSION_GREATER_EQUAL "3.7")
                    message(NOTICE "found python command as: ${python_command_name}")
                    set(PYTHON_COMMAND ${python_command_name} CACHE FILEPATH "path to python interperter or name of python command" FORCE)
                    set(python_found TRUE)
                endif()
            endif()
        endif()
    endforeach()
    
    if(NOT ${python_found})
    # python command was not found, find it using cmake.
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
            cmake_path(CONVERT ${Python3_EXECUTABLE} TO_NATIVE_PATH_LIST python3_path NORMALIZE)
            message(NOTICE "found python command at: ${python3_path}")
            set(PYTHON_COMMAND "${python3_path}" CACHE STRING "path to python interperter or name of python command" FORCE)
        endif()
    endif()
endif()
message(NOTICE "PYTHON_COMMAND: ${PYTHON_COMMAND}")
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
    # sanity check
    if(NOT EXISTS ${NASM_PATH})
        message(ERROR "the path provided by `NASM_PATH` does not exist!")
    endif()
    # make sure that the path ends with a backslash
    cmake_path(CONVERT ${NASM_PATH} TO_NATIVE_PATH_LIST NASM_PATH NORMALIZE)
    string(REGEX MATCH ".$" last_char ${NASM_PATH})
    if(NOT last_char STREQUAL "\\")
        set(NASM_PATH ${NASM_PATH}\\)
    endif()
    set(NASM_PREFIX ${NASM_PATH} CACHE INTERNAL "path to nasm insall dir" FORCE)
elseif(NOT DEFINED NASM_PREFIX)
    # setting up for the first time
    set(default_nasm_exec "${DEFAULT_NASM_PATH}\\nasm.exe")
    # check for default location first
    if(EXISTS ${default_nasm_exec})
        set(NASM_PREFIX ${DEFAULT_NASM_PATH}\\ CACHE INTERNAL "path to nasm insall dir" FORCE)
    else()
    # try to find nasm from path
        execute_process(
            COMMAND cmd /C where nasm
            OUTPUT_VARIABLE output
            # ERROR_QUIET
            ECHO_OUTPUT_VARIABLE
            RESULT_VARIABLE run_result
            COMMAND_ECHO STDOUT
        )
        if(${run_result} EQUAL 0)
            # found nasm
            string(STRIP ${output} nasm_cmd_path)
            get_filename_component(nasm_path ${nasm_cmd_path} DIRECTORY)
            set(NASM_PREFIX ${nasm_path}\\ CACHE INTERNAL "path to nasm insall dir" FORCE)
        else()
            message(WARNING "cound not find nasm, components that uses nasm will fail to compile\nyou can specify nasm's directory by setting `NASM_PATH`")
        endif()
    endif()
endif()
if(DEFINED NASM_PREFIX)
    list(APPEND BUILD_ENV_VARIABLES NASM_PREFIX)
endif()

##
# find clang
##
if(DEFINED CLANG_BIN_PATH)
    # sanity check
    if(NOT EXISTS ${CLANG_BIN_PATH})
        message(ERROR "the path provided by `CLANG_BIN_PATH` does not exist!")
    endif()
    cmake_path(CONVERT ${CLANG_BIN_PATH} TO_NATIVE_PATH_LIST CLANG_BIN_PATH NORMALIZE)
    set(CLANG_BIN ${CLANG_BIN_PATH} CACHE INTERNAL "path to clang's bin dir" FORCE)
elseif(NOT DEFINED CLANG_BIN)
    set(default_clang_exec ${DEFAULT_CLANG_PATH}\\clang.exe)
    # check default path first
    if(EXISTS ${default_clang_exec})
        set(CLANG_BIN ${DEFAULT_CLANG_PATH} CACHE INTERNAL "path to clang's bin dir" FORCE)
    else()
        # try to get clang from path
        execute_process( # use vs enviroment script, to look also for visual studio's clang
            COMMAND cmd /C "${VS_ENVIRONMENT_SCRIPT}" && where clang
            OUTPUT_VARIABLE output
            RESULT_VARIABLE result
            ERROR_QUIET
        )
        if(${result} EQUAL 0)
            string(REGEX MATCH "C:\\\\[A-Z,a-z, ,\\\\,\\(,\\),_,0-9,\\.]*\\.exe" clang_cmd_path ${output})
            string(STRIP ${clang_cmd_path} clang_cmd_path)
            get_filename_component(clang_path ${clang_cmd_path} DIRECTORY)
            set(CLANG_BIN ${clang_path} CACHE INTERNAL "path to clang's bin dir" FORCE)
        else()
            message(WARNING "could not find clang, components that uses clang will fail to compile\nyou can specify clang's binary directory by setting `CLANG_BIN_PATH`")
        endif()
    endif()
endif()
if(DEFINED CLANG_BIN)
    list(APPEND BUILD_ENV_VARIABLES CLANG_BIN)
endif()

##
# make sure that edk2 build system is configured
##
set(CONF_PATH ${CMAKE_BINARY_DIR}\\conf CACHE PATH "where to save configuration for EDK build tools")
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
set(BASE_TOOLS_ARTIFACTS ${EDK_TOOLS_PATH}\\Bin\\Win32)
if(NOT EXISTS ${BASE_TOOLS_ARTIFACTS})
    foreach(var_name ${BUILD_ENV_VARIABLES})
        _set_variable_to_native_path(${var_name})
        set(ENV{${var_name}} "${${var_name}}")
        message(NOTICE "${var_name} = ${${var_name}}")
    endforeach()

    # set(ENV{PYTHON_COMMAND} ${PYTHON_COMMAND})
    message(NOTICE "building base tools...")
    set(ENV{PATH} "${BASE_TOOLS_ARTIFACTS};$ENV{PATH}")
    string(CONCAT build_tools_cmd "cmd /C \"${VS_ENVIRONMENT_SCRIPT}\""
        " && ${EDK_TOOLS_PATH}\\toolsetup.bat ForceRebuild ${TOOL_CHAIN}"
        " && ${EDK_TOOLS_PATH}\\toolsetup.bat Rebuild ${TOOL_CHAIN}"
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
set(EDK_TOOLS_BIN ${BASE_TOOLS_ARTIFACTS})
_set_variable_to_native_path(EDK_TOOLS_BIN)
list(APPEND BUILD_ENV_VARIABLES EDK_TOOLS_BIN)

##
# check which bin dir to use
##
if(NOT DEFINED EDK_BIN_WRAPPERS)
    _set_variable_to_native_path(EDK_TOOLS_PATH)
    execute_process(
        COMMAND ${PYTHON_COMMAND} -c "import edk2basetools" 
        RESULT_VARIABLE python_result
        OUTPUT_QUIET
        ERROR_QUIET
    )
    if(${python_result} EQUAL 0)
        set(EDK_BIN_WRAPPERS "${EDK_TOOLS_PATH}\\BinPipWrappers\\WindowsLike" CACHE INTERNAL "")
    else()
        set(EDK_BIN_WRAPPERS "${EDK_TOOLS_PATH}\\BinWrappers\\WindowsLike" CACHE INTERNAL "")
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
        "echo path: %PATH%"
        "echo ===================="
        "ls ${EDK_TOOLS_BIN}"
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
