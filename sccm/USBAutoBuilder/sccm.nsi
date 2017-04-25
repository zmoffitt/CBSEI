/*
Zachary Moffitt - Columbia Business School
 */

!define NAME "USB Self-Service Deployer"
!define FILENAME "SCCM-USB"
!define VERSION "0.1.0.1"
!define MUI_ICON "includes\images\usbicon.ico" ; "${NSISDIR}\Contrib\Graphics\Icons\nsis1-install.ico"

VIProductVersion "${VERSION}"
VIAddVersionKey CompanyName "Columbia Business School"
VIAddVersionKey LegalCopyright "Copyright ©2017 Zachary Moffitt - Columbia Business School"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey FileDescription "SCCM Auto Generator"
VIAddVersionKey License "GPL Version 2"

Name "${NAME} ${VERSION}"
OutFile "${FILENAME}-${VERSION}.exe"
RequestExecutionLevel admin ;highest
CRCCheck On
XPStyle on
ShowInstDetails nevershow
BrandingText "${NAME}"
CompletedText "Ta-da! The creation process has completed successfully!"
InstallButtonText "Create"

!include WordFunc.nsh
!include nsDialogs.nsh
!include MUI2.nsh
!include FileFunc.nsh
!include LogicLib.nsh
!AddPluginDir "plugins"

; Variables
Var HDDUSB
Var Capacity
Var VolName
Var Checker
Var FileFormat
Var FormatFat
Var FormatMe
Var FormatMeFat
Var Dialog
Var LabelDrivePage
Var Distro
Var Distro1
Var Distro2
Var DistroName
Var ISOFileName
Var ISOExpiration
Var ISOExpiration1
Var ISOExpiration2
Var DestDriveTxt
Var JustDrive
Var DestDrive
Var BootDir
Var IsoFile
Var JustISOName
Var DestDisk
Var Auth
Var Letters
Var Config2Use
Var AllDriveOption
Var DisplayAll
Var NameThatISO
Var OnlyVal
Var ShowAll
Var DismountAction


!include scripts\DiskVoodoo.nsh

; Interface settings
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "includes\images\cbs-nsis-logo.bmp"
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_HEADERIMAGE_RIGHT

; Distro Selection Page
Page custom SelectionsPage

; Install Files Page
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT $(Finish_Install)
!define MUI_TEXT_INSTALLING_TITLE $(Install_Title)
!define MUI_TEXT_INSTALLING_SUBTITLE $(Install_SubTitle)
!define MUI_TEXT_FINISH_SUBTITLE $(Install_Finish_Sucess)
!define MUI_PAGE_CUSTOMFUNCTION_PRE InstFiles_PreFunction
!insertmacro MUI_PAGE_INSTFILES

; Finish page
!define MUI_FINISHPAGE_TITLE $(Finish_Title)
!define MUI_FINISHPAGE_SUBTITLE $(Finish_SubTitle)
!define MUI_FINISHPAGE_TEXT $(Finish_Text)
!define MUI_WELCOMEFINISHPAGE_BITMAP "includes\images\finish.bmp"
!define MUI_PAGE_CUSTOMFUNCTION_PRE Finish_PreFunction
!insertmacro MUI_PAGE_FINISH

