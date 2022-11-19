import argparse
import os.path as path
import pathlib
import subprocess
import sys
from functools import reduce
from io import StringIO
from os import getenv
from typing import Dict, List, TextIO, Tuple

###
# defaults
###
VS_INSTALLER_PATHS = [
    path.join(getenv("ProgramFiles(x86)"), "Microsoft Visual Studio\\Installer\\vswhere.exe"),
    path.join(getenv("ProgramFiles"), "Microsoft Visual Studio\\Installer\\vswhere.exe"),
] 
VS_LOCATION_ENV_VARIABLES = [
    ("VS140COMNTOOLS","VS2015"),
    ("VS120COMNTOOLS","VS2013"),
    ("VS110COMNTOOLS","VS2012"),
]

###
# globals
###
DEBUG = False
OLD_VISUAL_STUDIO_DETECTED = False

###
# constants
###
VS_2022_MAJOR = 17
ENV_SETUP_FILE_NAMES = [
    "vcvars32.bat",
    "vsvars32.bat",
    "vcvars64.bat",
    "vsvars64.bat",
    "vcvarsall.bat",
    "vsvarsall.bat",
]
ENV_SETUP_FILE_DIRS = [
    "",
    "Common7\\Tools",
    "VC\\Auxiliary\\Build",
]
ENV_SETUP_FILE_LOCATIONS = reduce(lambda x,y: x+y,
    [[path.join(dir,file_name) for file_name in ENV_SETUP_FILE_NAMES] 
                                for dir in ENV_SETUP_FILE_DIRS]
)
###
# helper classes
###
class VisualStudionNotFound(Exception):
    pass
class ParseError(Exception):
    pass
class VsWhereParseError(ParseError):
    pass
# class VsWhereRunError(Exception):
#     pass
class UnsupportedVersion(Exception):
    pass

class VisualStudioInfo:
    """
    parserse vswhere value pairs and convert them to a more usefull information
    """
    # this table converts major VS version into an EDK2 toolchain tag.
    tag_lookup_table = {
        VS_2022_MAJOR: 'VS2019', # should be visual studio 2022, but it is not yet supported by EDK2
        16: 'VS2019',
        15: 'VS2017',
        14: 'VS2015',
        12: 'VS2013',
        11: 'VS2012',
    }
    
    @staticmethod
    def parse_version(version: str) -> Tuple[int, int]:
        """converts version string into major and minor version.

        Args:
            version (str): dot seperated version string

        Raises:
            VsWhereParseError: if the version has an invalid format.

        Returns:
            Tuple(int, int): returns a pair of major and minor version.
        """
        items = version.split('.')
        if len(items) < 2:
            raise VsWhereParseError('invalid version format')
        if not (items[0].isdecimal() or items[1].isdecimal()):
            raise VsWhereParseError('invalid version format')
        return int(items[0]), int(items[1])
    
    @staticmethod
    def convert_major_to_tag(major_version: int) -> str:
        """_summary_

        Args:
            major_version (int): _description_

        Raises:
            UnsupportedVersion: _description_

        Returns:
            str: _description_
        """
        # warn the user about using not yet supported version
        if VS_2022_MAJOR == major_version:
            print_error("WORNING: you visual studio version (2022) is not yet supported\r\n" +
                  "\t using it as visual studio 2019"
            )
        if major_version not in VisualStudioInfo.tag_lookup_table:
            raise UnsupportedVersion("you visual studio version is too old")
        return VisualStudioInfo.tag_lookup_table[major_version]
    
    def __init__(self, info_dict: Dict):
        """
        Args:
            info_dict (Dict): the raw key value pair generated by VsWhere.
        """
        self.id = info_dict['instanceId']
        self.path = info_dict['installationPath']
        self.version = info_dict['installationVersion']
        self.raw_dict = info_dict
        self.major, self.minor = self.parse_version(self.version)
        self.vs_tag = self.convert_major_to_tag(self.major)
    
    def get(self, key: str) -> str:
        """searches for a key in the dict generated by VsWhere.

        Args:
            key (str): name of a field

        Returns:
            str: value of a field
        """
        return self.raw_dict[key]

