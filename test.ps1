cd (Split-Path -parent $MyInvocation.MyCommand.Definition)

$csc = Join-Path  $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) "csc.exe"

& $csc *.cs

Copy-Item -Force .\DotNetService $env:USERPROFILE\Documents\WindowsPowerShell\Modules\ -Recurse
Import-Module DotNetService

Get-DotNetServiceName '.\Program.exe' -Verbose
Install-DotNetService -Path "./Program.exe" -Verbose
Start-DotNetService -Path "./Program.exe" -Verbose
Stop-DotNetService -Path "./Program.exe" -Verbose
UnInstall-DotNetService -Name "MyService" -Verbose
Remove-Module DotNetService