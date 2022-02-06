cmake_minimum_required(VERSION 3.11)
include(FetchContent)
if(NOT DEFINED LOCAL_EDK2)
    set(EDK_REPO https://github.com/tianocore/edk2.git)
else()
    set(EDK_REPO ${LOCAL_EDK2})
endif()
if(NOT DEFINED EDK2_TAG)
    set(EDK2_TAG edk2-stable202111)
endif()

FetchContent_Declare(
    edk2
    GIT_REPOSITORY ${LOCAL_EDK2}
    GIT_TAG        ${EDK2_TAG}
)

FetchContent_Populate(edk2)

set(EDK2_SOURCE_DIR ${edk2_SOURCE_DIR})
