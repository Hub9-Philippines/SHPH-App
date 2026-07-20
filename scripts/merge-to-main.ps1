# Merge current feature branch into main and push.
# Usage: .\scripts\merge-to-main.ps1

$featureBranch = git branch --show-current
$mainBranch = "main"

Write-Host "Current feature branch: $featureBranch" -ForegroundColor Cyan

if ($featureBranch -eq $mainBranch) {
    Write-Host "You are already on $mainBranch. Switch to your feature branch first." -ForegroundColor Red
    exit 1
}

# 1. Push the feature branch to remote
Write-Host "`n=== Pushing $featureBranch to origin ===" -ForegroundColor Cyan
git push origin $featureBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to push $featureBranch. Fix the error and try again." -ForegroundColor Red
    exit 1
}

# 2. Switch to main and update it
Write-Host "`n=== Switching to $mainBranch and pulling latest ===" -ForegroundColor Cyan
git checkout $mainBranch
git pull origin $mainBranch

# 3. Merge feature branch into main
Write-Host "`n=== Merging $featureBranch into $mainBranch ===" -ForegroundColor Cyan
git merge $featureBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Merge failed. Resolve conflicts manually, then run: git commit && git push origin $mainBranch" -ForegroundColor Red
    exit 1
}

# 4. Push main
Write-Host "`n=== Pushing $mainBranch to origin ===" -ForegroundColor Cyan
git push origin $mainBranch
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nMerged and pushed successfully!`nFeature branch '$featureBranch' is now in '$mainBranch'." -ForegroundColor Green
} else {
    Write-Host "Failed to push $mainBranch." -ForegroundColor Red
    exit 1
}

# 5. Optional: switch back to feature branch
$back = Read-Host "`nSwitch back to $featureBranch ? (y/n)"
if ($back -eq 'y') {
    git checkout $featureBranch
}