###
# helper functions
###
def print_error(*args,**kwargs):
    print(*args,file=sys.stderr,**kwargs)
    
def debug_print(*args,**kwargs):
    """prints to stderr if the DEBUG global is True
    """
    global DEBUG
    if DEBUG:
        print_error(*args,**kwargs)
        

def parse_vswhere_output(output_file: TextIO) -> List[Dict]:
    """parsers VsWhere output in to a dict
    
    Note:
    returns array of pairs because if there are multiple versions of visual studio installed,
    vswhere will return information about each of them

    Args:
        output_file (TextIO): a file like object that contains VsWhere output

    Raises:
        VsWhereParseError: if unexpected output was found
        

    Returns:
        [dict]: array of value pairs
    """
    result = []
    
    ###
    # parse heading, make sure that we are on the right software
    ###
    line = output_file.readline()
    while line == "\r\n":
        line = output_file.readline()
    if line == "":
        # got empty string, reached end of file sooner than expected.
        raise VsWhereParseError("EOF was not expected")
    
    if not line.startswith("Visual Studio Locator"):
        raise VsWhereParseError("invalid format")
    
    line = output_file.readline().strip()
    if not line.startswith("Copyright"):
        raise VsWhereParseError("invalid format")
    
    line = output_file.readline() # should be empty line, ignore it
    
    ###
    # parse the data
    ###
    line = output_file.readline()
    if line == "":
        # got empty string, reached end of file sooner than expected.
        raise VsWhereParseError("EOF was not expected")
    line = line.strip()

    while True:
        current_data = {}
        while line != "":
            items = line.split(': ')
            # in some cases, there is an empty value
            if len(items) == 1:
                key = line.strip(':')
                value = None
            # expecting only key and value
            elif len(items) > 2: 
                raise VsWhereParseError("invalid format")
            else:
                key = items[0].strip()
                value = items[1].strip()
            
            current_data[key] = value
            line = output_file.readline().strip()
        # end of loop
        if not current_data:
            # if the dict is empty, somthing went wrong in the parsing
            raise VsWhereParseError("invalid format")
        result.append(current_data)
        line = output_file.readline()
        if line == "":
            # reached EOF
            break
        line = line.strip()
    return result
        

def get_infos_from_installer(vswhere_path: str) -> List[VisualStudioInfo]:
    """gets information from VS installer and parses it

    Args:
        vswhere_path (str): path to VsWhere

    Returns:
        [VisualStudioInfo]: list of information about all visual studios that have been found
    """
    run_result = subprocess.run(vswhere_path, 
        stdout=subprocess.PIPE,
        check=True,
    )
    # get raw values
    stdout = StringIO(run_result.stdout.decode())
    infos = parse_vswhere_output(stdout)
    result = []
    for info in infos:
        try:
            # parse the values and add them to result
            result.append(VisualStudioInfo(info))
        except UnsupportedVersion as e:
            global OLD_VISUAL_STUDIO_DETECTED
            OLD_VISUAL_STUDIO_DETECTED = True
            debug_print(e)
    return result
        
    
def get_avaible_visual_studios_from_installers(vswhere_paths: List[str]) -> List[VisualStudioInfo]:
    """find information from all installlers

    Args:
        vswhere_paths (List): all paths to an vswhere executable

    Raises:
        VisualStudionNotFound: if did not find even s single visual studio

    Returns:
        [VisualStudioInfo]: list of all visual studio info that was found
    """
    result = []
    for installer in vswhere_paths:
        if path.exists(installer):
            try:
                result.extend(get_infos_from_installer(installer))
            except (subprocess.CalledProcessError, VsWhereParseError) as e:
                debug_print(e)
                
    if not result:
        # make sure if we do not find any thing to raise an error about it
        raise VisualStudionNotFound("all installers does not have visual studio")
    return result

def get_avaible_visual_studios_from_env() -> List[Tuple[str,str]]:
    """detects visual studio using env variables

    Raises:
        VisualStudionNotFound: if none of the expected env variables are defined.

    Returns:
        [(str,str)]: list of pairs, containing visual studio location and it's toolchain tag
    """
    result = []
    for env_var, tool_tag in VS_LOCATION_ENV_VARIABLES:
        vs_path = getenv(env_var)
        if vs_path != None:
            result.append((vs_path, tool_tag))
            
    if not result:
        raise VisualStudionNotFound("None of visual studios env variables are defined")
    return result
