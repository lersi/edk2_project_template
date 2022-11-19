
if(NOT DEFINED TOOL_CHAIN)
    # executing these commands in pipe will get darwin major version
    execute_process(
        COMMAND uname -r
        OUTPUT_VARIABLE DARWIN_VERSION
    )
    message(NOTICE "darwin version: ${DARWIN_VERSION}")
    # different darwin versions need different toolchains
    # note that "Darwin version" ≠ "OS X version" (i.e OS X Yosemite 10.10.2 has Darwin version 14)
    if (${DARWIN_VERSION} VERSION_LESS 10)
        # these old mac os versions are not supported by edk's build system
        message(FATAL_ERROR "this macos version is not supported please upgrade to a newer version")
    elseif(${DARWIN_VERSION} VERSION_LESS 11) # only major 10
        set(TOOL_CHAIN "XCODE32" CACHE INTERNAL "")
    elseif(${DARWIN_VERSION} VERSION_LESS 13) # only majors 11 and 12
        set(TOOL_CHAIN "XCLANG" CACHE INTERNAL "")
    else() # major 13 and forward
        set(TOOL_CHAIN "XCODE5" CACHE INTERNAL "")
    endif()
endif()
message(NOTICE "using toolchain: ${TOOL_CHAIN}")
set(TARGET_TOOLS "${TOOL_CHAIN}")
