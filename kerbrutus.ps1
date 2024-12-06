param (
    [Parameter(Mandatory=$true)]
    [int]$ExecutionCount, # Number of times to execute the command per iteration

    [Parameter(Mandatory=$true)]
    [int]$TimeWindowMinutes, # Time window in minutes

    [Parameter(Mandatory=$true)]
    [string]$CommandTemplate, # Command template with <pass> placeholder

    [Parameter(Mandatory=$true)]
    [string]$PasswordsFile # Path to passwords.txt
)

function ExecuteCommand {
    param (
        [string]$CommandToExecute
    )
    
    Write-Host "Executing command: $CommandToExecute"
    Invoke-Expression $CommandToExecute
}

# Read the passwords file
if (-not (Test-Path $PasswordsFile)) {
    Write-Error "Passwords file not found: $PasswordsFile"
    exit 1
}
$passwords = Get-Content $PasswordsFile | ForEach-Object { $_.Trim() }

# Ensure there are passwords to process
if ($passwords.Count -eq 0) {
    Write-Error "No passwords found in the specified file."
    exit 1
}

# Main loop
$passwordIndex = 0
while ($passwordIndex -lt $passwords.Count) {
    # Print start time
    $startTime = Get-Date
    Write-Host "Commencing at $startTime"

    # Execute the command `ExecutionCount` times
    for ($i = 1; $i -le $ExecutionCount; $i++) {
        # Check if we have remaining passwords
        if ($passwordIndex -ge $passwords.Count) {
            Write-Host "No more passwords left in the file."
            break
        }

        # Get the current password and increment the index
        $currentPassword = $passwords[$passwordIndex].Trim()

        # Ensure the current password is valid
        if ([string]::IsNullOrWhiteSpace($currentPassword)) {
            Write-Warning "Skipping empty or invalid password at index $passwordIndex"
            $passwordIndex++
            continue
        }

        $passwordIndex++

        # Escape `$` in the current password
        $escapedPassword = $currentPassword -replace '\`', '``'
        $escapedPassword = $escapedPassword -replace '\$', '`$'
        $escapedPassword = $escapedPassword -replace '\|', '`|'
        $escapedPassword = $escapedPassword -replace '\&', '`&'
        $escapedPassword = $escapedPassword -replace '\"', '`"'
        $escapedPassword = $escapedPassword -replace "\'", "`'"

        # Replace <pass> in the command template with the escaped password
        $command = $CommandTemplate.Replace('<pass>', $escapedPassword)

        # Debugging: Log the generated command
        # Write-Host "DEBUG: Generated command: '$command'" -ForegroundColor Green

        # Execute the command
        ExecuteCommand -CommandToExecute $command
    }

    # Print completion time
    $completionTime = Get-Date
    Write-Host "Completed at $completionTime"

    # Wait for the specified time window after the last command completes
    $waitTimeSeconds = ($TimeWindowMinutes + 1) * 60
    Start-Sleep -Seconds $waitTimeSeconds
}
