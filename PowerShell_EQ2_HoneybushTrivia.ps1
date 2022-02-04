clear-host
$LogFileServerLocation = "C:\Users\Public\Daybreak Game Company\Installed Games\EverQuest II\logs"
$TempDir = "C:\Temp"
$ToonListFile = "$TempDir\ToonList.csv"
$ServerListFile = "$TempDir\ServerList.csv"
$ServerListHeader = "Selection,ServerName"
$ToonListHeader = "Selection,ToonName,LogFilePath"
If((Test-Path -Path $TempDir) -eq $false){New-Item -Path $TempDir -ItemType Directory}
Add-Content -Path $ServerListFile -Value $ServerListHeader
Add-Content -Path $ToonListFile -Value $ToonListHeader
$Serverlist = Get-ChildItem -Path $LogFileServerLocation -Directory
$ServerListCount = 0
ForEach ($Server in $ServerList)
    {
    $ServerListCount = $ServerListCount + 1
    $Content = "$ServerListCount" + "," + $Server.Name
    Add-Content -Path $ServerListFile -Value $Content
    }
Write-Host "--------------------------------------------------------"
Write-Host "-                CHOOSE YOUR SERVER                    -"
Write-Host "--------------------------------------------------------"
$ServerListSelection = Import-CSV -Path $ServerListFile
ForEach($Line in $ServerListSelection)
    {   
    $Entry = $Line.Selection + " - " + $Line.ServerName
    Write-Host "        "$Entry
    }
Write-Host "--------------------------------------------------------"
Write-Host ""
$Selection = Read-Host -Prompt "Enter the number of your server choice [Example: 1]"
$SelectedServer = Import-CSV -Path $ServerListFile | Where-Object Selection -eq $Selection | Select-Object ServerName
$SelectedServer = $SelectedServer.ServerName
Write-Host "You selected "$SelectedServer
$CharacterList = Get-ChildItem -Path "$LogFileServerLocation\$SelectedServer" | Where-Object Name -notlike "*.*.txt"
$ToonListCount = 0
ForEach($Toon in $CharacterList)
    {
    If($Toon.Name -like "*Conflict*"){Write-Host "Found Conflict"}
    Else
        {
        $ToonListCount = $ToonListCount + 1
        $FullPath = $Toon.FullName
        $ToonContent = "$ToonListCount" + "," + $Toon.Name + "," + $FullPath
        Add-Content -Path $ToonListFile -Value $ToonContent
        }   
    }
Clear-Host
Write-Host "               SERVER - $SelectedServer                 "
Write-Host "--------------------------------------------------------"
Write-Host "-                CHOOSE YOUR TOON                      -"
Write-Host "--------------------------------------------------------"
$ToonListSelection = Import-CSV -Path $ToonListFile
ForEach($Line in $ToonListSelection)
    {
    $Toonname = $Line.ToonName -replace "eq2log_" -replace ".txt"
    $Entry = $Line.Selection + " - " + $Toonname
    Write-Host "        "$Entry
    }
Write-Host "--------------------------------------------------------"
Write-Host ""
$Selection = Read-Host -Prompt "Enter the number of your toon choice [Example: 1]"
$SelectedToon = Import-CSV -Path $ToonListFile | Where-Object Selection -eq $Selection | Select-Object ToonName,LogFilePath
$SelectedToonName = $SelectedToon.ToonName
$ToonFilePath = $SelectedToon.LogFilePath
Clear-Host
Write-Host "Listening to - "$SelectedToonName -ForegroundColor Green
Write-Host ""
Write-Host "To EXIT, press [Ctrl+C]" -ForegroundColor Green
Remove-Item -Path $ServerListFile,$ToonListFile



Get-Content -Path $ToonFilePath -Wait -Tail 5 |
    Where-Object { $_ -like '*\aPC -1 Honeybush:Honeybush\/a tells General (*),*' } |
        ForEach-Object {
        $Message = $_.split(",",2)[1] -replace '"'
        $pattern = '(?<=\[).+?(?=\])'
        $MessageTime = [regex]::Matches($_, $pattern).Value
        If($MessageTime -eq $PreviousMessageTime)
            {
            Write-Host "$Message" -ForegroundColor Yellow
            $LineCount = $LineCount + 1
            $PreviousMessage = $PreviousMessage + $Message
            }
        Else {
            Write-Host "----"
            Write-Host $Message -ForegroundColor green
            $LineCount = 1
            $Searched = "no"
            $PreviousMessage = $Message
            $PreviousMessageTime = $MessageTime
            }
        If($LineCount -ge 3 -and $Searched -eq "no")
            {
            $Searched = "yes"            
            $PreviousMessage = $PreviousMessage -replace " ","+" -replace "'"
            $URL = "https://www.google.com/search?q=song+lyrics" + $PreviousMessage
            Write-Host "Invoking Google Search for [$URL]" -ForegroundColor red
            [system.Diagnostics.Process]::Start("chrome","$URL")
            }
        }
        


