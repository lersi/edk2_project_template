#brief: makes sure that edk2's build system is configured
# in variables:
#    CONF_PATH - a path to save edk's build configuration
#    BUILD_ENV_VARIABLES - variables that are configuring the EDK2 build system
#    EDK_TOOLS_PATH - path to basetools repo dir
# out variables: None

set(_must_be_defined
    CONF_PATH
    BUILD_ENV_VARIABLES
    EDK_TOOLS_PATH
)

include(cmake_files/generic/helper_functions.cmake)
check_required_variables_defined("${_must_be_defined}") #note the argument must be inside quotation marks so the list will be delivered as a single variable 
unset(_must_be_defined) # make sure does not leaks to other files

if((NOT EXISTS ${CONF_PATH}) OR (NOT EXISTS ${CONF_PATH}/tools_def.txt))
    make_directory(${CONF_PATH})
    set(ENV{RECONFIG} "TRUE")
    foreach(var_name ${BUILD_ENV_VARIABLES})
        set_variable_to_native_path(${var_name})
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
