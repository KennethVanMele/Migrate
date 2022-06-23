$oPC = Read-Host -Prompt "Old PC name"
#Connection test old.
if (-not (Test-Connection -ComputerName $oPC -Count 1 -Quiet)){
    Throw "$oPC not found!"
}

$nPC = Read-Host -Prompt "New PC name"
#Connection test new.
if (-not (Test-Connection -ComputerName $nPC -Count 1 -Quiet)){
    Throw "$nPC not found!"
}

#Convert to SAMName: https://9to5it.com/powershell-find-ad-user-full-name/
$userName = Read-Host -Prompt "User to migrate"
#user test on old.
if (-not (Test-Path -Path "\\$oPc\c$\users\$userName")){
    Throw "User $userName doesn't have an account on $oPC."    
}else{
    $oldFolder = "\\$oPc\c$\users\$userName"
}

#user test on new.
if (-not (Test-Path -Path "\\$nPc\c$\users\$userName")){
    $prompt = Read-Host -Prompt "User $userName doesn't have an account. Create Backup folder?"
    if ($prompt -eq "y" -or $prompt -eq "yes"){
        New-Item -Path "\\$nPC\c$\Backup_$oPc_$userName" -ItemType Directory -Force
        Write-Host "C:\Backup__$oPc_$userName created."
        $newFolder = "\\$nPC\c$\Backup_$oPc_$userName"
    }else{
        $newFolder = "\\$nPc\c$\users\$userName"
    }
}

#Desktop
if (Test-Path -Path "$oldFolder\Desktop"){
    $fs = ((Get-ChildItem -Path "$oldFolder\Desktop" -Recurse | Measure-Object -Property Length -Sum).Sum / 1Mb)
    if ($fs -gt 0.001){
        $fs = [math]::Round($fs, 2)
        $prompt = Read-Host -Prompt "Desktop contains $fs Mbs of data. Migrate?"
        if ($prompt -eq "y" -or $prompt -eq "yes"){
            Robocopy.exe "$oldFolder\Desktop" "$newFolder\Desktop" /E
        }
    }
}