# Chocolatey ps1
$chocoUrl = 'https://community.chocolatey.org/install.ps1'

# Collections of types of apps
$collections = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JMBargueno/utils/main/scripts/installApps/apps.json" | ConvertFrom-Json

# Installed packages with chocolatey
$packages = @()

# Execute a remote ps1 script.
function install($url){
    $tempScriptPath = "$env:TEMP\tempScript.ps1"
    (New-Object System.Net.WebClient).DownloadString($url) | Set-Content -Path $tempScriptPath
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression "$tempScriptPath"
}

# Verify if a package is installed.
function verifyInstallation ($app) {
    foreach ($package in $packages) {
        if ("$package".StartsWith($app + "")) {
            return $true
        }
    }
    return $false
}

# If a package is not installed, install it.
function installApp($app){
    if (-not (verifyInstallation $app)) {
    Write-Host "Installing $app..."
    Start-Process -FilePath "choco" -ArgumentList "install $app -y" -Wait
    Write-Host "$app installed." -ForegroundColor Green
    } else {
    Write-Host "$app is already installed." -ForegroundColor Yellow
    }
}

# Main function of app. Loop over $collections, if you want install the collection, loop over the apps provided.
function main(){
    $collections.psobject.Properties | ForEach-Object {
        $category = $_.Name
        $applications = $_.Value
        $res = Read-Host "Do you want install $category apps? (y/n)"
        if ($res -eq "y") {
            Write-Host "Installing $category apps."
            $applications | ForEach-Object {
                installApp $_
            }
        }
        elseif ($res -eq "n") {
            Write-Host "Skipping $category apps."
        }
        else {
            Write-Host "Invalid answer. You must enter 'y' or 'n'."
        }
       
        Write-Host ""
    }
}
# Check if chocolatey is installed. If not, install it.
if (Get-Command -Name choco -ErrorAction SilentlyContinue) {
    Write-Host "The 'choco' command exists in the system. Skipping installation."
} else {
    Write-Host "The 'choco' command does not exist on the system. We will install Chocolatey."
    # Run the Chocolatey installation command
    install $chocoUrl
}

# Wait until Chocolatey is available to use.
while (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Start-Sleep -Milliseconds 100
}

# Load in $packages all apps installed.
$packages = choco list -lo

# Execute the main function.
main

# Pause so you can see the results before the window closes
Read-Host -Prompt "Installation done. Press Enter to exit."