; English Language files
!insertmacro MUI_LANGUAGE "English" ; first language is the default language
LangString SelectDist_Title ${LANG_ENGLISH} "Information Technology Group - USB Auto-Deployer"
LangString SelectDist_Subtitle ${LANG_ENGLISH} "Select and confirmation of USB deployment"
LangString DrivePage_Text ${LANG_ENGLISH} "Step 1: Select the drive letter of the USB target device:"
LangString Extract ${LANG_ENGLISH} "Extracting the $FileFormat: The progress bar will not move until finished. Please be patient..."
LangString CreateSysConfig ${LANG_ENGLISH} "Creating configuration files for $DestDisk"
LangString ExecuteSyslinux ${LANG_ENGLISH} "Executing syslinux on $BootDir"
LangString SkipSyslinux ${LANG_ENGLISH} "Good Syslinux Exists..."
LangString WarningSyslinux ${LANG_ENGLISH} "An error ($R8) occurred while executing syslinux.$\r$\nYour USB drive won't be bootable...$\r$\n$\r$\nCheck to make sure your drive is formatted as Fat32 or NTFS."
LangString Install_Title ${LANG_ENGLISH} "Information Technology Group - USB Auto-Deployer"
LangString Install_SubTitle ${LANG_ENGLISH} "Please wait while we extract the boot image to $JustDrive"
LangString Install_Finish_Sucess ${LANG_ENGLISH} "Successfully deployed to $JustDrive"
LangString Finish_Install ${LANG_ENGLISH} "USB Extraction Complete!"
LangString Finish_Title ${LANG_ENGLISH} "The USB drive is ready!"
LangString Finish_SubTitle ${LANG_ENGLISH} "Please confirm that your USB is functional."
LangString Finish_Text ${LANG_ENGLISH} "I, your metal-minon, can only do so much and you will have to talk to Dr. Moffitt if there are critical or unrecoverable errors.$\r$\n$\r$\nAlso, quick reminder, this USB SELF-DESTRUCTS:$\r$\n$\r$\n$ISOExpiration$\r$\n$\r$\nPlease do not redistribute this application outside of ITG."

!include scripts\FileManipulation.nsh ; Text File Manipulation
!include scripts\FileNames.nsh ; Macro for FileNames
!include scripts\ReplaceInFile.nsh

Function SelectionsPage
  StrCpy $R8 2
 !insertmacro MUI_HEADER_TEXT $(SelectDist_Title) $(SelectDist_Subtitle)
  nsDialogs::Create 1018
  Pop $Dialog

  NSISdl::download http://dp01.sccm.gsb.columbia.edu/media/scadp/latest-v.txt tmp.txt
    Pop $R0 ;Get the return value
    StrCmp $R0 "success" +2
	Goto overwrite
    FileOpen $4 "tmp.txt" r
    FileRead $4 $ISOExpiration2
    FileClose $4
	StrCpy $ISOExpiration1 "EXPIRES:"
	Goto continue

  overwrite:
    StrCpy $ISOExpiration1 "ERROR: "
	StrCpy $ISOExpiration2 "(Unable to fetch date file! Check network connection!)"

	continue:
  ${NSD_SetText} $DistroName "deployMedia-latest"
  ${NSD_SetText} $ISOFileName "deployMedia-latest.iso"
  ${NSD_SetText} $ISOFile "$EXEDIR\$ISOFileName"
  ${NSD_SetText} $Config2Use "win.lst"

; Drive Selection Starts
  ${NSD_CreateLabel} 0 0 58% 15 ""
  Pop $LabelDrivePage
  ${NSD_SetText} $LabelDrivePage "Step 1: Select the Drive Letter of your USB Device:"

; Droplist for Drive Selection
  ${NSD_CreateDropList} 0 20 28% 15 "" ; was 0 20 15% 15
  Pop $DestDriveTxt
  Call ListAllDrives
  ${NSD_OnChange} $DestDriveTxt OnSelectDrive

; All Drives Option
  ${NSD_CreateCheckBox} 30% 23 30% 15 "Show All Drives?" ; was 17% 23 41% 15
  Pop $AllDriveOption
  ${NSD_OnClick} $AllDriveOption ListAllDrives

; Format Fat32 Option (Override)
  ${NSD_CreateCheckBox} 60% 23 100% 15 "Format Drive:$DestDisk"
  Pop $FormatFat
  ${NSD_Check} $FormatFat
  ${NSD_OnClick} $FormatFat FormatIt

; Distro information - part 1
  ${NSD_CreateLabel} 0 70 90% 15 " "
  Pop $Distro1
  ${NSD_SetText} $Distro1 "This application will download and deploy the current SCCM boot image."

; Distro information - part 2
  ${NSD_CreateLabel} 20% 87 100% 15 " "
  Pop $Distro2
  ${NSD_SetText} $Distro2 "$ISOExpiration1 $ISOExpiration2"

