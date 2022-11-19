set(NEWLINE_STYLE "WIN32")

function(generate_build_script CONTENT_VAR)
    # export the configuration variables
    set(EXPORTED_ENV "")
    foreach(var_name ${BUILD_ENV_VARIABLES})
        set(var_value "${${var_name}}")
        set_variable_to_native_path(var_value)
        string(FIND "${var_value}" " " has_space)
        if(${has_space} GREATER_EQUAL 0)
            string(APPEND EXPORTED_ENV "\n" "set ${var_name}=\"${var_value}\"")
        else()
            string(APPEND EXPORTED_ENV "\n" "set ${var_name}=${var_value}")
        endif()
    endforeach()

    string(JOIN "\n" script_content
        "@echo off"
        # something for python cache
        "set PYTHONHASHSEED=1"
        # for using clang
        "@set CLANG_HOST_BIN=n"
        # to set visual studio configuration
        "call \"${VS_ENVIRONMENT_SCRIPT}\""
        # to set things based on visual studio configuration
        "call \"${BASE_TOOLS_PATH}\\set_vsprefix_envs.bat\""
        "${EXPORTED_ENV}"
        # add base tools to path
        "set PATH=${EDK_TOOLS_BIN};${EDK_BIN_WRAPPERS};\%PATH\%"
        # add python base tools to python path
        "set PYTHONPATH=${BASETOOLS_PYTHON_SOURCE};%PYTHONPATH%"
        "echo build \%*"
        "build \%*"
    )

    set(${CONTENT_VAR} "${script_content}" PARENT_SCOPE)
endfunction()
