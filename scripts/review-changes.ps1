# Review changes before committing
# Usage: .\scripts\review-changes.ps1

Write-Host "=== Modified/New Files ===" -ForegroundColor Cyan
git status --short

Write-Host "`n=== Unstaged Diff Summary ===" -ForegroundColor Cyan
git diff --stat

Write-Host "`n=== Staged Diff Summary (if any) ===" -ForegroundColor Cyan
git diff --staged --stat

Write-Host "`nRun 'git diff' for full unstaged diff, or 'git diff --staged' for staged diff." -ForegroundColor Yellow
Write-Host "Run 'git add -p' to interactively stage changes hunk-by-hunk." -ForegroundColor Yellow
