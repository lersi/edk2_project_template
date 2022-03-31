[Defines]
  PLATFORM_NAME           = Lior
  PLATFORM_GUID           = aaddf6e3-7ed7-323c-a77e-ee6498f52ecb
  PLATFORM_VERSION        = 0.1
  DSC_SPECIFICATION       = 0x00010005
#   OUTPUT_DIRECTORY        = Build/Lior
  OUTPUT_DIRECTORY        = LiorPkg
  SUPPORTED_ARCHITECTURES = X64 # IA32|IPF|X64|EBC
  BUILD_TARGETS           = DEBUG # DEBUG|RELEASE
  SKUID_IDENTIFIER        = DEFAULT

# [SkuIds] 0|DEFAULT #The entry: 0|DEFAULT is reserved and required.

[LibraryClasses]
  ## More library instances need to be added if more library classes are used
  ## by the components in the following [Components] section.
  ## library class name | library instance INF file path from package
  DebugLib | MdePkg/Library/UefiDebugLibStdErr/UefiDebugLibStdErr.inf
  BaseLib | MdePkg/Library/BaseLib/BaseLib.inf
  BaseMemoryLib | MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf

  ## Basic Library
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
  DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
  SynchronizationLib|MdePkg/Library/BaseSynchronizationLib/BaseSynchronizationLib.inf
  CpuLib|MdePkg/Library/BaseCpuLib/BaseCpuLib.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  ## Pci Library
  PciCf8Lib|MdePkg/Library/BasePciCf8Lib/BasePciCf8Lib.inf
  PciExpressLib|MdePkg/Library/BasePciExpressLib/BasePciExpressLib.inf
  PciLib|MdePkg/Library/BasePciLibCf8/BasePciLibCf8.inf
  ## Entry Point Library
  PeimEntryPoint|MdePkg/Library/PeimEntryPoint/PeimEntryPoint.inf
  UefiDriverEntryPoint|MdePkg/Library/UefiDriverEntryPoint/UefiDriverEntryPoint.inf
  UefiApplicationEntryPoint|MdePkg/Library/UefiApplicationEntryPoint/UefiApplicationEntryPoint.inf
  ## PEI service library
  PeiServicesLib|MdePkg/Library/PeiServicesLib/PeiServicesLib.inf
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLib/PeiServicesTablePointerLib.inf
  ## UEFI and DXE service library
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  DxeServicesTableLib|MdePkg/Library/DxeServicesTableLib/DxeServicesTableLib.inf
  UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf
  DxeServicesLib|MdePkg/Library/DxeServicesLib/DxeServicesLib.inf
  UefiRuntimeLib|MdePkg/Library/UefiRuntimeLib/UefiRuntimeLib.inf
  UefiLib|MdePkg/Library/UefiLib/UefiLib.inf
  DevicePathLib|MdePkg/Library/UefiDevicePathLib/UefiDevicePathLib.inf
  ## This library instance should be provide by chipset.
  TimerLib|MdePkg/Library/BaseTimerLibNullTemplate/BaseTimerLibNullTemplate.inf

  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  RegisterFilterLib|MdePkg/Library/RegisterFilterLibNull/RegisterFilterLibNull.inf


##PCDs sections are not specified.
##All PCDs value are from their Default value in DEC.
##[PcdsFeatureFlag]
##[PcdsFixedAtBuild]
[Components]
  # All libraries, drivers and applications are added here to be compiled
  #
  # Module INF file path are specified from package directory.
  LiorPkg/Lior/lior.inf

