cmake_minimum_required(VERSION 3.12)

project(edk2_template LANGUAGES C ASM)

# include general files
include(cmake_files/generic/helper_functions.cmake)

# set(LOCAL_EDK2 <full path to your local edk2 repo>) # this variable could also be be transfered to cmake in the command line
# imports edk2 project
include(cmake_files/generic/include_edk2.cmake)
# get the cpu core count
include(cmake_files/generic/core_count.cmake)

# specifiece the dir that contains sources for EDK2
set(PACKAGE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/uefi_apps)
set(PACKAGES_PATH ${PACKAGE_DIR} ${EDK2_SOURCE})
set(CMAKE_SCRIPTS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake)

# platform specific modules
if(WIN32)
    # windows platform (also 64 bit)
    include(cmake_files/windows/windows_defines.cmake)
elseif(APPLE)
    # mac platform 
    include(cmake_files/mac/mac_defines.cmake)
elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    # linux platform
    include(cmake_files/linux/linux_defines.cmake)
else()
    message("${CMAKE_SYSTEM_NAME}")
    message(FATAL_ERROR "current platform is not supported")
endif()



# include functions for creating targets
include(cmake_files/generic/package_build_api.cmake)


# list all packages that we want to compile
include(uefi_apps/lior_pkg.cmake)

