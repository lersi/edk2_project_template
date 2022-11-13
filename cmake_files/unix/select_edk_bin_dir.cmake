#brief: makes sure that edk2's build system is configured
# in variables:
#    EDK_TOOLS_PATH - path to edk base tools repo
#    PYTHON_COMMAND - path/name of the python command to use
# out variables: 
#     BASE_TOOLS_ARTIFACTS - the path to base tools compiled binaries
#     BASETOOLS_FAILED - CACHED INTERNAL  for indicating that even if the artifact exists it needs recompile

set(_must_be_defined
    EDK_TOOLS_PATH
    PYTHON_COMMAND
)

include(cmake_files/generic/helper_functions.cmake)
check_required_variables_defined("${_must_be_defined}") #note the argument must be inside quotation marks so the list will be delivered as a single variable 
unset(_must_be_defined) # make sure does not leaks to other files

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
