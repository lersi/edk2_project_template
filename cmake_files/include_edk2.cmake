cmake_minimum_required(VERSION 3.17)
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
    GIT_REPOSITORY ${EDK_REPO}
    GIT_TAG        ${EDK2_TAG}
    GIT_SUBMODULES_RECURSE  FALSE
    GIT_PROGRESS            TRUE
)

FetchContent_Populate(edk2)

set(EDK2_SOURCE_DIR ${edk2_SOURCE_DIR})
