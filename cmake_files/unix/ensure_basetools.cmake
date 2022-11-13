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

set(BASE_TOOLS_ARTIFACTS ${EDK_TOOLS_PATH}/Source/C/bin)
if(NOT EXISTS ${BASE_TOOLS_ARTIFACTS} OR BASETOOLS_FAILED)
# build base tools if are not present
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
        set(BASETOOLS_FAILED TRUE CACHE INTERNAL "basetools compilation failed last run")
        message(FATAL_ERROR "base tools build failed!")
    elseif()
        unset(BASETOOLS_FAILED CACHE)
    endif()
endif()
