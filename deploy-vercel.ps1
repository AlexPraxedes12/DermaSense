param(
  [switch]$Production,
  [string]$ProjectName = "derma-sense-demo"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $projectRoot

try {
  if ($ProjectName -cnotmatch '^[a-z0-9][a-z0-9._-]{0,99}$' -or $ProjectName.Contains('---')) {
    throw "Nombre de proyecto invalido: usa minusculas, numeros, punto, guion o guion bajo."
  }

  if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter no esta disponible en PATH."
  }

  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "npx no esta disponible. Instala Node.js antes de desplegar."
  }

  Write-Host "[1/3] Resolviendo dependencias Flutter..." -ForegroundColor Cyan
  flutter pub get
  if ($LASTEXITCODE -ne 0) { throw "flutter pub get fallo." }

  Write-Host "[2/3] Compilando demo web sin cache PWA persistente..." -ForegroundColor Cyan
  flutter build web --release --pwa-strategy=none
  if ($LASTEXITCODE -ne 0) { throw "flutter build web fallo." }

  if (-not (Test-Path "build/web/index.html")) {
    throw "No se genero build/web/index.html."
  }

  cmd /c "npx --yes vercel@latest project inspect $ProjectName --yes >nul 2>&1"
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Creando proyecto Vercel '$ProjectName' por primera vez..." -ForegroundColor Cyan
    & npx --yes vercel@latest project add $ProjectName
    if ($LASTEXITCODE -ne 0) { throw "No se pudo crear el proyecto de Vercel." }
  }

  $vercelArgs = @(
    "vercel@latest",
    "deploy",
    "build/web",
    "--yes",
    "--project",
    $ProjectName
  )
  if ($Production) {
    $vercelArgs += "--prod"
    Write-Host "[3/3] Desplegando a produccion en Vercel..." -ForegroundColor Cyan
  } else {
    Write-Host "[3/3] Creando despliegue Preview en Vercel..." -ForegroundColor Cyan
  }

  & npx --yes @vercelArgs
  if ($LASTEXITCODE -ne 0) { throw "El despliegue de Vercel fallo." }
} finally {
  Pop-Location
}
