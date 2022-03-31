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
        COMMAND uname -r
        OUTPUT_VARIABLE DARWIN_VERSION
    )
    message(NOTICE "darwin version: ${DARWIN_VERSION}")
    # different darwin versions need different toolchains
    # note that "Darwin version" ≠ "OS X version" (i.e OS X Yosemite 10.10.2 has Darwin version 14)
    if (${DARWIN_VERSION} VERSION_LESS 10)
        # these old mac os versions are not supported by edk's build system
        message(FATAL_ERROR "this macos version is not supported please upgrade to a newer version")
    elseif(${DARWIN_VERSION} VERSION_LESS 11) # only major 10
        set(TOOL_CHAIN "XCODE32" CACHE INTERNAL "")
    elseif(${DARWIN_VERSION} VERSION_LESS 13) # only majors 11 and 12
        set(TOOL_CHAIN "XCLANG" CACHE INTERNAL "")
    else() # major 13 and forward
        set(TOOL_CHAIN "XCODE5" CACHE INTERNAL "")
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
if(NOT DEFINED PYTHON_COMMAND)
    execute_process(
        COMMAND zsh -c "which python3"
        OUTPUT_VARIABLE PYTHON_COMMAND
    )
    string(STRIP "${PYTHON_COMMAND}" PYTHON_COMMAND)
    if("${PYTHON_COMMAND}" STREQUAL "")
        string(CONCAT error_msg
            "could not find the location of the python command, "
            "please use `-DPYTHON_COMMAND=<path to your python interperter>`\n"
            "to declare the python interperter for use"
        )
        message(SEND_ERROR ${error_msg})
    else()
        message(NOTICE "found python command at: ${PYTHON_COMMAND}")
        set(PYTHON_COMMAND ${PYTHON_COMMAND} CACHE FILEPATH "path to python interperter" FORCE)
    endif()
else()
    set(PYTHON_COMMAND ${PYTHON_COMMAND} CACHE FILEPATH "path to python interperter") 
endif()
list(APPEND BUILD_ENV_VARIABLES WORKSPACE PYTHON_COMMAND EDK_TOOLS_PATH)

##
# make sure that edk2 build system is configured
##
set(CONF_PATH ${CMAKE_BINARY_DIR}/conf CACHE PATH "where to save configuration for EDK build tools")
list(APPEND BUILD_ENV_VARIABLES CONF_PATH)
if((NOT EXISTS ${CONF_PATH}) OR (NOT EXISTS ${CONF_PATH}/tools_def.txt))
    make_directory(${CONF_PATH})
    set(ENV{RECONFIG} "TRUE")
    foreach(var_name ${BUILD_ENV_VARIABLES})
        set(ENV{${var_name}} "${${var_name}}")
    endforeach()
    message(NOTICE ${env_string})
    execute_process(
        COMMAND /bin/zsh -c "source ${EDK_TOOLS_PATH}/BuildEnv"
        OUTPUT_VARIABLE conf_result
        ERROR_VARIABLE conf_error
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()
##
# make sure base tools is compiled
##
set(BASE_TOOLS_ARTIFACTS ${EDK_TOOLS_PATH}/Source/C/bin)
if(NOT EXISTS ${BASE_TOOLS_ARTIFACTS})
    set(ENV{PYTHON_COMMAND} ${PYTHON_COMMAND})
    message(NOTICE "building base tools...")
    execute_process(
        COMMAND make -C ${EDK_TOOLS_PATH}
        OUTPUT_QUIET
        RESULT_VARIABLE build_result
    )
    if(NOT ${build_result} EQUAL 0)
        execute_process(
            COMMAND make -C ${EDK_TOOLS_PATH} clean
            OUTPUT_QUIET
            ERROR_QUIET
        )
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
        set(EDK_BIN_WRAPPERS ${EDK_TOOLS_PATH}/BinPipWrappers/PosixLike CACHE INTERNAL "")
    else()
        set(EDK_BIN_WRAPPERS ${EDK_TOOLS_PATH}/BinWrappers/PosixLike CACHE INTERNAL "")
    endif()
endif()

function(_add_package PKG_NAME BUILD_ARGS)
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
        "#!/bin/zsh"
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
    _add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()
