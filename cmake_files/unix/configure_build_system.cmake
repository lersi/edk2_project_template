#brief: makes sure that edk2's build system is configured
# in variables:
#    SHELL_CMD - the name\fullpath of the shell commad to execute 
#    SHELL_EXECUTE_ARG - the argument that allows to execute one command in the shell
#    CONF_PATH - a path to save edk's build configuration
#    BUILD_ENV_VARIABLES - variables that are configuring the EDK2 build system
#    EDK_TOOLS_PATH - path to basetools repo dir
# out variables: None

set(_must_be_defined
    SHELL_CMD
    SHELL_EXECUTE_ARG
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
        set(ENV{${var_name}} "${${var_name}}")
    endforeach()
    execute_process(
        COMMAND ${SHELL_CMD} ${SHELL_EXECUTE_ARG} "source ${EDK_TOOLS_PATH}/BuildEnv"
        OUTPUT_VARIABLE conf_result
        ERROR_VARIABLE conf_error
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()


