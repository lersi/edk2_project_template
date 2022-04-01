# EDK2 Project Template

## Making build for UEFI easy
  
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

| Variable              |  Type             |  Description  | Location (for deeper look) |
| -------------------   |  -----            | ------------- | -------------------------- |  
| LOCAL_EDK2            | URL or LOCAL_PATH | 
|
|