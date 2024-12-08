param (
    [Parameter(Mandatory=$true)]
    [int]$ExecutionCount, # Number of times to execute the command per iteration

    [Parameter(Mandatory=$true)]
    [int]$TimeWindowMinutes, # Time window in minutes

    [Parameter(Mandatory=$true)]
    [string]$CommandTemplate, # Command template with <pass> placeholder

    [Parameter(Mandatory=$true)]
    [string]$PasswordsFile, # Path to passwords.txt

    [Parameter(Mandatory=$true)]
    [string]$OutputFile # Path to the output log file
)

function ExecuteCommand {
    param (
        [string]$CommandToExecute,
        [string]$LogFile
    )
    # Split the command and arguments for proper execution
    $commandParts = $CommandToExecute -split ' '
    $command = $commandParts[0]
    $arguments = $commandParts[1..($commandParts.Length - 1)]

    # Print the command being executed
    Write-Host "Executing command: $CommandToExecute" -ForegroundColor Cyan

    # Capture command output with line breaks preserved
    $result = & $command $arguments | Out-String

    # Print the command output to the console
    Write-Host $result -ForegroundColor Gray

    # Append the command and its output to the log file with line breaks preserved
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @"
============================================================
Timestamp: $timestamp
Command: $CommandToExecute

Output:
$result
============================================================
"@
    Add-Content -Path $LogFile -Value $logEntry
}

# Validate the passwords file
if (-not (Test-Path $PasswordsFile)) {
    Write-Error "Passwords file not found: $PasswordsFile"
    exit 1
}

# Validate or create the output file
if (-not (Test-Path $OutputFile)) {
    New-Item -Path $OutputFile -ItemType File -Force | Out-Null
}

# Load passwords from the file
$passwords = Get-Content $PasswordsFile | ForEach-Object { $_.Trim() }

if ($passwords.Count -eq 0) {
    Write-Error "No passwords found in the specified file."
    exit 1
}

# Main processing loop
$passwordIndex = 0
while ($passwordIndex -lt $passwords.Count) {
    $startTime = Get-Date
    Write-Host "Commencing at $startTime"

    for ($i = 1; $i -le $ExecutionCount; $i++) {
        # Exit if we've processed all passwords
        if ($passwordIndex -ge $passwords.Count) {
            Write-Host "No more passwords left to process."
            break
        }

        # Get the current password
        $currentPassword = $passwords[$passwordIndex]
        $passwordIndex++

        # Replace <pass> in the command template
        $command = $CommandTemplate.Replace('<pass>', $currentPassword)

        # Debugging output
        # Write-Host "DEBUG: Current Password: $currentPassword" -ForegroundColor Yellow
        # Write-Host "DEBUG: Generated Command: $command" -ForegroundColor Green

        # Execute the command and append to the output file
        ExecuteCommand -CommandToExecute $command -LogFile $OutputFile
    }

    $completionTime = Get-Date
    Write-Host "Completed at $completionTime"

    # Wait before the next iteration
    Start-Sleep -Seconds (($TimeWindowMinutes + 1) * 60)
}
