#brief: defines all helper functions for creating a build target for a package 


function(internal_add_package PKG_NAME BUILD_ARGS)
    # list all files in our pkg
    file(GLOB_RECURSE PKG_SOURCE_FILES
        LIST_DIRECTORIES false
        ${PACKAGE_DIR}/${PKG_NAME}/**
    )

    # generate build script
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
    set(SCRIPT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_SCRIP})
    file(GENERATE OUTPUT ${SCRIPT_PATH}
        CONTENT ${script_content}
        FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        NEWLINE_STYLE UNIX
    )

    # create the target
    add_custom_target(${PKG_NAME}
        ${SCRIPT_PATH} ${BUILD_ARGS} 
        SOURCES ${PKG_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} 
        USES_TERMINAL
    )
endfunction()

##
# description: this function creates a Cmake target for a package.
# 
# arg1: PKG_NAME  the name of the package to create a target for
# arg2-n: BUILD_ARGS  list of argument to pass to edk's build system
#
# this is a warper function that deals with sending lists to a function
# as a bunch of variables instead of a list
##
function(add_package PKG_NAME BUILD_ARGS)
    if(NOT EXISTS ${PACKAGE_DIR}/${PKG_NAME})
        message(FATAL_ERROR "the packge ${PKG_NAME} does not exists in folder ${PACKAGE_DIR}")
    endif()
    set(BUILD_LIST "")
    list(APPEND BUILD_LIST ${BUILD_ARGS})
    list(APPEND BUILD_LIST ${ARGN})
    internal_add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()
