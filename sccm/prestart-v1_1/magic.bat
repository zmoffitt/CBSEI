;Created by Zachary Moffitt (znm2104)
;Revision 1.1 on June 22nd 2016
;Used for SCCM predeployments by USB key

:StartCBSEIS
@echo off
cls
echo.
echo    ---------------------------------------------------------
echo            Welcome to the Columbia Business School 
echo                 Enterprise Imaging Suite (v1.1)
echo    ---------------------------------------------------------
echo.
echo    note: this preps the system for imaging via SCCM from USB
echo.
echo.
set /p choice=Do you want to continue? [y/n] 
IF %choice% == y goto PrepWork
IF %choice% == n exit

:PrepWork
@echo off
echo.
echo WARNING: We need to format the drive!
echo.
set /p choice=Should I list the disks for you? [y/n] 
IF %choice% == y goto ListDisk
IF %choice% == n goto SelectDisk

:ListDisk
cls
echo Here are the available disks I see on this system: 
diskpart /s list.txt

:SelectDisk
echo.
set /p choice=What disk should be selected and formatted? [0/1/2/list] 
IF %choice% == 0 goto UseDisk0
IF %choice% == 1 goto UseDisk1
IF %choice% == 2 goto UseDisk2
IF %choice% == list goto ListDisk

:UseDisk0
echo.
echo WARNING!! We are about to format DISK 0!
echo.
set /p choice=Are you sure you would like to format DISK 0? This cannot be undone! [y/n] 
IF %choice% == y goto MakeDisk0
IF %choice% == n goto PrepWork

:MakeDisk0
cls
echo    ---------------------------------------------------------
echo             FORMATTING DISK 0 AS CLEAN PARTITION 
echo    ---------------------------------------------------------
diskpart /s makeDisk0.txt
echo.
echo DISK 0 has been formatted.
goto CompleteCheck

:UseDisk1
echo.
echo WARNING!! We are about to format DISK 1!
echo.
set /p choice=Are you sure you would like to format DISK 1? This cannot be undone! [y/n] 
IF %choice% == y goto MakeDisk1
IF %choice% == n goto PrepWork

:MakeDisk1
cls
echo    ---------------------------------------------------------
echo            FORMATTING DISK 1 AS CLEAN PARTITION 
echo    ---------------------------------------------------------
echo.
echo.
diskpart /s makeDisk1.txt
echo.
echo DISK 1 has been formatted.
echo.
goto CompleteCheck

:UseDisk2
echo.
echo WARNING!! We are about to format DISK 2!
echo.
set /p choice=Are you sure you would like to format DISK 2? This cannot be undone. [y/n] 
IF %choice% == y goto MakeDisk2
IF %choice% == n goto PrepWork

:MakeDisk2
echo.
echo.
echo    ---------------------------------------------------------
echo            FORMATTING DISK 2 AS CLEAN PARTITION 
echo    ---------------------------------------------------------
echo.
echo.
diskpart /s makeDisk2.txt
echo.
echo DISK 2 has been formatted.
echo.
goto CompleteCheck

:CompleteCheck
echo.
set /p choice=Did the operation complete successfully? [y/n] 
IF %choice% == y goto Complete
IF %choice% == n goto StartCBSEIS

:Complete
echo.
echo The process is complete. We will now continue to the WinPE environment.
echo.
pause
exit