####
# description: detects clang location.
# author: Lior Shalmay
# in variables:
#    SHELL_CMD - the name\fullpath of the shell commad to execute 
#    SHELL_EXECUTE_ARG - the argument that allows to execute one command in the shell
#    CLANG_BIN_PATH - OPTIONAL user provided path to clang binary dir
#    DEFAULT_CLANG_PATH - a default path to where clang should probably be.
#
# out variables:
#     CLANG_BIN - CACHED OPTIONAL path to clang binary dir
####
set(_must_be_defined
    SHELL_CMD
    SHELL_EXECUTE_ARG
    DEFAULT_CLANG_PATH
)

include(cmake_files/generic/helper_functions.cmake)
check_required_variables_defined("${_must_be_defined}") #note the argument must be inside quotation marks so the list will be delivered as a single variable 
unset(_must_be_defined) # make sure does not leaks to other files

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
