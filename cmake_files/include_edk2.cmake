cmake_minimum_required(VERSION 3.17)
include(FetchContent)

# checks if we got a repo from user, if not get the repo from github
if(NOT DEFINED LOCAL_EDK2)
    set(EDK_REPO https://github.com/tianocore/edk2.git CACHE STRING "")
else()
    set(EDK_REPO ${LOCAL_EDK2} CACHE INTERNAL "") # note that this could be also a remote repo
endif()

# lets the user configure it's own edk2 tag to work with
set(EDK2_TAG edk2-stable202205 CACHE STRING "the tag or commit of edk2 repo to use") # default tag 


# fetches the repo
FetchContent_Declare(
    EDK2
    GIT_REPOSITORY ${EDK_REPO}
    GIT_TAG        ${EDK2_TAG}
    GIT_SUBMODULES_RECURSE  FALSE # for some problems with cmake cloning
    GIT_PROGRESS            TRUE # show the progress of the repo cloning
)
FetchContent_Populate(EDK2)


# sets the source directory into a more redable name
set(EDK2_SOURCE ${edk2_SOURCE_DIR}) # cmake will make the repo name lowercase

