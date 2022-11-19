#brief: some helper functions
if(NOT DEFINED __CMAKE__HELPER_FINCTIONS) # prevent multiple inclusions
set(__CMAKE__HELPER_FINCTIONS TRUE)

function(check_required_variables_defined variables)
    cmake_path(GET CMAKE_CURRENT_LIST_FILE FILENAME file_name)
    foreach(var_name ${variables})
        if(NOT DEFINED ${var_name})
            message(SEND_ERROR "${var_name} must be defined in order to use ${file_name}")
        endif() 
    endforeach()
endfunction()

function(set_variable_to_native_path var_name)
    cmake_path(CONVERT "${${var_name}}" TO_NATIVE_PATH_LIST result NORMALIZE)
    set(${var_name} ${result} PARENT_SCOPE)
endfunction()


endif() # no code after this line
