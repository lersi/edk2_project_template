# EDK2 Project Template

Making build for UEFI easy
  
<br/>

## List of content

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
    - [Create Module file (.inf)](#create-module-file-inf)
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

- Quick and easy start of UEFI development for newbies  
- Easy out of EDK tree development
- Zero hussle with EDK build setup

### Brief Overwiew

This project is a cmake warper to edk's build system.
And it is devided into 3 seperate components:  
1. middleware scripts between cmake and edk's build command, located under `build_scripts`.
2. cmake files that implements the core of this build system, located under `cmake_files`.
3. packages for edk2, located under `uefi_apps`.

### Installing Dependencies

This project does not has any dependencies by itself (except for Cmake and EDK2's existance obviously)

You will need to intall the dependencies of EDK2.  
these links may be useful for installing these dependencies:  

- [mac](https://github.com/tianocore/tianocore.github.io/wiki/Xcode) 
- [windows](https://github.com/tianocore/tianocore.github.io/wiki/Windows-systems#compile-tools) 
- [linux](https://github.com/tianocore/tianocore.github.io/wiki/Using-EDK-II-with-Native-GCC) 
- [intro page](https://github.com/tianocore/tianocore.github.io/wiki/Getting-Started-with-EDK-II) 

## Usage

### Invoking Cmake via vscode

This is very straightforward, just use the gui to configure and build the project.  
For customizing the project you can add variables in the file `.vscode/settings.json`.

```json
{
    "cmake.configureArgs" : [
      "-D<variable name>=<value>",
    ]
}
```

> ### Note
> cmake may fail to configure or build when invoked from vs code.
> if cmake fails, try to invoke it again from the commandline.

### Using Commandline

Configure the project:

```sh
cmake -S <path to this repo> -B <path to build dir>
```

Build the package:

```sh
cmake --build <path to build dir> --target <package name>
```

For customizing the project you can add variable via the flag `-D` when configuring the project:

```sh
cmake -D<variable name>=<value> <rest of cmake configuration flags>
```

### Customizing via Cmake variables

editing the following variables will change the build system behavior.  

| Variable              | Type              |  Description                           |
| --------------------- | ----------------- | -------------------------------------- |  
| LOCAL_EDK2            | URL or PATH       | a local path or an url to edk2 repo    |
| EDK2_TAG              | string            | a tag name or commit or branch of edk2 |
| VS_TAG                | string            | **WINDOWS_ONLY** <br/> version of visual studio to use. Format: `VS<year>` |
| PYTHON_COMMAND        | string            | full path to python interperter or name of python command in path |
| CORE_COUNT            | int (as a string) | the amount of treads to use in the build process |
| CONF_PATH             | PATH              | a path to save edk's build configuration |
| | | |


you may want to look at the source of the variables for deeper look.
| Variable                           | definition/use Location             |
| ---------------------------------- | ----------------------------------- |
| LOCAL_EDK2                         | `cmake_files/generic/include_edk2.cmake`    |
| EDK2_TAG                           | `cmake_files/generic/include_edk2.cmake`    |
| VS_TAG                             | `cmake_files/windows/detect_visual_studio.cmake` |
| PYTHON_COMMAND                     | `cmake_files/generic/detect_python.cmake` |
| CORE_COUNT                         | `cmake_files/generic/core_count.cmake` |
| CONF_PATH                          | `cmake_files/unix/configure_build_system.cmake` OR `` |
|                           | `` |
|                           | `` |


## Brief Description of edk2 build system

The EDK project is composed of packages.  
Each package is independent or is dependent on other packages.  
Package is composed of several modules. Each module can depend on some other modules.

Package is spcified by a `.dsc` file, which delares basic info like:  

- supported architectures
- it's own modules
- dependencies

Module is specified by a `.inf` file, which declares more specific info like:

- main function name (if have one)
- it's source files
- dependencies

For more explanation, you may use the following links:  

- [setup](https://github.com/tianocore/tianocore.github.io/wiki/Getting-Started-with-EDK-II)
- [build system](https://edk2-docs.gitbook.io/edk-ii-build-specification/4_edk_ii_build_process_overview/41_edk_ii_build_system)
- [guide](https://edk2-docs.gitbook.io/edk-ii-module-writer-s-guide/2_an_edk_ii_package/21_introduction)

## Creating your own Package

### Initialize the package

#### Create the Package folder

Create new folder at `uefi_apps/<your package name>Pkg`
and make sure that the folder name format is `UpperCamelCase`.  
This is your "new" source root directory,
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

#### Create Platform file (.dsc)

The dsc file uses `ini` like syntax.  

> #### \[Defines\] Section
>  
> This section defines importent information for edk2's build system.  
> The format for entries in this section is: `<name> = <vlaue>`.  
> You mast define these variables:  
>
> | Variable name           | Type                | Description |
> | ----------------------- | ------------------- | ----------- |
> | DSC_SPECIFICATION       | 32 bit hex or float | the version of the specification. It does not need to be changed, unless you use a specific feature that appears in a newer specification. Format: `<major>.<minor>` or Upper 16 bits = Major, Lower 16 bit = Minor. |
> | PLATFORM_NAME           | String              | a name for your platform, must be unique. |
> | PLATFORM_GUID           | uuid                | an uuid for your platform, must be unique. |
> | PLATFORM_VERSION        | 32 bit hex or float | the version of your package. |
> | OUTPUT_DIRECTORY        | relative path       | a path for placing your build artifacts, it's relative to `WORKSPACE` dir. |
> | SUPPORTED_ARCHITECTURES | list                | a list that contains all the architectures that the package supports. Format: `<arch>|<another arch>`. |
> | BUILD_TARGETS           | list                | list of your build targets. avaible options are `DEBUG` `RELEASE` `NOOPT`. To create more options you need to edit the file `tools_def.txt` in edk's build tools conf directory. |

> #### \[LibraryClasses\] Section
>  
> In this section you declare on the libraries your module is going to use.
> Use the names declared here in `inf`'s file `[LibraryClasses]` section.  
> Format: `<libname>|<path to lib module's inf file>[|<path to lib module's inf file>...]`  
> **Note** you also need to declare on library classes needed by the modules you depend on.

> #### \[Components\] Section
>
> Here you define the modules and libraries that will be compiled as part of the package.
> Format: path to the `inf` file of the module: `<package name>/path/to/module.inf`.  each path is seperated by a new line.

> ### **Note**
>
> There are more section, these sctions are the basic sections that must be defined in order to compile the package.

For more info, you may read the [dsc specification](https://edk2-docs.gitbook.io/edk-ii-dsc-specification).  

#### Create Module file (.inf)

The inf file uses `ini` like syntax.  

> #### \[Definess\] Section
>
> This section defines importent information for edk2's build system.  
> The format for entries in this section is: `<name> = <vlaue>`.  
> You mast define these variables:  
>
> | Variable name | Type                | Description |
> | ------------- | ------------------- | ----------- |
> | INF_VERSION   | 32 bit hex or float | the version of the specification, does not need to be changed, unless you use a specific feature that apears in newer specification. Format: `<major>.<minor>` or Upper 16 bits = Major, Lower 16 bit = Minor. |
> | BASE_NAME     | string              | an unique name for the module |
> | FILE_GUID     | uuid                | an uuid for the module |
> | MODULE_TYPE   | string              | the module's type i.e application or driver. For all module types, please see [module types table](https://edk2-docs.gitbook.io/edk-ii-inf-specification/appendix_f_module_types). |
> | ENTRY_POINT   | string              | the name of the entry point function (only applies to applications and drivers) |

> #### \[LibraryClasses\] Section
>
> In this section you declare on the libraies that your module is depended on. use the library names you have defined in the `inf` file.  
> each name sould be seperated by a new line.  

> #### \[Sources\] Section
>
> This section is used to declare on the source files of the module, both header files and source files must be declared here (and any other file that is part of the source).
> This section contains the source file paths relative to `inf`'s file location.
> Each path is seperated by a new line.

> #### \[Packages\] Section
>
> This section is used to list all edk2's decleration files that are used by this module.
> Sadly, I am not going to explain what decleraion files are, you only need to know that 
> **every** *executable* module need to declare on the file: `MdePkg/MdePkg.dec`.

> ### **Note**
>
> There are more section, these sctions are the basic sections that must be defined in order to compile the module.

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
Copyright (c) 2022 Lior Shalmay. All rights reserved.

## LICENSE
This project is distributed both under Propriatary License and GPL-2
