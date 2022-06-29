[CmdletBinding()]
Param(
    [switch] $full = $false
)

$oPC = Read-Host -Prompt "Old PC name"
#Connection test old.
if (-not (Test-Connection -ComputerName $oPC -Count 1 -Quiet)){
    Throw "$oPC not found!"
}else{
    Write-Verbose -Message "$oPC connected successfully." 
}

$nPC = Read-Host -Prompt "New PC name"
#Connection test new.
if (-not (Test-Connection -ComputerName $nPC -Count 1 -Quiet)){
    Throw "$nPC not found!"
}else{
    Write-Verbose -Message "$nPC connected successfully." 
}

$error.clear()
Try{
    $prompt = Read-Host -Prompt "User to migrate"
    #convertion to SAM needs RSAT: Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online
    $firstName = $prompt.Split(" ", 2)[0]
    $lastName = $prompt.Split(" ", 2)[1]
    $name = "$lastName, $firstName"
    $User = Get-ADuser -filter "Name -like '$name'" -Properties SamAccountName
    $userName = $User.SamAccountName
    Write-Verbose -Message "SAM account name $username found."
}catch{
    "Can't access AD."
}
if ($error){
	$userName = Read-Host -Prompt "AD not available. Use logon name instead"
}


#user test on old.
if (-not (Test-Path -Path "\\$oPC\c$\users\$userName")){
	Throw "User $userName doesn't have an account on $oPC."    
}else{
	$oldFolder = "\\$oPC\c$\users\$userName"
	Write-Verbose -Message "Profile for user, $userName, found on $oPC."
}

#user test on new.
if (-not (Test-Path -Path "\\$nPC\c$\users\$userName")){
	$prompt = Read-Host -Prompt "User $userName doesn't have an account. Create Backup folder?"
	if ($prompt -eq "y" -or $prompt -eq "yes"){
		New-Item -Path "\\$nPC\c$\Backup_$oPc_$userName" -ItemType Directory -Force
		Write-Host "C:\Backup__$oPC_$userName created."
		$newFolder = "\\$nPC\c$\Backup_$oPC_$userName"
	}
}else{
		$newFolder = "\\$nPC\c$\users\$userName"
		Write-Verbose -Message "Profile for user, $userName, found on $nPC."
}

if ($full){
	Write-Verbose -Message "Copying data."
}else{
	Write-Host "Choose data to copy."
}

