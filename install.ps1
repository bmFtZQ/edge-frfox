# Get-ExecutionPolcy = "Restricted" by default

# VARIABLES, CHANGE AS NEEDED
$GITHUB_REPO="https://github.com/bmFtZQ/edge-frfox.git"
$PROJECT_NAME=$($GITHUB_REPO.Split("/")[-1] -replace ".git", "")
$FIREFOX_DIR="$env:APPDATA\Mozilla\Firefox";
$PROFILE_ROOTDIR="$($FIREFOX_DIR)\Profiles\$((Select-String -Path "$($FIREFOX_DIR)\installs.ini" -Pattern "Default=" | Select-Object -Last 1).Line.Substring(17))";
$CHANGED_PREFS=@("toolkit.legacyUserProfileCustomizations.stylesheets", "svg.context-properties.content.enabled", "layout.css.color-mix.enabled");

# UTILITY FUNCTIONS
function set_pref {
  param (
    $Pref,
    $Bool
  )

  Write-Output "setting $pref to $bool in prefs.js";
	"user_pref(`"$pref`", $bool);" | out-file "$PROFILE_ROOTDIR/prefs.js" -Encoding ASCII -append
}

function delete_pref {
  param (
    $Pref
  )

  $Prefsjs="$PROFILE_ROOTDIR\prefs.js";

  Write-Output "resetting $Pref to default";
  (Get-Content -Path $Prefsjs) |
    ForEach-Object {$_ -Replace "user_pref\(\`"$Pref\`", (true|false)\);", ''} |
      Set-Content -Path $Prefsjs;
}

#####################
# PRE-INSTALL PHASE #
#####################

$firefox_proc=Get-Process firefox -ErrorAction SilentlyContinue;
if ($firefox_proc) {
  Write-Output "ERROR: Before installing, please make sure firefox is not running.`nOtherwise, changes cannot be made to prefs.js";
  exit 0;
}

# Prompting for correct install directory
Write-Output "
Please enter the path to your firefox profile directory.
This can be found by opening about:support in firefox and looking for the Profile root directory.
Press CTRL+C to abort installation now.
Automatically detected: $PROFILE_ROOTDIR
Press ENTER to use this directory, or type in a new one.";
$ans=Read-Host "Path";
$PROFILE_ROOTDIR=($PROFILE_ROOTDIR,$ans)[[bool]$ans];

# Check if issued `...\installer.sh uninstall`
if ($args[0] -eq "uninstall") {
  Remove-Item "$PROFILE_ROOTDIR/chrome" -Recurse -Confirm:$true;
   
  Write-Output "uninstalling...";
  foreach ($pref in $CHANGED_PREFS) {
    delete_pref $pref;
  }

  Write-Output "uninstall complete.";
  exit 0;
}

Write-Output "Checking if git is installed...";
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Output "ERROR: git not found... Please install git and try again.";
  exit 0;
}

Write-Output "Detecting if firefox is installed on your system..."
if (!(Test-Path $FIREFOX_DIR)) {
  Write-Output "ERROR: firefox not found...";
  
  Write-Output "Do you want to continue anyway?";
  $continue=Read-Host -Prompt "y/n";

	if (!("$continue".ToLower() -match "^(y|yes)$")) {
		Write-Output "Aborting installation...";
		exit 0;
	}
}

if (!(Test-Path "$PROFILE_ROOTDIR")) {
	Write-Host "ERROR: firefox profile directory could not be found..." -ForegroundColor Red;

	do {
		$PROFILE_ROOTDIR=Read-Host -Prompt "Enter active root directory found in about:support here";
		if (!(Test-Path "$PROFILE_ROOTDIR")) {
			Write-Host "invalid directory: specified location does not exist. Try again..." -ForegroundColor Red;
		}
	} while (!(Test-Path "$PROFILE_ROOTDIR"));
}

#################
# INSTALL PHASE #
#################

Write-Host "Installing..." -ForegroundColor Green;
if (!(Test-Path "$("$env:temp\$PROJECT_NAME")")) {
	Write-Output "Cloning $GITHUB_REPO into $env:temp\$PROJECT_NAME...";

	git clone $GITHUB_REPO "$env:temp\$PROJECT_NAME";
}

Write-Output "Copying files to $PROFILE_ROOTDIR\chrome...";
Remove-Item "$PROFILE_ROOTDIR\chrome" -Recurse -ErrorAction SilentlyContinue -Confirm:$false -Force;
Copy-Item "$env:temp\$PROJECT_NAME\chrome" -Destination $PROFILE_ROOTDIR -Recurse -Force;

# firefox will automatically sort out any duplicate issues, whatever is at the end of the file takes priority, so this works.
Write-Output "Setting preferences...";
foreach ($pref in $CHANGED_PREFS) {
	set_pref $pref "true";
}

Write-Host "Installation complete! Please start firefox to see the changes.`n`n" -ForegroundColor Green;
