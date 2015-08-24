function Get-InstallUtil()
{
    # returnth path to InstallUtil.exe
    return Join-Path  $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) "InstallUtil.exe"
}




<#
.Synopsis
   Returns Name of .NET Service with specified Path
.DESCRIPTION
   Returns Name of .NET Service with specified Path
.EXAMPLE
   $service = Get-DotNetServiceName -PathName "D:\test\My Program.exe"
#>

function Get-DotNetServiceName
{
    
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Path to installing assembly file 
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path -Path $_})]
        [string]$Path
    )

    $Path = (Get-Item $Path).FullName
    
    $query = '"' + ($Path -replace '\\', '\\') + '"'
    #resolving name of a new service by pathname
    $service = get-wmiobject -query "select * from win32_service where PathName = '$query'"
    if ($service)
    {
        return $service.Name
    }
    else
    {
        
        Write-Verbose "No service with PathName $Path found"
        return $null
    }
 
}


<#
.Synopsis
   Installs .NET Service
.DESCRIPTION
   Installs .NET Service using InstallUtil.exe utility
.EXAMPLE
   Install-DotNetService -Path "D:\test\My Program.exe"
#>

function Install-DotNetService
{
    
    [CmdletBinding()]
    Param
    (
        # Path to installing assembly file 
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path
    )

    $Path = (Get-Item $Path).FullName
    Write-Verbose "Starting Install-DotNetService with parameter Path = $Path"
    

    # getting path to InstallUtil.exe 
    $cmd = Get-InstallUtil
    
    # checking if InstallUtil.exe exists
    if ( !(Test-Path -Path $cmd ) ) 
    { 
        Write-Error "$cmd was not found! Cannot proceed." 
        return
    }
    
    
    # checking if specified assembly file exists
    if ( !(Test-Path -Path $Path ) ) 
    { 
        Write-Error "$Path was not found! Please, specify path to existing assembly." 
        return
    }

    # checking if service already exist
    $service = Get-DotNetServiceName -Path $Path 
    if ( $service )
    {
    
        Write-Error "Service `"$service`" already exist! Remove it first." 
        return
    
    }
    
    #executing InstallUtil.exe
    $result = (& $cmd $Path)
    if ($LASTEXITCODE -ne 0)
    {
        #parsing text output for logfile name
        $logfile = ($result -match "logfile")[0]
        Write-Error "$LASTEXITCODE : Error happened. You can examine logfile: $logfile "
    }
    
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
    {
        #resolving name of a new service by pathname
        $service = Get-DotNetServiceName $Path
        Write-Verbose "Service with name $service successfully installed"
    }
}



<#
.Synopsis
   Uninstalls .NET Service
.DESCRIPTION
   Uninstalls .NET Service using specified Name (default behavior) OR Path
.EXAMPLE
   Install-DotNetService -Name "My Service"
.EXAMPLE
   Install-DotNetService -Path "D:\test\My Program.exe"
#>

function Uninstall-DotNetService
{
    
    [CmdletBinding()]
    [OutputType([string])]
    [CmdletBinding(DefaultParametersetName="WithName")]
    Param
    (
        # Path to installing assembly file 
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='WithPath')
        ]
        [string]$Path,

        # Name - optional name of installed service
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName='WithName')
        ]

        [string]$Name
    )

    
    # getting path to InstallUtil.exe 
    $cmd = Get-InstallUtil
    
    # checking if InstallUtil.exe exists
    if ( !(Test-Path -Path $cmd ) ) 
    { 
        Write-Error "$cmd was not found! Cannot proceed." 
        return
    }
    
   
    switch ($PsCmdlet.ParameterSetName)
    {
        "WithName"  
        { 
            Write-Verbose "Starting Uninstall-DotNetService with parameter Name = $Name"


            $service = get-wmiobject -query "select * from win32_service where Name = '$Name'"
            if ($service -eq $null)
            {
    
                Write-Error "Service with Name $Name not found!" 
                return
    
            }
            $Path = ($service | select PathName).PathName -replace "`"",""
            $ServiceName = $service.Name
            # checking if specified assembly file exists
            if ( !(Test-Path -Path $Path ) ) 
            { 
                Write-Error "Service $Name has Path $Path which was not found!" 
                return
            }
            
        }
        "WithPath"  
        { 
            $Path = (Get-Item $Path).FullName
            Write-Verbose "You specified service with Path $Path"
            # checking if specified assembly file exists
            if ( !(Test-Path -Path $Path ) ) 
            { 
                Write-Error "$Path was not found! Please, specify path to existing assembly." 
                return
            }

            # checking if service already exist
            $ServiceName = Get-DotNetServiceName -Path $Path 
            if ( $ServiceName -eq $null )
            {
    
                Write-Error "Service with Path $Path not found!" 
                return
    
            }
            
        }

    } 
    Stop-Service $ServiceName
    #executing InstallUtil.exe
    $result = (& $cmd "/u" $Path)
    if ($LASTEXITCODE -ne 0)
    {
        #parsing text output for logfile name
        $logfile = ($result -match "logfile")[0]
        Write-Error "$LASTEXITCODE : Error happened. You can examine logfile: $logfile "
    }
    
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
    {
        Write-Verbose "Service with name $ServiceName successfully removed"
    }

   
}


