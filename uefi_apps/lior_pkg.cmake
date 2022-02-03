cmake_minimum_required(VERSION 3.12)
set(PACKAGE_NAME LiorPkg)

set(BUILD_ARGS 
    --arch=X64
    --platform=LiorPkg/lior.dsc
    # --module=LiorPkg/Lior/lior.inf
    -n 7
    --tagname=${TOOL_CHAIN}
)

add_package(${PACKAGE_NAME} ${BUILD_ARGS})

