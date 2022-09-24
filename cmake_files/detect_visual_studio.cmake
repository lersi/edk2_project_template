####
# description: detects visual studio location, version and devenvironment.
# author: Lior Shalmay
####

cmake_minimum_required(VERSION 3.20)
set(_VS_INSTALLER_RELATIVE_PATH "Microsoft Visual Studio\\Installer\\vswhere.exe")
set(VS_INSTALLER_DEFAULT_PATHS 
    "$ENV{ProgramFiles\(x86\)}\\${_VS_INSTALLER_RELATIVE_PATH}"
    "$ENV{ProgramFiles}\\${_VS_INSTALLER_RELATIVE_PATH}"
)
# enables users to add there own paths
set(CUSTOM_VS_INSTALLER_PATHS "" CACHE STRING "list of paths to search for visual studio installer, seperated by colon")

set(VS_INSTALLER_PATHS )

function(_parse_vswhere_output VSWHERE_OUTPUT OUT_VARIABLE_VS_INSTALL_PATH)
    # get the entry that we want fron the output
    string(REGEX MATCH "installationPath:[^\n]*" vs_path_entry ${VSWHERE_OUTPUT})

    if(${vs_path_entry} STREQUAL "")
        # if the result is empty, the regex match has failed
        # set the result to NOTFOUND
        set(result NOTFOUND)
    else()
        # extract the path from that entry
        string(REPLACE ": " ";" temp_list ${vs_path_entry})
        list(GET temp_list "-1" result)
    endif()

    # return the result to upper scope
    set(${OUT_VARIABLE_VS_INSTALL_PATH} ${result} PARENT_SCOPE)
endfunction()


function(detect_vs_location_vswhere OUT_VARIABLE_VS_INSTALL_PATH)
    set(found_installer FALSE)
    foreach(installer_path ${VS_INSTALLER_DEFAULT_PATHS})
        if(NOT ${found_installer})
            if(EXISTS ${installer_path})
                message(NOTICE "found installer at: ${installer_path}")
                execute_process(COMMAND "${installer_path}"
                    COMMAND_ERROR_IS_FATAL ANY
                    OUTPUT_VARIABLE installer_output
                )
                _parse_vswhere_output(${installer_output} vs_install_path)
                if (NOT ${vs_install_path} STREQUAL "NOTFOUND")
                    set(found_installer TRUE)
                    set(${OUT_VARIABLE_VS_INSTALL_PATH} ${vs_install_path} PARENT_SCOPE)
                endif()
            endif()
        endif()
    endforeach()
endfunction()