<#
.Synopsis
   function Start-DotNetService - starts .NET Service
.DESCRIPTION
   Starts .NET Service using it's assembly PathName.
   To start service using it's name you can choose Start-Service instead
.EXAMPLE
   Start-DotNetService -Path "D:\test\My Program.exe"
#>
function Start-DotNetService
{
    
    [CmdletBinding()]
    Param
    (
        # Path to installing assembly file 
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path
    )

    $Path = (Get-Item $Path).FullName
    Write-Verbose "Starting Start-DotNetService with parameter Path = $Path"

    # checking if service already exist
    $ServiceName = Get-DotNetServiceName -Path $Path 
    if ( $ServiceName -eq $null )
    {
    
        Write-Error "Service `"$service`" not found!" 
        return
    
    }

    Start-Service $ServiceName
    Write-Verbose "Status of $ServiceName is $((Get-Service $ServiceName).Status)"
}

<#
.Synopsis
   function Stop-DotNetService - starts .NET Service
.DESCRIPTION
   Stops .NET Service using it's assembly PathName.
   To stop service using it's name you can choose Stop-Service instead
.EXAMPLE
   Start-DotNetService -Path "D:\test\My Program.exe"
#>
function Stop-DotNetService
{
    
    [CmdletBinding()]
    Param
    (
        # Path to installing assembly file 
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path
    )

    $Path = (Get-Item $Path).FullName
    Write-Verbose "Starting Stop-DotNetService with parameter Path = $Path"

    # checking if service already exist
    $ServiceName = Get-DotNetServiceName -Path $Path 
    if ( $ServiceName -eq $null )
    {
    
        Write-Error "Service `"$service`" not found!" 
        return
    
    }

    Stop-Service $ServiceName
    Write-Verbose "Status of $ServiceName is $((Get-Service $ServiceName).Status)"
}

<#
.Synopsis
   function Restart-DotNetService - restarts .NET Service
.DESCRIPTION
   Restarts .NET Service using it's assembly PathName.
   To restart service using it's name you can choose Restart-Service instead
.EXAMPLE
   Start-DotNetService -Path "D:\test\My Program.exe"
#>
function Restart-DotNetService
{
    
    [CmdletBinding()]
    Param
    (
        # Path to installing assembly file 
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$Path
    )

    $Path = (Get-Item $Path).FullName
    Write-Verbose "Starting Restart-DotNetService with parameter Path = $Path"

    # checking if service already exist
    $ServiceName = Get-DotNetServiceName -Path $Path 
    if ( $ServiceName -eq $null )
    {
    
        Write-Error "Service `"$service`" not found!" 
        return
    
    }

    Stop-Service $ServiceName
    Start-Service $ServiceName
    Write-Verbose "Status of $ServiceName is $((Get-Service $ServiceName).Status)"
}

