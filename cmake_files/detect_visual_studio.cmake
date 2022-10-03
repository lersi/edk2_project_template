####
# description: detects visual studio location, version and devenvironment.
# author: Lior Shalmay
####

cmake_minimum_required(VERSION 3.20)
set(force_vs_search FALSE)

if(DEFINED CUSTOM_VS_INSTALLER_PATHS)
    if(NOT ${CUSTOM_VS_INSTALLER_PATHS} STREQUAL ${_CUSTOM_VS_INSTALLER_PATHS})
        # enables users to add there own paths
        set(_CUSTOM_VS_INSTALLER_PATHS ${CUSTOM_VS_INSTALLER_PATHS} CACHE INTERNAL "list of paths to search for visual studio installer, seperated by colon" FORCE)
        set(force_vs_search TRUE)
        unset(_CUSTOM_VS_DIR CACHE)
    endif()
endif()

if(DEFINED VS_TAG)
    if(NOT ${VS_TAG} STREQUAL ${_VS_TAG})
        # enables users to select specific vs version
        set(_VS_TAG ${VS_TAG} CACHE INTERNAL "visual studio version tag i.e VS2019" FORCE)
        set(force_vs_search TRUE)
    endif()
endif()

if(DEFINED CUSTOM_VS_DIR)
    if(DEFINED CUSTOM_VS_INSTALLER_PATHS)
        message(FATAL_ERROR "'CUSTOM_VS_DIR' and 'CUSTOM_VS_INSTALLER_PATHS' cannot be defined at the same time")
    endif()
    if(NOT ${VS_TAG} STREQUAL ${_VS_TAG})
        # enables users to deliver custom vs location
        set(_CUSTOM_VS_DIR ${VS_TAG} CACHE INTERNAL "visual studio install dir location" FORCE)
        set(force_vs_search TRUE)
        unset(_CUSTOM_VS_INSTALLER_PATHS CACHE)
    endif()
endif()

set(force_vs_search TRUE)
unset(_VS_TAG CACHE)
if(${force_vs_search} OR NOT DEFINED VS_ENVIRONMENT_SCRIPT)
    set(args "")
    if(DEFINED _CUSTOM_VS_INSTALLER_PATHS)
        set(args "${args} --installer-paths ${_CUSTOM_VS_INSTALLER_PATHS}")
    endif()
    if(DEFINED _VS_TAG)
        set(args "${args} --vs-tag ${_VS_TAG}")
    endif()
    if(DEFINED _CUSTOM_VS_DIR)
        set(args "${args} --vs-path ${_CUSTOM_VS_DIR}")
    endif()

    execute_process(
        COMMAND ${PYTHON_COMMAND} ${CMAKE_SCRIPTS_DIR}/detect_visual_studio.py ${args}
        OUTPUT_VARIABLE output
        COMMAND_ERROR_IS_FATAL ANY
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REPLACE "," ";" outputs ${output})

    list(GET outputs 0 vs_script)
    list(GET outputs 1 vs_tag)
    set(VS_ENVIRONMENT_SCRIPT ${vs_script} CACHE INTERNAL "the script that defines all visual studio's environment" FORCE)
    set(_VS_TAG ${vs_tag} CACHE INTERNAL "visual studio version tag i.e VS2019" FORCE)
endif()