; Disable Next Button until a selection is made for all
  GetDlgItem $6 $HWNDPARENT 1
  EnableWindow $6 1
; Remove Back Button
  GetDlgItem $6 $HWNDPARENT 3
  ShowWindow $6 0
; Hide or disable steps until we state to display them
  ShowWindow $FormatFat 1
  EnableWindow $FormatFat 0
  nsDialogs::Show
FunctionEnd

Function GetDiskVolumeName
; Pop $1 ; get parameter
  System::Alloc 1024 ; Allocate string body
  Pop $0 ; Get the allocated string's address

  !define GetVolumeInformation "Kernel32::GetVolumeInformation(t,t,i,*i,*i,*i,t,i) i"
  System::Call '${GetVolumeInformation}("$9",.r0,1024,,,,.r2,1024)' ;

; Sort drive types and display only fixed and removable
  !define GetDriveType "Kernel32::GetDriveType(t) i"
  System::Call '${GetDriveType}("$8")' ; 1024

; Push $0 ; Push result
  ${If} $0 != ""
    StrCpy $VolName "$0"
  ${Else}
    StrCpy $VolName ""
  ${EndIf}

  StrCpy $2 "$2"
FunctionEnd ; GetDiskVolumeName

Function DiskSpace
  ${DriveSpace} "$9" "/D=T /S=G" $1 ; used to find total space of each drive
  ${If} $1 > "0"
    StrCpy $Capacity "$1GB"
  ${Else}
    StrCpy $Capacity ""
  ${EndIf}
FunctionEnd

Function DrivesList
 Call GetDiskVolumeName
 Call DiskSpace

;Prevent System Drive from being selected
 StrCpy $7 $WINDIR 3
 ${If} $9 != "$7"
 SendMessage $DestDriveTxt ${CB_ADDSTRING} 0 "STR:$9 $VolName $Capacity $8"
 ${EndIf}
 Push 1 ; must push something - see GetDrives documentation
FunctionEnd

Function ListAllDrives ; Set to Display All Drives
  SendMessage $DestDriveTxt ${CB_RESETCONTENT} 0 0
  ${NSD_GetState} $AllDriveOption $DisplayAll
  ${If} $DisplayAll == ${BST_CHECKED}
  ${NSD_Check} $AllDriveOption
  ${NSD_SetText} $AllDriveOption "Showing All Drives"
   StrCpy $ShowAll "YES"
   ${GetDrives} "FDD+HDD" DrivesList ; All Drives Listed
  ${ElseIf} $DisplayAll == ${BST_UNCHECKED}
  ${NSD_Uncheck} $AllDriveOption
  ${NSD_SetText} $AllDriveOption "Show All Drives?"
	 ${GetDrives} "FDD" DrivesList ; FDD+HDD reduced to FDD for removable media only
	StrCpy $ShowAll "NO"
  ${EndIf}
FunctionEnd

Function OnSelectDrive
  Pop $DestDriveTxt
  ${NSD_GetText} $DestDriveTxt $Letters
  StrCpy $DestDrive "$Letters"
  StrCpy $JustDrive $DestDrive 3
  StrCpy $BootDir $DestDrive 2 ;was -1
  StrCpy $DestDisk $DestDrive 2 ;was -1
  StrCpy $HDDUSB $Letters "" -3
  StrCpy $Checker "Yes"
  Call FormatIt

; Send an update to the window with the drive selection and confirmation
  ${NSD_SetText} $LabelDrivePage "Step 1: You selected $DestDisk as the USB target"
FunctionEnd

Function InstFiles_PreFunction
  StrCpy $R8 3
FunctionEnd

Function Finish_PreFunction
  StrCpy $R8 4
FunctionEnd

Function FreeDiskSpace
  ${If} $FormatMe == "Yes"
    ${DriveSpace} "$JustDrive" "/D=T /S=M" $1
  ${Else}
    ${DriveSpace} "$JustDrive" "/D=F /S=M" $1
  ${EndIf}
FunctionEnd

