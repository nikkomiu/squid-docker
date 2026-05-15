param(
    [Parameter(Position=0)]
    [string]$Target = "help"
)

function Invoke-Help {
    Write-Host "Usage: .\make.ps1 <target>" -ForegroundColor White
    Write-Host ""
    Write-Host "Targets:"
    $targets = @(
        @{ Name = "run";      Desc = "Start squid in the foreground (interactive)" },
        @{ Name = "start";    Desc = "Start squid in the background (detached)" },
        @{ Name = "stop";     Desc = "Stop the running squid container" },
        @{ Name = "restart";  Desc = "Stop then start the squid container" },
        @{ Name = "exec";     Desc = "Open a bash shell inside the running container" },
        @{ Name = "version";  Desc = "Print the squid version" },
        @{ Name = "gen-cert"; Desc = "Generate the TLS bump certificate (auto-run by start/run)" },
        @{ Name = "build";    Desc = "Build the Docker image locally" },
        @{ Name = "clean";    Desc = "Remove the generated certs directory" },
        @{ Name = "help";     Desc = "Show this help message" }
    )
    foreach ($t in $targets) {
        Write-Host ("  {0,-12} {1}" -f $t.Name, $t.Desc)
    }
}

$Image = "ghcr.io/nikkomiu/squid-docker:main"
$ContainerName = "squid"
$Root = $PSScriptRoot -replace '\\', '/'

function Invoke-GenCert {
    if (-not (Test-Path "$PSScriptRoot\certs\bump.crt")) {
        New-Item -ItemType Directory -Force -Path "$PSScriptRoot\certs" | Out-Null
        docker run --rm -v "${Root}/certs:/etc/squid/certs" $Image gen-cert
    }
}

function Invoke-Run {
    Invoke-GenCert
    docker run -it --rm -p 3128:3128 -p 3129:3129 --name $ContainerName `
        -v "${Root}/config/squid.conf:/etc/squid/squid.conf" `
        -v "${Root}/config/allowlist.txt:/etc/squid/allowlist.txt" `
        -v "${Root}/certs:/etc/squid/certs" `
        $Image
}

function Invoke-Start {
    Invoke-GenCert
    docker run -d --rm -p 3128:3128 -p 3129:3129 --name $ContainerName `
        -v "${Root}/config/squid.conf:/etc/squid/squid.conf" `
        -v "${Root}/config/allowlist.txt:/etc/squid/allowlist.txt" `
        -v "${Root}/certs:/etc/squid/certs" `
        $Image
}

function Invoke-Stop {
    docker stop $ContainerName 2>$null
    $global:LASTEXITCODE = 0
}

function Invoke-Restart {
    Invoke-Stop
    Invoke-Start
}

function Invoke-Exec {
    docker exec -it $ContainerName bash
}

function Invoke-Version {
    docker exec -it $ContainerName /entrypoint.sh version 2>$null
    if ($LASTEXITCODE -ne 0) {
        docker run -it --rm $Image version
    }
}

function Invoke-Build {
    docker build -t $Image .
}

function Invoke-Clean {
    Remove-Item -Recurse -Force "$PSScriptRoot\certs" -ErrorAction SilentlyContinue
}

switch ($Target) {
    "run"      { Invoke-Run }
    "start"    { Invoke-Start }
    "stop"     { Invoke-Stop }
    "restart"  { Invoke-Restart }
    "exec"     { Invoke-Exec }
    "version"  { Invoke-Version }
    "gen-cert" { Invoke-GenCert }
    "build"    { Invoke-Build }
    "clean"    { Invoke-Clean }
    "help"     { Invoke-Help }
    default    { Write-Error "Unknown target: '$Target'. Valid targets: run, start, stop, restart, exec, version, gen-cert, build, clean" }
}