def parse_msbuild_output(output: str) -> str:
    """extracts visual studio's version string from msbuild output

    Args:
        output (str): msbuild's output

    Raises:
        ParseError: if the output is not msbuild

    Returns:
        str: visual studio version string
    """
    # this line comes before the version string
    SIGNATURE_LINE = 'Microsoft (R) Build Engine version '

    start_index = output.find(SIGNATURE_LINE)
    if start_index < 0:
        # cant find our signature
        raise ParseError("not msbuild output")
    start_index += len(SIGNATURE_LINE)
    # find the nearest new line, so we can isolate this line
    end_index = output.find('\n', start_index)
    # take the version string plus other literals
    tmp_string = output[start_index:end_index].strip()
    # get only the version string
    version_string = tmp_string.split(' ')[0]
    return version_string
    

def get_vs_version(vsvars_script_path: str) -> Tuple[int,int]:
    """finds visual studio version based on vsvar*.bat script.

    Args:
        vsvars_script_path (str): full path to a vsvar*.bat file.

    Returns:
        (int,int): Major and Minor version of visual studio.
    """
    # run the script (adds msbuild to PATH) then run msbuild to detect its version
    run_result = subprocess.run(
        ["cmd","/C",vsvars_script_path,'&&',"msbuild"],
        stdout=subprocess.PIPE,
        check=False,
    )
    version_string = parse_msbuild_output(run_result.stdout.decode())
    return VisualStudioInfo.parse_version(version_string)
    
    
def find_vsvar_script(vs_dir: str) -> str:
    """finds vsvars script from known relative location to visual studio's dir

    Args:
        vs_dir (str): visual studio's install dir or tools dir

    Raises:
        FileNotFoundError: none vsvars script was found

    Returns:
        str: full path to vsvars script
    """
    for relative_path in ENV_SETUP_FILE_LOCATIONS:
        full_path = path.join(vs_dir,relative_path)
        if path.exists(full_path):
            return full_path
    raise FileNotFoundError("could not find vsvar script")

def get_argparse() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="finds visual studio and returns its version + path to vsvar*.bat",
    )
    parser.add_argument('--installer-paths',
        type=str,
        help="additional paths, seperated by colon, to search for visual studio installer",
        dest="installer_paths",
        default=None,
    )
    parser.add_argument('--vs-tag',
        type=str,
        help="edk2 toolchain tag representing the desired visual studio version",
        dest='vs_tag',
        default=None,
    )
    parser.add_argument('--vs-path',
        type=pathlib.Path,
        help="path to visual studio installation dir",
        dest='vs_path',
        default=None,
    )
    parser.add_argument('--debug', 
        action='store_true',
        help='enable debug prints',
        dest='debug'
    )
    return parser

###========================
# main functions
###========================
def handle_additional_installers(command_line_arg: str):
    """handles the installer options
    and adds these installer into intelnal variable

    Args:
        command_line_arg (str): the value from the command line
    """
    global VS_INSTALLER_PATHS
    for installer_path in command_line_arg.split(':'):
        if not path.exists(installer_path):
            print_error(f"ERROR: the provided installer path: {installer_path} DOES NOT EXISTS")
            exit(-1)
        if path.isdir(installer_path):
            installer_path = path.join(installer_path, 'vswhere.exe')
            if not path.exists(installer_path):
                print_error(f"ERROR: could not find 'vswhere.exe' in installer dir: '{installer_path}'")
                exit(-1)
        elif not installer_path.endswith('vswhere.exe'):
            print_error(f"ERROR: probided installer path does not ends with 'vswhere.exe': '{installer_path}'")
            exit(-1)
        VS_INSTALLER_PATHS.insert(0, installer_path)
        
