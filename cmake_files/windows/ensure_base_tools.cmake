#brief: makes sure that edk2's build system is configured
# in variables:
#    SHELL_CMD - the name\fullpath of the shell commad to execute 
#    SHELL_EXECUTE_ARG - the argument that allows to execute one command in the shell
#    EDK_TOOLS_PATH - path to edk base tools repo
#    PYTHON_COMMAND - path/name of the python command to use
#    VS_ENVIRONMENT_SCRIPT - full path to a script file that add visual studio compiler to path
# out variables: 
#     BASE_TOOLS_ARTIFACTS - the path to base tools compiled binaries
#     BASETOOLS_FAILED - CACHED INTERNAL  for indicating that even if the artifact exists it needs recompile
#     EDK_TOOLS_BIN - path to base tools binaries

set(_must_be_defined
    SHELL_CMD
    SHELL_EXECUTE_ARG
    EDK_TOOLS_PATH
    PYTHON_COMMAND
    VS_ENVIRONMENT_SCRIPT
)

include(cmake_files/generic/helper_functions.cmake)
check_required_variables_defined("${_must_be_defined}") #note the argument must be inside quotation marks so the list will be delivered as a single variable 
unset(_must_be_defined) # make sure does not leaks to other files

set(BASE_TOOLS_ARTIFACTS ${EDK_TOOLS_PATH}\\Bin\\Win32)
if(NOT EXISTS ${BASE_TOOLS_ARTIFACTS})
    #set esential variables needed by the build script
    foreach(var_name ${BUILD_ENV_VARIABLES})
        set_variable_to_native_path(${var_name})
        set(ENV{${var_name}} "${${var_name}}")
        message(NOTICE "${var_name} = ${${var_name}}")
    endforeach()

    message(NOTICE "building base tools...")
    set(ENV{PATH} "${BASE_TOOLS_ARTIFACTS};$ENV{PATH}") # some build steps relay on the artifacts of the previous steps, so add base tools bin dir to path
    string(CONCAT build_tools_cmd "${SHELL_CMD} ${SHELL_EXECUTE_ARG} \"${VS_ENVIRONMENT_SCRIPT}\""
        " && ${EDK_TOOLS_PATH}\\toolsetup.bat ForceRebuild ${TOOL_CHAIN}"
    )
    separate_arguments(build_tools_cmd WINDOWS_COMMAND ${build_tools_cmd})
    execute_process(
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
set_variable_to_native_path(EDK_TOOLS_BIN)
