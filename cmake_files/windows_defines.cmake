if(NOT DEFINED VS_VERSION)
    set(VS_VERSION VS2019)
endif()

set(TOOL_CHAIN ${VS_VERSION})
set(BUILD_SCRIPT _build.bat)


function(_add_package PKG_NAME BUILD_ARGS)
    # list all files in our pkg
    file(GLOB_RECURSE PKG_SOURCE_FILES
        LIST_DIRECTORIES false
        ${PACKAGE_DIR}/${PKG_NAME}/**
    )

    add_custom_target(${PKG_NAME}
        ${CMAKE_CURRENT_SOURCE_DIR}/${BUILD_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR} ${EDK2_SOURCE} ${VS_VERSION}  ${PACKAGE_DIR} ${BUILD_ARGS} 
        SOURCES ${PKG_SOURCE_FILES}
        BYPRODUCTS ${OUT_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} 
    )
endfunction()

function(add_package PKG_NAME BUILD_ARGS)
    set(BUILD_LIST "")
    list(APPEND BUILD_LIST ${BUILD_ARGS})
    list(APPEND BUILD_LIST ${ARGN})
    _add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()