#Desktop
if (Test-Path -Path "$oldFolder\Desktop"){
	$fs = ((Get-ChildItem -Path "$oldFolder\Desktop" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
	#Only if bigger than 2Kb = probably some default shortcuts.
	if ($fs -gt 0.003 -or $full){
		$fs = [math]::Round($fs, 2)
		if (-not $full) {
			$prompt = Read-Host -Prompt "Desktop contains $fs Mbs of data. Copy to '$nPC'?"
		}else{
			$prompt = "y"
		}
		if ($prompt -eq "y" -or $prompt -eq "yes"){
			Robocopy.exe "$oldFolder\Desktop" "$newFolder\Desktop" /E /njh /njs /ndl /nc /ns /np /nfl
			Write-Verbose -Message "Copying Desktop."
		}elseif($prompt -eq "n" -or $prompt -eq "no"){
			Write-Verbose -Message "Skipping Desktop."
		}else{
			Throw "Invalid input."
		}
	}else{
		Write-Verbose -Message "Desktop appears to be empty. Moving on."
	}
} else{
	Write-Verbose -Message "Desktop not found. Moving on."
}

#Pictures
if (Test-Path -Path "$oldFolder\Pictures"){
	$fs = ((Get-ChildItem -Path "$oldFolder\Pictures" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
	if ($fs -gt 0.003 -or $full){
		$fs = [math]::Round($fs, 2)
		if (-not $full) {
			$prompt = Read-Host -Prompt "Pictures contains $fs Mbs of data. Copy to '$nPC'?"
		}else{
			$prompt = "y"
		}
		if ($prompt -eq "y" -or $prompt -eq "yes"){
			Robocopy.exe "$oldFolder\Pictures" "$newFolder\Pictures" /E /njh /njs /ndl /nc /ns /np /nfl
			Write-Verbose -Message "Copying Pictures."
		}elseif($prompt -eq "n" -or $prompt -eq "no"){
			Write-Verbose -Message "Skipping Pictures."
		}else{
			Throw "Invalid input."
		}
	}else{
		Write-Verbose -Message "Pictures appears to be empty. Moving on."
	}
} else{
	Write-Verbose -Message "Pictures not found. Moving on."
}

#Videos
if (Test-Path -Path "$oldFolder\Videos"){
	$fs = ((Get-ChildItem -Path "$oldFolder\Videos" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
	if ($fs -gt 0.003 -or $full){
		$fs = [math]::Round($fs, 2)
		if (-not $full) {
			$prompt = Read-Host -Prompt "Videos contains $fs Mbs of data. Copy to '$nPC'?"
		}else{
			$prompt = "y"
		}
		if ($prompt -eq "y" -or $prompt -eq "yes"){
			Robocopy.exe "$oldFolder\Videos" "$newFolder\Videos" /E /njh /njs /ndl /nc /ns /np /nfl
			Write-Verbose -Message "Copying Videos."
		}elseif($prompt -eq "n" -or $prompt -eq "no"){
			Write-Verbose -Message "Skipping Videos."
		}else{
			Throw "Invalid input."
		}
	}else{
		Write-Verbose -Message "Videos appears to be empty. Moving on."
	}
} else{
	Write-Verbose -Message "Videos not found. Moving on."
}

#Favorites
#IE
if (Test-Path -Path "$oldFolder\Favorites"){
	$fs = ((Get-ChildItem -Path "$oldFolder\Favorites" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
	if ($fs -gt 0.001 -or $full){
		$fs = [math]::Round($fs, 2)
		if (-not $full) {
			$prompt = Read-Host -Prompt "Favorites contains $fs Mbs of data. Copy to '$nPC'?"
		}else{
			$prompt = "y"
		}
		if ($prompt -eq "y" -or $prompt -eq "yes"){
			Robocopy.exe "$oldFolder\Favorites" "$newFolder\Favorites" /E /njh /njs /ndl /nc /ns /np /nfl
			Write-Verbose -Message "Copying Favorites."
		}elseif($prompt -eq "n" -or $prompt -eq "no"){
			Write-Verbose -Message "Skipping Favorites."
		}else{
			Throw "Invalid input."
		}
	}else{
		Write-Verbose -Message "Favorites appears to be empty. Moving on."
	}
} else{
	Write-Verbose -Message "Favorites not found. Moving on."
}

#Chrome
if (Test-Path -Path "$oldFolder\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"){
	$fs = ((Get-Item -Path "$oldFolder\AppData\Local\Google\Chrome\User Data\Default\Bookmarks").Length / 1Kb)
	if ($fs -gt 4 -or $full){
		$fs = [math]::Round($fs, 2)
		if (-not $full) {
			$prompt = Read-Host -Prompt "Chrome bookmarks found. Copy to '$nPC'?"
		}else{
			$prompt = "y"
		}
		if ($prompt -eq "y" -or $prompt -eq "yes"){
			if (Test-Path -Path "$newFolder\AppData\Local\Google\Chrome\User Data\Default"){
				Robocopy.exe "$oldFolder\AppData\Local\Google\Chrome\User Data\Default" "$newFolder\AppData\Local\Google\Chrome\User Data\Default" "Bookmarks" /njh /njs /ndl /nc /ns /np /nfl
				Write-Verbose -Message "Copying Chrome bookmarks."
			}else{
				Robocopy.exe "$oldFolder\AppData\Local\Google\Chrome\User Data\Default" "$newFolder" "Bookmarks_Chrome" /njh /njs /ndl /nc /ns /np /nfl
				Write-Verbose -Message "Copying Chrome bookmarks."
				"Open Chrome and close it again." >>"$newFolder\README.txt"
				"Remove the '_Chrome'-part."  >>"$newFolder\README.txt"
				"Move Bookmarks to %localappdata%\Google\Chrome\User Data\Default\." >>"$newFolder\README.txt"
				" " >>"$newFolder\README.txt"
			}
		}elseif($prompt -eq "n" -or $prompt -eq "no"){
			Write-Verbose -Message "Skipping Chrome favorites."
		}else{
			Throw "Invalid input."
		}
	}else{
		Write-Verbose -Message "Chrome favorites appears to be empty. Moving on."
	}
} else{
	Write-Verbose -Message "Chrome favorites not found. Moving on."
}

#Edge
if (Test-Path -Path "$oldFolder\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"){
    $fs = ((Get-Item -Path "$oldFolder\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks").Length / 1Kb)
    if ($fs -gt 4 -or $full){
        $fs = [math]::Round($fs, 2)
        if (-not $full) {
            $prompt = Read-Host -Prompt "Edge bookmarks found. Copy to '$nPC'?"
        }else{
           $prompt = "y"
        }
        if ($prompt -eq "y" -or $prompt -eq "yes"){
            if (Test-Path -Path "$newFolder\AppData\Local\Microsoft\Edge\User Data\Default"){
                Robocopy.exe "$oldFolder\AppData\Local\Microsoft\Edge\User Data\Default" "$newFolder\AppData\Local\Microsoft\Edge\User Data\Default" "Bookmarks" /njh /njs /ndl /nc /ns /np /nfl
                Write-Verbose -Message "Copying Edge bookmarks."
            }else{
                Robocopy.exe "$oldFolder\AppData\Local\Microsoft\Edge\User Data\Default" "$newFolder" "Bookmarks_Edge" /njh /njs /ndl /nc /ns /np /nfl
                Write-Verbose -Message "Copying Favorites."
                "Open Edge and close it again." >>"$newFolder\README.txt"
                "Remove the '_Edge'-part."  >>"$newFolder\README.txt"
                "Move Bookmarks to %localappdata%\Microsoft\Edge\User Data\Default\." >>"$newFolder\README.txt"
                " " >>"$newFolder\README.txt"
            }
        }elseif($prompt -eq "n" -or $prompt -eq "no"){
            Write-Verbose -Message "Skipping Edge bookmarks."
        }else{
            Throw "Invalid input."
        }
    }else{
        Write-Verbose -Message "Edge bookmarks appears to be empty. Moving on."
    }
} else{
    Write-Verbose -Message "Edge bookmarks not found. Moving on."
}

#Skipping downloads and music because:
#1) Downloads is mostly junk and tends to contain duplicates.
#2) Music is rarelly used.

#Sticky notes
if (Test-Path -Path "$oldFolder\AppData\Roaming\Microsoft\Sticky Notes\StickyNotes.snt"){
    if (-not $full){
        $prompt = Read-Host -Prompt "Windows 7 sticky notes detected. Attempt to migrate? Note this doesn't always work."
    }else{
        $prompt = "y"
    }
    if ($prompt -eq "y" -or $prompt -eq "yes"){
        #Mixed reports online. Might be depricated after W10 1709. Some claim it still works. Keeping it in just in case.
        if (Test-Path -Path "$newFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\"){
            New-Item -Path "$newFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\Legacy"
            Robocopy.exe "$oldFolder\AppData\Roaming\Microsoft\Sticky Notes\" "$newFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\Legacy" "StickyNotes.snt" /njh /njs /ndl /nc /ns /np /nfl
            Rename-Item -Path "$newFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\Legacy\StickyNotes.snt" -NewName "ThresholdNotes.snt"
            Write-Host "Open the sticky notes app to check if the move worked."
        }else{
            Robocopy.exe "$oldFolder\AppData\Roaming\Microsoft\Sticky Notes\" "$newFolder" "StickyNotes.snt" /njh /njs /ndl /nc /ns /np /nfl
            Rename-Item -Path "$newFolder\StickyNotes.snt" -NewName "ThresholdNotes.snt"
            "Move ThresholdNotes.snt to %localappdata%\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\Legacy before opening the stickynotes app." >> "$newFolder\README.txt"
        }
    }elseif($prompt -eq "n" -or $prompt -eq "no"){
        Write-Host "Skipping sticky notes."
    }else{
        Throw "Invalid input."
    }
}elseif(Test-Path -Path "$oldFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite"){
    if (-not $full){
        $prompt = Read-Host -Prompt "Sticky notes detected. Copy to '$nPC'?"
    }else{
        $prompt = "y"
    }
    if ($prompt -eq "y" -or $prompt -eq "yes"){
        if (Test-Path -Path "$newFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\"){
            Robocopy.exe "$oldFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\" "$newFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\" "plum.sqlite" /njh /njs /ndl /nc /ns /np /nfl
            Write-Host "Sticky notes copied."
        }else{
            Robocopy.exe "$oldFolder\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\" "$newFolder" "plum.sqlite" /njh /njs /ndl /nc /ns /np /nfl
            "Move plum.sqlite to %localappdata%\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\ before opening the stickynotes app." >> "$newFolder\README.txt"
        }
    }elseif($prompt -eq "n" -or $prompt -eq "no"){
        Write-Verbose "Skipping sticky notes."
    }else{
        Throw "Invalid input."
    }
}else{
    Write-Verbose -Message "Stickynotes not found. Moving on."
}