#brief: some helper functions
if(NOT DEFINED __CMAKE__HELPER_FINCTIONS) # prevent multiple inclusions
set(__CMAKE__HELPER_FINCTIONS TRUE)

function(check_required_variables_defined variables)
    cmake_path(GET CMAKE_CURRENT_LIST_FILE FILENAME file_name)
    foreach(var_name ${variables})
        if(NOT DEFINED ${var_name})
            message(ERROR "${var_name} must be defined in order to use ${file_name}")
        endif() 
    endforeach()
endfunction()


endif() # no code after this line
