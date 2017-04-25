/*
 * This file is part of YUMI
 *
 * YUMI is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * any later version.
 *
 * YUMI is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with YUMI.  If not, see <http://www.gnu.org/licenses/>.
 */

; -------- Configuration and Text File Manipulation Stuff! --------

!macro WriteToFile String File
 Push "${String}"
 Push "${File}"
 Call WriteToFile
 ${LineFind} "$BootDir\multiboot\menu\$Config2Use" "$BootDir\multiboot\menu\$Config2Use" "1:-1" "DeleteEmptyLine" ; Remove any left over empty lines
!macroend  
!define WriteToFile "!insertmacro WriteToFile"

Function WriteToSysFile ; Write entry to syslinux.cfg
 Exch $R0 ;file to write to
 Exch
 Exch $1 ;text to write
 FileOpen $R0 '$BootDir\multiboot\syslinux.cfg' a 
 FileSeek $R0 0 END
 FileWrite $R0 '$\r$\n$1$\r$\n'
 FileClose $R0
 Pop $1
 Pop $R0
FunctionEnd
!macro WriteToSysFile String File
  Push "${String}"
  Push "${File}"
  Call WriteToSysFile
!macroend  
!define WriteToSysFile "!insertmacro WriteToSysFile"

