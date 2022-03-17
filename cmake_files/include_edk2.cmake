cmake_minimum_required(VERSION 3.17)
include(FetchContent)

# checks if we got a repo from user, if not get the repo from github
if(NOT DEFINED LOCAL_EDK2)
    set(EDK_REPO https://github.com/tianocore/edk2.git)
else()
    set(EDK_REPO ${LOCAL_EDK2}) # note that this could be also a remote repo
endif()

# lets the user configure it's own edk2 tag to work with
if(NOT DEFINED EDK2_TAG)
    set(EDK2_TAG edk2-stable202111) # default tag 
endif()

# fetches the repo
FetchContent_Declare(
    EDK2
    GIT_REPOSITORY ${EDK_REPO}
    GIT_TAG        ${EDK2_TAG}
    GIT_SUBMODULES_RECURSE  FALSE
    GIT_PROGRESS            TRUE
)
FetchContent_Populate(EDK2)