Function HaveSpace
  Call FreeDiskSpace
  System::Int64Op $1 > 450 ; Compare the space available - we are GUESSING that our data does not need more than 450MB!!
  Pop $3 ; Get the result ...
  IntCmp $3 1 okay ; ... and compare it
  MessageBox MB_ICONSTOP|MB_OK "ERROR: There is not enough space free! Are you sure you're using the right key?"
  quit ; Close the program if the disk space was too small...
  okay: ; Proceed to execute...
FunctionEnd

Function FormatYes ; If Format is checked, do something
  !insertmacro ReplaceInFile "DSK" "$DestDisk" "all" "all" "$PLUGINSDIR\diskpartformat.txt"
  StrCpy $DismountAction "WIPE_FORMAT"
  Call Lock_Dismount ; Lock and Dismount Volume
  Call UnLockVol ; Unlock to allow Access
  DetailPrint "Sprinkling a little DISKPART delight on $DestDisk; this is required so please wait..."
  nsExec::ExecToLog '"DiskPart" /S $PLUGINSDIR\diskpartformat.txt'

; Need to sleep just in case the host is busy!
  Sleep 2000
  DetailPrint "Making $DestDisk FAT (thirty-two), heh... hang tight..."
  nsExec::ExecToLog '"cmd" /c "echo y|$PLUGINSDIR\fat32format $DestDisk"'
  Sleep 2000
FunctionEnd

Function FormatIt ; Set Format Option
  ${NSD_GetState} $FormatFat $FormatMeFat
  ${If} $FormatMeFat == ${BST_CHECKED}
  ${NSD_Check} $FormatFat
   StrCpy $FormatMeFat "Yes"
  ${NSD_SetText} $FormatFat "Formatting: $DestDisk as FAT32"
  ${ElseIf} $FormatMeFat == ${BST_UNCHECKED}
  ${NSD_Uncheck} $FormatFat
  ${NSD_SetText} $FormatFat "Formatting: $DestDisk as FAT32"
   StrCpy $Checker "Yes"
  ${EndIf}

FunctionEnd

Function DoSyslinux ; Install Syslinux on USB
  IfFileExists "$BootDir\multiboot\libcom32.c32" SkipSyslinux CreateSyslinux ; checking for newer syslinux
  CreateSyslinux:
    CreateDirectory $BootDir\multiboot\menu ; recursively create the directory structure if it doesn't exist
    CreateDirectory $BootDir\multiboot\ISOS ; create ISOS folder
    DetailPrint $(ExecuteSyslinux)
    ExecWait '$PLUGINSDIR\syslinux.exe -maf -d /multiboot $BootDir' $R8
    DetailPrint "Syslinux Error Count: $R8"
  Banner::destroy
    ${If} $R8 != 0
      MessageBox MB_ICONEXCLAMATION|MB_OK $(WarningSyslinux)
    ${EndIf}
  DetailPrint "Creating Label MULTIBOOT on $DestDisk"
  nsExec::ExecToLog '"cmd" /c "LABEL $DestDiskMULTIBOOT"'

  SkipSyslinux:
    DetailPrint $(SkipSyslinux)
    ${IfNot} ${FileExists} $BootDir\multiboot\linux.c32 ; need linux.c32 to launch wimboot from syslinux.
      DetailPrint "Working to make wimboot work on linux framework..."
      DetailPrint "Setting up wimboot..."
      CopyFiles "$PLUGINSDIR\wimboot" "$BootDir\multiboot\wimboot"
      DetailPrint "Setting up linux.c32..."
      CopyFiles "$PLUGINSDIR\linux.c32" "$BootDir\multiboot\linux.c32"
    ${EndIf}

  ; Create and Copy core files
    DetailPrint "Adding required files to the $BootDir\multiboot directory..."
    CopyFiles "$PLUGINSDIR\syslinux.cfg" "$BootDir\multiboot\syslinux.cfg"
    CopyFiles "$PLUGINSDIR\vesamenu.c32" "$BootDir\multiboot\vesamenu.c32"
    CopyFiles "$PLUGINSDIR\menu.c32" "$BootDir\multiboot\menu.c32"
    CopyFiles "$PLUGINSDIR\chain.c32" "$BootDir\multiboot\chain.c32"
    CopyFiles "$PLUGINSDIR\libcom32.c32" "$BootDir\multiboot\libcom32.c32"
    CopyFiles "$PLUGINSDIR\libutil.c32" "$BootDir\multiboot\libutil.c32"
    CopyFiles "$PLUGINSDIR\memdisk" "$BootDir\multiboot\memdisk"
	CopyFiles "$PLUGINSDIR\cbs.png" "$BootDir\multiboot\cbs.png"
	CopyFiles "$PLUGINSDIR\grub.exe" "$BootDir\multiboot\grub.exe"
    DetailPrint "The extraction of Syslinux has completed successfully, moving along..."
    Sleep 1000
	DetailPrint "Setting up the multiboot options for legacy support..."
	CopyFiles "$PLUGINSDIR\cbs.xpm.gz" "$BootDir\multiboot\menu\cbs.xpm.gz"
	CopyFiles "$PLUGINSDIR\chain.c32" "$BootDir\multiboot\menu\chain.c32"
    CopyFiles "$PLUGINSDIR\libcom32.c32" "$BootDir\multiboot\menu\libcom32.c32"
    CopyFiles "$PLUGINSDIR\libutil.c32" "$BootDir\multiboot\menu\libutil.c32"
    CopyFiles "$PLUGINSDIR\memdisk" "$BootDir\multiboot\menu\memdisk"
	CopyFiles "$PLUGINSDIR\menu.lst" "$BootDir\multiboot\menu\menu.lst"
	CopyFiles "$PLUGINSDIR\vesamenu.c32" "$BootDir\multiboot\menu\vesamenu.c32"
	DetailPrint "USB is legacy ready! Continuing..."
	Sleep 500
