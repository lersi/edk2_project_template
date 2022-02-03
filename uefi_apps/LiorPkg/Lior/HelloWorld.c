#include <Uefi.h>
#include <Library/UefiLib.h>
#include <Library/UefiBootServicesTableLib.h>

EFI_STATUS
EFIAPI
main(
    IN EFI_HANDLE        ImageHandle,
    IN EFI_SYSTEM_TABLE  *SystemTable
    )
{
    EFI_STATUS Status;
    EFI_PHYSICAL_ADDRESS PhysicalBuffer;
    UINTN Pages;
    VOID *Buffer;
    
    Print(L"\n");
    Pages = EFI_SIZE_TO_PAGES (SIZE_16KB);
    Status = SystemTable->BootServices->AllocatePages (
                    AllocateAnyPages,
                    EfiBootServicesData,
                    Pages,
                    &PhysicalBuffer
                    );
    if (EFI_ERROR (Status)) {
        Print(L"error allocating memory\n");
        return Status;
    }
    //
    // Convert the physical address to a pointer.
    // This method works for all support CPU architectures.
    //
    Buffer = (VOID *)(UINTN)PhysicalBuffer;
    //
    // Free the allocated buffer
    //
    Status = gBS->FreePages (PhysicalBuffer, Pages);
    if (EFI_ERROR (Status)) {
        Print(L"error freeing memory\n");
        return Status;
    }
    Print(L"Success!\n");
    return EFI_SUCCESS;
}