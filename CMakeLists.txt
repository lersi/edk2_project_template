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

# list all packages that we want to compile
include(uefi_apps/lior_pkg.cmake)

