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
    #Throw "User $userName doesn't have an account on $oPC."    
}
#user test on new.
if (-not (Test-Path -Path "\\$nPc\c$\users\$userName")){
    $cb = Read-Host -Prompt "User $userName doesn't have an account. Create Backup folder?"
    if ($cb -eq "y" -or $cb -eq "yes"){
        New-Item -Path "\\$nPC\c$\Backup_$userName" -ItemType Directory -Force
        Write-Host "C:\\Backup_$userName created."
    }
}