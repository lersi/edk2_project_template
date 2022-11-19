#brief: selects edk bin wrappers based on system installation
# in variables:
#    EDK_TOOLS_PATH - path to edk base tools repo
#    PYTHON_COMMAND - path/name of the python command to use
# out variables: 
#     EDK_BIN_WRAPPERS - CACHED INTERNAL path to edk bin wrappers folder

set(_must_be_defined
    EDK_TOOLS_PATH
    PYTHON_COMMAND
)

include(cmake_files/generic/helper_functions.cmake)
check_required_variables_defined("${_must_be_defined}") #note the argument must be inside quotation marks so the list will be delivered as a single variable 
unset(_must_be_defined) # make sure does not leaks to other files

if(NOT DEFINED EDK_BIN_WRAPPERS)
    set_variable_to_native_path(EDK_TOOLS_PATH)
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