def handle_provided_visual_studio(vs_path: pathlib.Path, vs_tag: str = None):
    """handles the vs-path option

    Args:
        vs_path (pathlib.Path): the content of vs-path option
        vs_tag (str, optional): the option for vs-tag. Defaults to None.
    """
    if not vs_path.exists():
        print_error("ERROR: the provided visual studio path does not exists")
        exit(-1)
        
    if vs_path.is_file():
        # it's not documented, but the program can recive direct path to vsvar/vcvar
        if not (vs_path.name.startswith("vsvar") or vs_path.name.startswith("vcvar")):
            print_error("ERROR: the provided visual studio path is not a directory")
            exit(-1)
        vsvar_path = str(vs_path)
    elif vs_path.is_dir():
        vs_path = str(vs_path)
        try:
            vsvar_path = find_vsvar_script(vs_path)
        except FileNotFoundError as e:
            print_error("ERROR: "+str(e))
            exit(-1)
    else:
        print_error("ERROR: the provided visual studio path does not exists")
        exit(-1)
    
    major,_ = get_vs_version(vsvar_path)
    version_tag = VisualStudioInfo.convert_major_to_tag(major)
    
    # make sure that the version that the user wants, matches the version of 
    # visual studio that he has provided.
    if vs_tag:
        if vs_tag != version_tag:
            print_error(f"ERROR: the provided visual studio (ver: {version_tag}) does not much the provided version ({vs_tag})")
            exit(-1)
    print(",".join((vsvar_path, version_tag)))

def main():
    VISUAL_STUDIO_DETECTED = False # for error prints
    parser = get_argparse()
    args = parser.parse_args()
    if args.debug:
        # enable debug prints
        global DEBUG
        DEBUG = True
        
    if args.vs_tag:
        # make sure that we are reciving a valid tag
        if args.vs_tag not in VisualStudioInfo.tag_lookup_table.values():
            print_error(f"ERROR: invalid visual studio version/tag: {args.vs_tag}")
            exit(-1)
    
    if args.installer_paths and args.vs_path:
        # conflicting argument
        print_error("ERROR: installers paths and visual studio path, cannot be given at the same time")
        exit(-1)
    
    if args.vs_path:
        handle_provided_visual_studio(args.vs_path, args.vs_tag)
        return
    
    elif args.installer_paths:
        handle_additional_installers(args.installer_paths)
    
    found_vs_info = None # will contain the first visual studio that was found
    
    try:
        vs_infos = get_avaible_visual_studios_from_installers(VS_INSTALLER_PATHS)
        # sort the visual studios, so the latest one is first
        vs_infos.sort(key=lambda i: i.major,reverse=True)
        
        for vs_info in vs_infos:
            VISUAL_STUDIO_DETECTED = True
            tag = vs_info.vs_tag
            try:
                vsvar_script = find_vsvar_script(vs_info.path)
            except FileNotFoundError as e:
                # if for some reason we can't find the script, don't fail, go to next one instead
                debug_print(e)
                continue
            
            if not args.vs_tag or vs_info.vs_tag == args.vs_tag:
                print(','.join((vsvar_script,tag)))
                return
            if not found_vs_info:
                found_vs_info = (vsvar_script, tag)
    except VisualStudionNotFound:
        debug_print("no visual studio was found from installers")
    
    debug_print("specified version was not found from installers")
    
    try:
        pairs = get_avaible_visual_studios_from_env()
        for vs_dir,tag in pairs:
            VISUAL_STUDIO_DETECTED = True
            try:
                vsvar_script = find_vsvar_script(vs_dir)
            except FileNotFoundError as e:
                debug_print(e)
                continue
            
            if not args.vs_tag or args.vs_tag == tag:
                print(','.join((vsvar_script,tag)))
                return
            if not found_vs_info:
                found_vs_info = (vsvar_script,tag)
            
    except VisualStudionNotFound:
        debug_print("no visual studio was found from env")
    
    # last resort
    if found_vs_info:
        print_error("WARNING: could not find the specified visual studio version, using lates found instead")
        print(','.join(found_vs_info))
        return
    
    if VISUAL_STUDIO_DETECTED:
        print_error("ERROR: visual studio was detected, but could not find vsvar script")
    elif OLD_VISUAL_STUDIO_DETECTED:
        print_error("ERROR: old visual studio was detected, please install newer one")
    else:
        print_error("ERROR: could not find any visual studio, please provide one")
    exit(-1)
    
    
if __name__ == '__main__':
    main()