#brief: defines all helper functions for creating a build target for a package 
include(cmake_files/generic/helper_functions.cmake)

function(internal_add_general_target PKG_NAME CURRENT_TARGET)
    if(NOT TARGET ${PKG_NAME})
        add_custom_target(${PKG_NAME} echo)
    endif()
    add_dependencies(${PKG_NAME} ${CURRENT_TARGET})
endfunction()

function(internal_add_package PKG_NAME ARCH BUILD_ARGS)
    set(CURRENT_TARGET ${PKG_NAME}_${ARCH})
    # list all files in our pkg
    file(GLOB_RECURSE PKG_SOURCE_FILES
        LIST_DIRECTORIES false
        ${PACKAGE_DIR}/${PKG_NAME}/**
    )
    # add flag for the architecture to compile to
    list(APPEND BUILD_ARGS --arch=${ARCH})

    set(SCRIPT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${BUILD_SCRIPT})
    set_variable_to_native_path(SCRIPT_PATH)
    if(NOT DEFINED ENV{BUILD_SCRIPT_GENERATED})
        set(ENV{BUILD_SCRIPT_GENERATED} TRUE)
        generate_build_script(script_content)
        file(GENERATE OUTPUT ${SCRIPT_PATH}
            CONTENT "${script_content}"
            FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
            NEWLINE_STYLE ${NEWLINE_STYLE}
        )
    endif()
    message("build cmd: ${SCRIPT_PATH} ${BUILD_ARGS}")
    # create the target
    add_custom_target(${CURRENT_TARGET} ALL
        ${SCRIPT_PATH} ${BUILD_ARGS} 
        SOURCES ${PKG_SOURCE_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} 
        USES_TERMINAL
    )
    internal_add_general_target(${PKG_NAME} ${CURRENT_TARGET})
endfunction()

##
# description: this function creates a Cmake target for a package.
# 
# arg1: PKG_NAME  the name of the package to create a target for
# arg2: ARCH  the architecture of the target
# arg3-n: BUILD_ARGS  list of argument to pass to edk's build system
#
# this is a warper function that deals with sending lists to a function
# as a bunch of variables instead of a list
##
function(add_package PKG_NAME ARCH BUILD_ARGS)
    if(NOT EXISTS ${PACKAGE_DIR}/${PKG_NAME})
        message(FATAL_ERROR "the packge ${PKG_NAME} does not exists in folder ${PACKAGE_DIR}")
    endif()
    set(BUILD_LIST "")
    list(APPEND BUILD_LIST ${BUILD_ARGS})
    list(APPEND BUILD_LIST ${ARGN})
    internal_add_package(${PKG_NAME} ${ARCH} "${BUILD_LIST}")
endfunction()
