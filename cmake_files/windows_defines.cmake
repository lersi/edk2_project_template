if(NOT DEFINED VS_VERSION)
    set(VS_VERSION VS2019)
endif()

set(TOOL_CHAIN ${VS_VERSION})
set(BUILD_SCRIPT build.bat)


function(_add_package PKG_NAME BUILD_ARGS)
    # list all files in our pkg
    file(GLOB_RECURSE PKG_SOURCE_FILES
        LIST_DIRECTORIES false
        RELATIVE ${PACKAGE_DIR}
        ${PACKAGE_DIR}/${PKG_NAME}/**
    )

    # # create list of destination files
    list(TRANSFORM PKG_SOURCE_FILES PREPEND ${EDK2_SOURCE}/ OUTPUT_VARIABLE OUT_FILES)
    # # create list of all source files
    list(TRANSFORM PKG_SOURCE_FILES PREPEND ${PACKAGE_DIR}/)

    add_custom_target(${PKG_NAME}
        ${CMAKE_COMMAND} -E copy_directory ${PACKAGE_DIR}/${PKG_NAME} ${PKG_NAME}
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_SCRIPT} ${VS_VERSION} ${BUILD_ARGS}
        SOURCES ${PKG_SOURCE_FILES}
        BYPRODUCTS ${OUT_FILES}
        WORKING_DIRECTORY ${EDK2_SOURCE}
    )
endfunction()

function(add_package PKG_NAME BUILD_ARGS)
    set(BUILD_LIST "")
    list(APPEND BUILD_LIST ${BUILD_ARGS})
    list(APPEND BUILD_LIST ${ARGN})
    _add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()