FunctionEnd

; ---- Let's Do This! ----
  Section  ; This is the only section that exists
  StrCpy $DistroName "deployMedia-latest"
  StrCpy $JustISOName $DistroName
  StrCpy $ISOFileName "deployMedia-latest.iso"
  StrCpy $ISOFile "$EXEDIR\$ISOFileName"
  StrCpy $Config2Use "win.lst"
  #Call FindConfig
  Push 1
  Pop $NameThatISO
  ${NSD_GetText} $Distro $DistroName ; Was ${NSD_LB_GetSelection} $Distro $DistroName
  StrCpy $DistroName "$DistroName"
  MessageBox MB_YESNO|MB_ICONEXCLAMATION "WARNING: This will format drive $BootDir and extract the System Center Configuration Manager Boot Image!$\r$\n$\r$\nDo you wish to conitnue?" IDYES proceed
  Quit

 proceed:
   Call FormatYes ; Format the Drive?
   Call HaveSpace ; Got enough Space? Lets Check!
   Call DoSyslinux ; Run Syslinux on the Drive to make it bootable

; Copy the config file if it doesn't exist and create the entry in syslinux.cfg
  ${IfNot} ${FileExists} "$BootDir\multiboot\menu\$Config2Use"
    CopyFiles "$PLUGINSDIR\$Config2Use" "$BootDir\multiboot\menu\$Config2Use"
    ${WriteToSysFile} "label Windows Installers$\r$\nmenu label Windows Installers ->$\r$\nMENU INDENT 1$\r$\nKERNEL /multiboot/grub.exe$\r$\nAPPEND --config-file=/multiboot/menu/win.lst" $R0
  ${EndIf}
  DetailPrint "Let's see if I can update myself to the latest version..."
  NSISdl::download http://dp01.sccm.gsb.columbia.edu/media/scadp/deployMedia-latest.iso latest.iso
  Pop $R0 ;Get the return value
    StrCmp $R0 "success" +3
      MessageBox MB_OK|MB_ICONQUESTION "Download failed: $R0"
    quit
    NSISdl::download http://dp01.sccm.gsb.columbia.edu/media/scadp/latest-v.txt latest.txt
    FileOpen $4 "latest.txt" r
    FileRead $4 $ISOExpiration ; we read until the end of line (including carriage return and new line) and save it to $1
    FileClose $4 ; and close the file
    DetailPrint "Creating the boot key on $BootDir that will expire $ISOExpiration, please wait..."
    nsExec::ExecToLog '"$PLUGINSDIR\7zG.exe" x "$PLUGINSDIR\latest.iso" -o"$BootDir" -y -x![BOOT]*'
    Delete $PLUGINSDIR\src\latest.iso
    DetailPrint "Tidying up..."
    Sleep 2000
 SectionEnd

 ; --- Stuff to do at startup of script ---
