# EDK2 Project Template

Making build for UEFI easy
  
<br/>
<br/>

## List of content

- [EDK2 Project Template](#edk2-project-template)
  - [List of content](#list-of-content)
  - [Introduction](#introduction)
    - [Key Objectives](#key-objectives)
    - [Brief Overwiew](#brief-overwiew)
    - [Installing Dependencies](#installing-dependencies)
  - [Usage](#usage)
    - [Invoking Cmake via vscode](#invoking-cmake-via-vscode)
    - [Using Commandline](#using-commandline)
    - [Customizing via Cmake variables](#customizing-via-cmake-variables)
  - [Brief Description of edk2 build system](#brief-description-of-edk2-build-system)
  - [Creating your own Package](#creating-your-own-package)
    - [Intitialise the package](#intitialise-the-package)
      - [Create the Package folder](#create-the-package-folder)
      - [Create the Cmake file for the Package](#create-the-cmake-file-for-the-package)
        - [Configure the File](#configure-the-file)
    - [Create files for EDK2 build system](#create-files-for-edk2-build-system)
      - [use the automatic generation (not yet avaible)](#use-the-automatic-generation-not-yet-avaible)
      - [Create Platform file (.dsc)](#create-platform-file-dsc)
        - [\[Defines\] Section](#defines-section)
      - [Create Module file (.inf)](#create-module-file-inf)
        - [\[Definess\] Section](#definess-section)
  - [More Info on EDK2](#more-info-on-edk2)
    - [Lists of all tianocore documentation (more or less)](#lists-of-all-tianocore-documentation-more-or-less)
    - [Guides](#guides)
    - [Training](#training)
    - [Compilation Environment](#compilation-environment)
    - [Build Files specifications](#build-files-specifications)
    - [Security](#security)
    - [etc](#etc)
    - [Lot of info about computers](#lot-of-info-about-computers)
  - [COPYRIGHT](#copyright)

## Introduction

### Key Objectives

* Quick and easy start of UEFI development for newbies  
* Easy out of EDK tree development
* Zero hussle with EDK build setup

### Brief Overwiew

TBD

### Installing Dependencies

This project does not has any dependencies by itself (except for Cmake and EDK2's existance obviously)

You will need to intall the dependencies of EDK2.  
these links may be useful for installing these dipendencies:  

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

Configure the project:

```sh
cmake -S <path to this repo> -B <path to build dir>
```

Build the package:

```sh
cmake --build <path to build dir> --target <package name>
```

For customizing the project you can add variable via the flag `-D`:

```sh
cmake -D<variable name>=<value>
```

### Customizing via Cmake variables

editing the following variables will change the build system behavior.  

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

Module is specified by a `.inf` file, which declares more specific info like:

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

this is your "new" source root directory,
add files and directories to this folder as the edk2 specification instructs.

#### Create the Cmake file for the Package

In the directory `uefi_apps` you need to create file named
`<your package name>_pkg.cmake`, in `snake_case`.  
Then add the following line at the bottom of the file `CMakeLists.txt`:
  
```cmake
include(uefi_apps/<your package name>_pkg.cmake)
```

##### Configure the File

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

The dsc file uses `ini` like syntax.  

##### \[Defines\] Section

For more info, you may read the [dsc specification](https://edk2-docs.gitbook.io/edk-ii-dsc-specification).  

#### Create Module file (.inf)

The inf file uses `ini` like syntax.  

##### \[Definess\] Section

For more info, you may read the [inf specification](https://edk2-docs.gitbook.io/edk-ii-inf-specification).  

## More Info on EDK2

### Lists of all tianocore documentation (more or less)

https://github.com/tianocore-docs/tianocore-docs.github.io 
https://github.com/tianocore/tianocore.github.io/wiki/EDK-II-Documents 

### Guides

https://edk2-docs.gitbook.io/edk-ii-module-writer-s-guide/  
https://edk2-docs.gitbook.io/edk-ii-uefi-driver-writer-s-guide/  

### Training

https://github.com/tianocore-training/Tianocore_Training_Contents/wiki  
https://github.com/tianocore/tianocore.github.io/wiki/Training  
https://github.com/tianocore-docs/Training  

### Compilation Environment

windows https://github.com/tianocore/tianocore.github.io/wiki/Windows-systems#compile-tools  
macos   https://github.com/tianocore/tianocore.github.io/wiki/Xcode  
linux   https://github.com/tianocore/tianocore.github.io/wiki/Using-EDK-II-with-Native-GCC  
https://edk2-docs.gitbook.io/edk-ii-basetools-user-guides/build  
https://edk2-docs.gitbook.io/edk-ii-build-specification/4_edk_ii_build_process_overview/41_edk_ii_build_system  
https://github.com/tianocore/tianocore.github.io/wiki/Getting-Started-with-EDK-II  

### Build Files specifications

https://edk2-docs.gitbook.io/edk-ii-fdf-specification/  
https://edk2-docs.gitbook.io/edk-ii-dsc-specification  
https://edk2-docs.gitbook.io/edk-ii-dec-specification/  
https://edk2-docs.gitbook.io/edk-ii-inf-specification  

### Security

https://edk2-docs.gitbook.io/a-tour-beyond-bios-memory-protection-in-uefi-bios/  
https://edk2-docs.gitbook.io/security-advisory/  
https://edk2-docs.gitbook.io/understanding-the-uefi-secure-boot-chain/  

### etc

https://github.com/tianocore-docs  
https://edk2-docs.gitbook.io/edk-ii-c-coding-standards-specification/  

### Lot of info about computers

https://opensecuritytraining.info/IntroBIOS.html

## COPYRIGHT
Copyright (c) 2022 Lior Shalmay
