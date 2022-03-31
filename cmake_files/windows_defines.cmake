cmake_minimum_required(VERSION 3.12)
set(VS_VERSION VS2019 CACHE STRING "the version of visual studio to us i.e VS2019")


set(TOOL_CHAIN ${VS_VERSION})
set(BUILD_SCRIPT _build.bat)


function(_add_package PKG_NAME BUILD_ARGS)
    # list all files in our pkg
    file(GLOB_RECURSE PKG_SOURCE_FILES
        LIST_DIRECTORIES false
        ${PACKAGE_DIR}/${PKG_NAME}/**
    )

    # fix path in all arguments so it matches windows style
    string(JOIN " " BUILD_SCRIPT_ARGS ${CMAKE_CURRENT_BINARY_DIR} ${EDK2_SOURCE} ${VS_VERSION}  ${PACKAGE_DIR} ${BUILD_ARGS})
    string(REPLACE "/" "\\" BUILD_SCRIPT_ARGS ${BUILD_SCRIPT_ARGS})

    # seperate the string back to its arguments
    separate_arguments(BUILD_SCRIPT_ARGS WINDOWS_COMMAND ${BUILD_SCRIPT_ARGS})  
    message("script args: ${BUILD_SCRIPT_ARGS}")

    add_custom_target(${PKG_NAME}
        ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_SCRIPT} ${BUILD_SCRIPT_ARGS} 
        SOURCES ${PKG_SOURCE_FILES}
        BYPRODUCTS ${OUT_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} 
        USES_TERMINAL
    )
endfunction()

function(add_package PKG_NAME BUILD_ARGS)
    set(BUILD_LIST "")
    list(APPEND BUILD_LIST ${BUILD_ARGS})
    list(APPEND BUILD_LIST ${ARGN})
    _add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()
