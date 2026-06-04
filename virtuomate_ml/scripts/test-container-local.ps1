# Build and smoke-test the Cloud Run image locally (requires Docker Desktop)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Copy-Item -Path (Join-Path $Root "Dockerfile.cloud") -Destination (Join-Path $Root "Dockerfile") -Force

docker build -t virtuomate-intelligence:test .
docker run --rm -p 8080:8080 -e PORT=8080 virtuomate-intelligence:test

# In another terminal: curl http://localhost:8080/health
