SET(NEWLINE_STYLE "UNIX")

function(generate_build_script CONTENT_VAR)
    # export the configuration variables
   set(EXPORTED_ENV "")
   foreach(var_name ${BUILD_ENV_VARIABLES})
       set(var_value "${${var_name}}")
       string(APPEND EXPORTED_ENV "\n" "export ${var_name}=\"${var_value}\"")
   endforeach()
   
   string(JOIN "\n" script_content
       "#!${SHELL_CMD}"
       "${EXPORTED_ENV}"
       "export PATH=${EDK_BIN_WRAPPERS}:$PATH"
       "echo build $@"
       "build $@"
   ) 

   set(${CONTENT_VAR} "${script_content}" PARENT_SCOPE)
endfunction()
