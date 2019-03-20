Param(
    [string]$source = $(throw "source is a required parameter"),
    [string]$target = $(throw "target is a required parameter")
)

$originalDirectory = Get-Location
$workingDirectory = "workspace"

try {
    # Delete working directory if exists
    if(Test-Path $workingDirectory) {
        Remove-Item -LiteralPath $workingDirectory -Force -Recurse
    }

    # Create working directory
    New-Item -ItemType Directory -Path $workingDirectory

    # Move to working directory
    Set-Location $workingDirectory

    # Clone git repository
    git clone $source .

    # Get remotes and checkout all
    $remoteBranches = git branch -r

    foreach($remoteBranch in $remoteBranches) {
        Write-Host git checkout --track $remoteBranch
    }

    # Add new temp origin
    git remote add temp-origin $target

    # Push all branches to new remote
    git push --all temp-origin

    # Push all tags
    git push --tags temp-origin

    # Remove existing origin
    git remote rm origin

    # Rename temp-origin to origin -- Redundant step
    git remote rename temp-origin origin
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    # Restore original location
    Set-Location $originalDirectory
}
