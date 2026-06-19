# Regenerate typed Dart client from SHPH API.yaml using OpenAPI Generator.
#
# Prerequisites:
#   - Java 11+
#   - openapi-generator-cli (https://openapi-generator.tech/docs/installation)
#
# Usage (PowerShell):
#   .\tool\generate_api_client.ps1
#
# Note: The current app uses a hand-written Dio client in lib/api/ because many
# endpoints in SHPH API.yaml lack response schemas. Run this script when the spec
# is enriched and you want fully generated models/clients.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$spec = Join-Path $root "SHPH API.yaml"
$output = Join-Path $root "lib\api\generated"

if (-not (Test-Path $spec)) {
  throw "OpenAPI spec not found: $spec"
}

if (Get-Command openapi-generator-cli -ErrorAction SilentlyContinue) {
  $generator = "openapi-generator-cli"
} elseif (Get-Command openapi-generator -ErrorAction SilentlyContinue) {
  $generator = "openapi-generator"
} else {
  throw "Install openapi-generator-cli first: https://openapi-generator.tech/docs/installation"
}

if (Test-Path $output) {
  Remove-Item $output -Recurse -Force
}

& $generator generate `
  -i "$spec" `
  -g dart-dio `
  -o "$output" `
  --additional-properties=pubName=shph_api_client,pubAuthor=SerbisyoHub,useEnumExtension=true,nullableFields=true

Write-Host "Generated client at $output"
