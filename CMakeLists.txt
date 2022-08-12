cmake_minimum_required(VERSION 3.12)

project(edk2_template LANGUAGES C ASM)

# set(LOCAL_EDK2 <full path to your local edk2 repo>) # this variable could also be be transfered to cmake in the command line
# imports edk2 project
include(cmake_files/include_edk2.cmake)

# translates a name from `include_edk2.cmake` to somthing more readable
set(EDK2_SOURCE ${EDK2_SOURCE_DIR})
# specifiece the dir that contains sources for EDK2
set(PACKAGE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/uefi_apps)

# platform specific modules
if(WIN32)
    # windows platform (also 64 bit)
    include(cmake_files/windows_defines.cmake)
else()
    message(FATAL_ERROR "current platform is not supported")
endif()



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
    _add_package(${PKG_NAME} "${BUILD_LIST}")
endfunction()


# list all packages that we want to compile
include(uefi_apps/lior_pkg.cmake)

