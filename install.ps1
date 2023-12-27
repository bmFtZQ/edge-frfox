# Get-ExecutionPolcy = "Restricted" by default

# VARIABLES, CHANGE AS NEEDED
$GITHUB_REPO="https://github.com/bmFtZQ/edge-frfox.git"
$PROJECT_NAME=$($GITHUB_REPO.Split("/")[-1] -replace ".git", "")
$FIREFOX_DIR="$env:APPDATA\Mozilla\Firefox";
$PROFILE_ROOTDIR="$($FIREFOX_DIR)\Profiles\$((Select-String -Path "$($FIREFOX_DIR)\profiles.ini" -Pattern "Path=.*\.(dev-edition-default|default-.*)" | Select-Object -Last 1).Line.Substring(14))";
$OPTIONALS=@{
  "widget.macos.native-context-menus" = "false"
  "browser.theme.dark-private-windows" = "false"
};

# UTILITY FUNCTIONS
function set_pref {
  param (
    $Pref,
    $Bool
  )

  Write-Output "setting $pref to $bool in user.js";
	Write-Output "user_pref(`"$pref`", $bool);" | % { $_ -replace ' +$','' } | out-file "$PROFILE_ROOTDIR\user.js" -append -Encoding UTF8
}

function delete_pref {
  param (
    $Pref
  )

  $Userjs="$PROFILE_ROOTDIR\user.js";

  Write-Output "resetting $Pref to default";
  (Get-Content "$PROFILE_ROOTDIR\user.js")  | 
  Where-Object {$_ -ne $Pref}               | 
  Set-Content -Path $Userjs;
}

#####################
# PRE-INSTALL PHASE #
#####################

$firefox_proc=Get-Process firefox -ErrorAction SilentlyContinue;
if ($firefox_proc) {
  Write-Host "ERROR: Before installing, please make sure firefox is not running.`nOtherwise, changes cannot be made to user.js" -ForegroundColor Red;
  exit 0;
}

# Prompting for correct install directory
Write-Output "
Please enter the path to your firefox profile directory.
This can be found by opening about:support in firefox and looking for the Profile root directory.
Press CTRL+C to abort installation now."
Write-Host "Automatically detected: $PROFILE_ROOTDIR" -ForegroundColor Cyan;
Write-Output "Press ENTER to use this directory, or type in a new one.";
$ans=Read-Host "Path";
$PROFILE_ROOTDIR=($PROFILE_ROOTDIR,$ans)[[bool]$ans];

if (!(Test-Path "$PROFILE_ROOTDIR")) {
	Write-Host "ERROR: firefox profile directory could not be found..." -ForegroundColor Red;

	do {
		$PROFILE_ROOTDIR=Read-Host -Prompt "Enter active root directory found in about:support here";
		if (!(Test-Path "$PROFILE_ROOTDIR")) {
			Write-Host "invalid directory: specified location does not exist. Try again..." -ForegroundColor Red;
		}
	} while (!(Test-Path "$PROFILE_ROOTDIR"));
}

# Check if issued `...\installer.sh uninstall`
if ($args[0] -eq "uninstall") {
  Write-Host "NOTE: This is the final opportunity to abort uninstallation by pressing Ctrl+C" -ForegroundColor Yellow;
  Remove-Item "$PROFILE_ROOTDIR\chrome" -Recurse -Confirm:$true;

  # Download changed user.js from online
  $fail=$false
  Invoke-Webrequest -Uri "https://raw.githubusercontent.com/bmFtZQ/edge-frfox/main/user.js" -UseBasicParsing -OutFile "$env:temp\user.js"
  if (!($?)) {
    Write-Host "WARNING: Failed to retrieve online user.js prefs. Continuing..." -ForegroundColor Yellow
    $fail=$true
  }

  Write-Output "uninstalling...";
  if (!$fail) {
    $FETCHED_PREFS= @()
    $FETCHED_PREFS += Select-String -Path "$env:temp\user.js" -Pattern "user_pref\(`"([a-zA-Z0-9.-]+)`",\s*(true|false)\);" | ForEach-Object {$_.Line -replace ".*\\", ""}
    foreach ($pref in $FETCHED_PREFS) {
      delete_pref "$pref";
    }
  } 

  $ans = "n"
  Write-Host "NOTE: etner 'a' to answer 'yes' to all questions." -ForegroundColor Cyan
  foreach ($key in $OPTIONALS.Keys) {
    $setting = "user_pref(`"${key}`", $($OPTIONALS[$key]));"

    if (-not ($ans.ToLower() -match "^(all|a)$")) {
        $ans = "n"
        $in = Read-Host -Prompt "Remove setting $setting from user.js? [y/a/N]"
        $ans = if ($in) { $in.ToLower() } else { $ans }

        if (-not ($ans -match "^(yes|y|all|a)$")) {
            continue
        }
    }

    delete_pref $setting;
  }

  Write-Output "uninstall complete.";
  exit 0;
}

#################
# INSTALL PHASE #
#################

Write-Output "Installing...";
Write-Output "Downloading source code...";

$response = Invoke-WebRequest -Uri "https://github.com/bmFtZQ/edge-frfox/archive/refs/heads/main.zip" -OutFile "$env:temp\edge-frfox.zip"
if (!($?)) {
  Write-Host "ERROR: Failed to download source code from https://github.com/bmFtZQ/edge-frfox/archive/refs/heads/main.zip." -ForegroundColor Red;
  Write-Host "$($response.StatusCode)"
  exit 0;
}

Expand-Archive -Path "$env:temp\$PROJECT_NAME.zip" -DestinationPath "$env:temp" -Force
if (!($?)) {
  Write-Host "ERROR: Failed to extract $env:temp\$PROJECT_NAME.zip." -ForegroundColor Red;
  Write-Host "Message: $($Error[0].Exception.Message)";
  exit 0;
}

echo "Copying theme folder..."
Copy-Item -Recurse -Path "$env:temp\$PROJECT_NAME-main\chrome" -Destination $PROFILE_ROOTDIR
Get-Content "$env:temp\$PROJECT_NAME-main\user.js" | Out-File "$PROFILE_ROOTDIR\user.js" -append -Encoding UTF8 | Out-Null

# firefox will automatically sort out any duplicate issues, whatever is at the end of the file takes priority, so this works.
Write-Output "Setting preferences...";
foreach ($key in $OPTIONALS.Keys) {
  $ans = "n"
  $in = Read-Host -Prompt "Set $key to $($optionals[$key]) [y/N]"
  $ans = if ($in) { $in } else { $ans }

  if (!($ans.ToLower() -match "^(yes|y)$")) {
    continue
  }

  set_pref "$key" "$($optionals[$key])";
}

Write-Host "Installation complete! Please start firefox to see the changes.`n" -ForegroundColor Green;
