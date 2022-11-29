cmake_minimum_required(VERSION 3.12)
# the name of the package, this must be idendical to the name of the package dir
set(PACKAGE_NAME LiorPkg)
set(ARCHES X64 AARCH64 ARM)

# build arguments for edk2 build system
set(BUILD_ARGS 
    --platform=LiorPkg/lior.dsc # the platform to compile
    # --module=LiorPkg/Lior/lior.inf # the specific module to compile
    -n ${CORE_COUNT} # amount of threads
    --tagname=${TOOL_CHAIN} # tool chain to use
)

foreach(arch ${ARCHES})
    # this would create a target for the package
    add_package(${PACKAGE_NAME} ${arch} ${BUILD_ARGS})
endforeach()



