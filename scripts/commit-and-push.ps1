# Commit and push helper — review, stage, commit, push to current branch
# Usage: .\scripts\commit-and-push.ps1 -Message "your commit message"

param(
    [Parameter(Mandatory = $true)]
    [string]$Message
)

$branch = git branch --show-current

Write-Host "=== Current branch: $branch ===" -ForegroundColor Cyan
Write-Host "=== Changes to be committed ===" -ForegroundColor Cyan
git status --short

$confirm = Read-Host "`nProceed with 'git add -A' and commit? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

git add -A
git commit -m $Message

$pushConfirm = Read-Host "`nPush to origin/$branch ? (y/n)"
if ($pushConfirm -eq 'y') {
    git push origin $branch
    Write-Host "Pushed to origin/$branch" -ForegroundColor Green
} else {
    Write-Host "Committed locally only. Run 'git push origin $branch' when ready." -ForegroundColor Yellow
}
