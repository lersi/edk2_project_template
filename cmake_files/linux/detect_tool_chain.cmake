if(NOT DEFINED TOOL_CHAIN)
    # executing these commands in pipe will get darwin major version
    execute_process(
        COMMAND gcc --version
        COMMAND head -n 1
        COMMAND awk "{print $4}"
        OUTPUT_VARIABLE GCC_VERSION
    )

    
    if(${GCC_VERSION} VERSION_LESS 4.8)
    # edk2 requires gcc 4.8 and later
        message(FATAL_ERROR "EDK2 required gcc version of 4.8 or later")
    elseif(${GCC_VERSION} VERSION_LESS 4.9)
    # gcc is version 4.8.x
        set(TOOL_CHAIN "GCC48" CACHE INTERNAL "")
    elseif(${GCC_VERSION} VERSION_LESS 5.0)
    # gcc is version 4.9.x
        set(TOOL_CHAIN "GCC49" CACHE INTERNAL "")
    else()
    # gcc is version 5.0 or later
        set(TOOL_CHAIN "GCC5" CACHE INTERNAL "")
    endif()
    
endif()
message(NOTICE "using toolchain: ${TOOL_CHAIN}")
set(TARGET_TOOLS "${TOOL_CHAIN}")