Function .onInit

  SetOutPath $TEMP
  File /oname=spltmp.bmp "includes\images\cbs_splash.bmp"

  splash::show 2000 $TEMP\spltmp

  Delete $TEMP\spltmp.bmp

 StrCpy $R9 0 ; we start on page 0
 StrCpy $FileFormat "ISO"
 StrCpy $Distro "Latest Boot Image"
 StrCpy $DistroName "deployMedia-latest"
 StrCpy $FormatMe "Yes"
 StrCpy $ISOFileName "deployMedia-latest.iso"
 StrCpy $ISOFile "$EXEDIR\$ISOFileName"
 StrCpy $Config2Use "win.lst"
 userInfo::getAccountType
 Pop $Auth
 strCmp $Auth "Admin" done
 Messagebox MB_OK|MB_ICONINFORMATION "Currently you're trying to run this program as: $Auth$\r$\n$\r$\nYou must give me administrative access...$\r$\n$\r$\nRight click the file and select Run As Administrator or Run As (and select an administrative account)!"
 Abort
 done:
 SetShellVarContext all
 InitPluginsDir
  File /oname=$PLUGINSDIR\dskvol.txt "includes\op\dskvol.txt"
  File /oname=$PLUGINSDIR\diskpart.txt "includes\op\diskpart.txt"
  File /oname=$PLUGINSDIR\dd-diskpart.txt "includes\op\dd-diskpart.txt"
  File /oname=$PLUGINSDIR\diskpartformat.txt "includes\op\diskpartformat.txt"
  File /oname=$PLUGINSDIR\diskpartdetach.txt "includes\op\diskpartdetach.txt"
  File /oname=$PLUGINSDIR\syslinux.exe "tools\syslinux.exe"
  File /oname=$PLUGINSDIR\syslinux.cfg "lib\syslinux.cfg"
  File /oname=$PLUGINSDIR\menu.lst "menu\menu.lst"
  File /oname=$PLUGINSDIR\win.lst "menu\win.lst"
  File /oname=$PLUGINSDIR\grub.exe "tools\grub.exe"
  File /oname=$PLUGINSDIR\system.cfg "menu\system.cfg"
  File /oname=$PLUGINSDIR\7zG.exe "tools\7zG.exe"
  File /oname=$PLUGINSDIR\7z.dll "lib\7z.dll"
  File /oname=$PLUGINSDIR\vesamenu.c32 "lib\vesamenu.c32"
  File /oname=$PLUGINSDIR\menu.c32 "lib\menu.c32"
  File /oname=$PLUGINSDIR\memdisk "lib\memdisk"
  File /oname=$PLUGINSDIR\chain.c32 "lib\chain.c32"
  File /oname=$PLUGINSDIR\libcom32.c32 "lib\libcom32.c32"
  File /oname=$PLUGINSDIR\libutil.c32 "lib\libutil.c32"
  File /oname=$PLUGINSDIR\linux.c32 "lib\linux.c32"
  File /oname=$PLUGINSDIR\wimboot "lib\wimboot"
  File /oname=$PLUGINSDIR\remount.cmd "scripts\remount.cmd"
  File /oname=$PLUGINSDIR\boot.cmd "scripts\boot.cmd"
  File /oname=$PLUGINSDIR\dd.exe "tools\dd.exe"
  File /oname=$PLUGINSDIR\fat32format.exe "tools\fat32format.exe"
  File /oname=$PLUGINSDIR\cbs.png "includes\images\cbs.png"
  SetOutPath "$PLUGINSDIR"
  File /r "includes\wimlib"
  SetOutPath ""
FunctionEnd
