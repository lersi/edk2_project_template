####
# description: detects nasm location.
# author: Lior Shalmay
# in variables:
#    SHELL_CMD - the name\fullpath of the shell commad to execute 
#    SHELL_EXECUTE_ARG - the argument that allows to execute one command in the shell
#    NASM_PATH - OPTIONAL user provided path to nasm install dir
#    DEFAULT_NASM_PATH - a default path to where nasm should probably be.
#
# out variables:
#     NASM_PREFIX - CACHED OPTIONAL path to nasm install dir
####
set(_must_be_defined
    SHELL_CMD
    SHELL_EXECUTE_ARG
    DEFAULT_NASM_PATH
)

include(cmake_files/generic/helper_functions.cmake)
check_required_variables_defined("${_must_be_defined}") #note the argument must be inside quotation marks so the list will be delivered as a single variable 
unset(_must_be_defined) # make sure does not leaks to other files

if(DEFINED NASM_PATH)
    # sanity check
    if(NOT EXISTS ${NASM_PATH})
        message(SEND_ERROR "the path provided by `NASM_PATH` does not exist!")
    endif()
    # make sure that the path ends with a backslash
    set_variable_to_native_path(NASM_PATH)
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
            COMMAND ${SHELL_CMD} ${SHELL_EXECUTE_ARG} where nasm
            OUTPUT_VARIABLE output
            ERROR_QUIET
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
