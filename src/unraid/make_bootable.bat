@echo off
:: v1.0 - script to make the USB Flash device from which this is run bootable.
:: v1.1 - script authorization check code contributed by forum member "Spectrum"
:: v1.2 - include 'f' switch to syslinux invokation to handle devices not marked "removeable"
:: v1.3 - make "script authorization" and "volume label" check language independent
:: v1.4 - add check of syslinux executable presence
:: v1.5 - add Legacy/UEFI boot mode selection

echo Make Bootable v1.5

:: check script authorization
net session >nul 2>&1
if not %errorlevel% equ 0 (
  echo ERROR - script must be run as administrator
  echo:
  echo Right click and select 'Run as administrator'
  echo or execute from an elevated command prompt.
  goto:end
)

:: check syslinux executable
set syslinux=%~d0\syslinux\syslinux.exe
if not exist %syslinux% (
  echo ERROR - syslinux executable not found, expected: %syslinux%
  goto:end
)

:: output volume information
vol %~d0

:: check volume label
set tag=UNRAID
set label=
for /f %%v in ('vol %~d0^|findstr %tag%') do set label=%tag%
if not defined label (
  echo ERROR - volume label must be %tag%
  goto:end
)

:: Skip boot mode selection when not present
if not exist EFI (
if not exist EFI- (
  goto:make
))

:: Select boot mode
:select
echo:
set/p boot="Permit UEFI boot mode [Y/N]: "
if /i %boot%==N (
  if exist EFI (
  if not exist EFI- (
    rename EFI EFI-
  ))
  goto:make
)
if /i %boot%==Y (
  if exist EFI- (
  if not exist EFI (
    rename EFI- EFI
  ))
  goto:make
)
echo Please answer Y or N
goto:select

:: make bootable
:make
echo Ready to make disk bootable!
pause
echo %syslinux% -maf %~d0
%syslinux% -maf %~d0
echo Completed

:end
echo:
pause
