-- 
-- Zachary Moffitt. Columbia Business School. All rights reserved.
-- 

display dialog "Please enter machine hostname:" default answer "" with icon note buttons {"Exit", "Set Machine Name"}
if the button returned of the result is "Exit" then
	quit
else
	set machinename to text returned of result
end if

repeat while machinename = ""
	display dialog "Warning: the provided string was empty or invalid!" with icon note buttons {"OK"}
	display dialog "Please enter machine hostname:" default answer "" with icon note buttons {"Exit", "Set Machine Name"}
	if the button returned of the result is "Exit" then
		quit
	else
		set machinename to text returned of result
	end if
end repeat

display dialog "The hostname will be set to " & machinename & ". Is this correct?" with icon note buttons {"Cancel", "Yes"}
if the button returned of the result is "Cancel" then
	quit
else
	-- Set the variables for machine renaming with confirmation
	do shell script ¬
		"scutil --set HostName " & machinename with administrator privileges
	do shell script ¬
		"scutil --set LocalHostName " & machinename with administrator privileges
	do shell script ¬
		"scutil --set ComputerName " & machinename with administrator privileges
	
	-- Specify the path for the package
	set pkgPath to "/Volumes/CBS\\ Casper\\ Image\\ Installer/Resources/"
	do shell script ¬
		"open " & pkgPath & "QuickAdd.pkg" with administrator privileges
	quit
end if
return 0
quit
