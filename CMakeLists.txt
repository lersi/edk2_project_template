cmake_minimum_required(VERSION 3.12)

project(edk2_template)

# set(LOCAL_EDK2 <full path to your local edk2 repo>)
include(cmake_files/include_edk2.cmake)

set(EDK2_SOURCE ${EDK2_SOURCE_DIR})
set(PACKAGE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/uefi_apps)

# platform specific modules
if(WIN32)
    include(cmake_files/windows_defines.cmake)
else()
    message(FATAL_ERROR "current platform is not supported")
endif()

# list all packages that we want to compile
include(uefi_apps/lior_pkg.cmake)

