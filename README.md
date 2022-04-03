# EDK2 Project Template

Making build for UEFI easy
  
<br/>
<br/>

## list of content

TBD

## Usage

### Invoking cmake via vscode

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

### Using command line

```sh
cmake -S <path to this repo> -B <path to build dir>
```

TBD  
For customizing the project you can add variable via the flag `-D`:

```sh
cmake -D<variable name>=<value>
```

### Customizing via cmake variables

editing the following variables  

| Variable              | Type              |  Description                           |
| --------------------- | ----------------- | -------------------------------------- |  
| LOCAL_EDK2            | URL or LOCAL_PATH | a local path or an url to edk2 repo    |
| EDK2_TAG              | string            | a tag name or commit or branch of edk2 |
| VS_VERSION            | string            | WINDOWS_ONLY <br/> version of visual studio to use. format: `VS<year>` |


for deeper look
| Variable              | definition/use Location             |
| --------------------- | ----------------------------------- |
| LOCAL_EDK2            | `cmake_files/include_edk2.cmake`    |
| EDK2_TAG              | `cmake_files/include_edk2.cmake`    |
| VS_VERSION            | `cmake_files/windows_defines.cmake` |


## brief description of edk2 build system

TBD

## creating your own pkg

### Intitialise the package

#### Create the Package folder

create new folder at `uefi_apps/<your package name>Pkg`
and make sure that the folder name format is `UpperCamelCase`.  

this is your "new" source root directory.
add files and directories to this folder as the edk2 standard instructs.

#### Create the Cmake file for the Package

TBD

#### Create files for EDK2 build system

##### use the automatic generation (not yet avaible)

work in progress


