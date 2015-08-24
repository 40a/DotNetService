cd (Split-Path -parent $MyInvocation.MyCommand.Definition)

Copy-Item -Force .\DotNetService $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ -Recurse
Import-Module DotNetService

Get-DotNetServiceName '.\My Program.exe' -Verbose
Install-DotNetService -Path "./My Program.exe" -Verbose
Start-DotNetService -Path "./My Program.exe" -Verbose
Stop-DotNetService -Path "./My Program.exe" -Verbose
UnInstall-DotNetService -Name "MyService" -Verbose
Remove-Module DotNetService