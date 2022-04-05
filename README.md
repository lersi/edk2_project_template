# EDK2 Project Template

Making build for UEFI easy
  
<br/>
<br/>

## list of content

TBD

## Introduction

### Key Objectives

* Quick and easy start of UEFI development for newbies  
* Easy out of EDK tree development
* Zero hussle with EDK build setup

### Brief Overwiew

TBD

### Installing Dependencies

This project does not has any dependencies by itself (except for Cmake and EDK2 existance obviously)

You will need to intall the dependencies of EDK2.  
these links may be useful:  

* [mac](https://github.com/tianocore/tianocore.github.io/wiki/Xcode) 
* [windows](https://github.com/tianocore/tianocore.github.io/wiki/Windows-systems#compile-tools) 
* [linux](https://github.com/tianocore/tianocore.github.io/wiki/Using-EDK-II-with-Native-GCC) 
* [intro page](https://github.com/tianocore/tianocore.github.io/wiki/Getting-Started-with-EDK-II) 

## Usage

### Invoking Cmake via vscode

This is very straightforward, just use the gui to configure and build the project.  
For customizing the project you can add variables in the file `.vscode/settings.json`.

```json
{
    "cmake.configureEnvironment": {
        "<cmake variable>": "<your special data>",
        ...
    }
}
```

### Using Commandline

```sh
cmake -S <path to this repo> -B <path to build dir>
```

TBD  
For customizing the project you can add variable via the flag `-D`:

```sh
cmake -D<variable name>=<value>
```

### Customizing via Cmake variables

editing the following variables  

| Variable              | Type              |  Description                           |
| --------------------- | ----------------- | -------------------------------------- |  
| LOCAL_EDK2            | URL or LOCAL_PATH | a local path or an url to edk2 repo    |
| EDK2_TAG              | string            | a tag name or commit or branch of edk2 |
| VS_VERSION            | string            | **WINDOWS_ONLY** <br/> version of visual studio to use. Format: `VS<year>` |


for deeper look
| Variable                           | definition/use Location             |
| ---------------------------------- | ----------------------------------- |
| LOCAL_EDK2                         | `cmake_files/include_edk2.cmake`    |
| EDK2_TAG                           | `cmake_files/include_edk2.cmake`    |
| VS_VERSION                         | `cmake_files/windows_defines.cmake` |
| TOOL_CHAIN (not user configurable) | `cmake_files/windows_defines.cmake` |


## Brief Description of edk2 build system

The EDK project is composed of packages.  
Each package is independent or is dependent on other packages.  
Package is composed of several modules. Each module can depend on another modules.

Package is spcified by a `.dsc` file, which delares basic info like:  

* supported architectures
* it's own modules
* dependencies

Module is specified by a `.inf` file, which declares more specific info, like:

* main function name (if have one)
* it's source files
* dependencies

For more explanation, you may use the following links:  

* [setup](https://github.com/tianocore/tianocore.github.io/wiki/Getting-Started-with-EDK-II)
* [build system](https://edk2-docs.gitbook.io/edk-ii-build-specification/4_edk_ii_build_process_overview/41_edk_ii_build_system)
* [guid](https://edk2-docs.gitbook.io/edk-ii-module-writer-s-guide/2_an_edk_ii_package/21_introduction)

## Creating your own Package

### Intitialise the package

#### Create the Package folder

create new folder at `uefi_apps/<your package name>Pkg`
and make sure that the folder name format is `UpperCamelCase`.  

this is your "new" source root directory.
add files and directories to this folder as the edk2 standard instructs.

#### Create the Cmake file for the Package

In the directory `uefi_apps` you need to create file named
`<your package name>_pkg.cmake`, in `snake_case`.  
Then add at the bottom of the file `CMakeLists.txt`,
The following line:  
```cmake
include(uefi_apps/<your package name>_pkg.cmake)
```

##### configure the file

1. Declare on the package name, which must be equal to the name of the package's folder.  
    i.e `set(PACKAGE_NAME <your package folder name>)`

2. Create a list with the build arguments to edk's build command.
    you mast use the flag `--platform` in order to declare on the platform to compile.
    you can find more info on the arguments at [edk's website](https://edk2-docs.gitbook.io/edk-ii-basetools-user-guides/build).  
    here is an example for build arguments:

    ```cmake
        set(BUILD_ARGS 
            --arch=X64 # architecture to compile to
            --platform=<your package>/<platform decleration file>.dsc # the platform to compile
            -n 7 # amount of threads
            # the variable TOOL_CHAIN will be provided by the this build system
            --tagname=${TOOL_CHAIN} # tool chain to use, you don't have to mention this flag but it useful if edk's build system uses the wrong tool-chain for some reason
        )
    ```

3. use the function `add_package` to create a target for you package.  
    the function recieves the package's name and then the build arguments, and creates a build target for you.  
    you can simply write: `add_package(${PACKAGE_NAME} ${BUILD_ARGS})`

here is an example for cmake file named `lior_pkg.cmake` that builds the package `LiorPkg`:  

```cmake
# the name of the package, this must be idendical to the name of the package dir
set(PACKAGE_NAME LiorPkg)

# build arguments for edk2 build system
set(BUILD_ARGS 
    --arch=X64 # architecture to compile to
    --platform=LiorPkg/lior.dsc # the platform to compile
    -n 7 # amount of threads
    --tagname=${TOOL_CHAIN} # tool chain to use
)
# this would create a target for the package
add_package(${PACKAGE_NAME} ${BUILD_ARGS})
```

### Create files for EDK2 build system

#### use the automatic generation (not yet avaible)

work in progress

#### Create Platform file (.dsc)

The dsc file uses `ini` syntax.

#### Create Module file (.inf)



## COPYRIGHT
Copyright (c) 2022 Lior Shalmay
