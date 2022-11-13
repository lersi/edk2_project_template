# brief detects python executable of version 3.7 and above
# input variables: None
# out variables: 
#     PYTHON_COMMAND - CACHED  full path to python interperter or name of python command in path

# the minimum compatiable python version 
set(_MINIMUM_PYTHON_VERSION "3.7")
# list of predeterment names of the python command to look for
set(_PYTHON_3_COMMANDS 
        "py -3" 
        "python" 
        "python3"
        "python3.8"
        "python3.9"
        "python3.10"
)


if(NOT DEFINED PYTHON_COMMAND)
    # first try to find default python command names in path
    set(python_found FALSE)
    foreach(python_command_name ${_PYTHON_3_COMMANDS})
        # for each command name check if it exists and suitable
        string(REPLACE " " ":" _command "${python_command_name}")
        execute_process(
            COMMAND ${_command} --version
            RESULT_VARIABLE result
            OUTPUT_VARIABLE output
        )
        if(result EQUAL 0 AND NOT "${output}" STREQUAL "")
        # the python command has executed successfuly (it exits)
            string(REPLACE " " ";" outputs "${output}") 
            list(GET outputs 1 version)
            # check if the python version matches our requirments
            if(${version} VERSION_GREATER_EQUAL ${_MINIMUM_PYTHON_VERSION})
                message(NOTICE "found python command as: ${python_command_name}")
                # save the command name into cache
                set(PYTHON_COMMAND ${python_command_name} CACHE STRING "path to python interperter or name of python command" FORCE)
                set(python_found TRUE)
                break() # we found what we need
            endif()
        endif()
    endforeach()
    
    if(NOT ${python_found})
    # python command was not found, find it using cmake.
        # searching for python command location
        find_package (Python3 ${_MINIMUM_PYTHON_VERSION} QUIET COMPONENTS Interpreter)
        if(NOT ${Python3_Interpreter_FOUND})
        # python location was not found
            string(CONCAT error_msg
                "could not find the location of the python command (or your python is older than 3.7), \n"
                "please use `-DPYTHON_COMMAND=<path to your python interperter>`\n"
                "to declare the python interperter for use"
            )
            message(SEND_ERROR ${error_msg})
        else()
        # show python loocation to user, and save to cache
            cmake_path(CONVERT ${Python3_EXECUTABLE} TO_NATIVE_PATH_LIST python3_path NORMALIZE)
            message(NOTICE "found python command at: ${python3_path}")
            set(PYTHON_COMMAND "${python3_path}" CACHE STRING "path to python interperter or name of python command" FORCE)
        endif()
    endif()
endif()
message(NOTICE "PYTHON_COMMAND: ${PYTHON_COMMAND}")
