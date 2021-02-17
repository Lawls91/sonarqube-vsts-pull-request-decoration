# This is required due to a bug with SonarQube PR decoration. As we scan multiple projects, the last one to be scanned wins out and wipes
# all results from the previous project. Just add a summary comment manually to ensure people go check SonarQube
# https://jira.sonarsource.com/browse/MMF-2001
# also https://jira.sonarsource.com/browse/SONAR-11870
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $SonarKey,
    [Parameter(Mandatory=$true)]
    [string]
    $SonarName
)

$sonarUri = "{https://{YOUR_SONARQUBE_URL}/api/project_pull_requests/list?project}=$SonarKey"
$sonarResponse = Invoke-RestMethod -Method Get -ContentType application/json -Uri $sonarUri
$sonarScan = @($sonarResponse.pullRequests | Where-Object { $_.key -eq $env:SYSTEM_PULLREQUEST_PULLREQUESTID })
$sonarScan
if ($sonarScan.Count -eq 1) {
    if ($sonarScan[0].status.qualityGateStatus -ne 'OK') {
        $vstsUri = "https://dev.azure.com/{YOUR_VSTS_ORG_NAME}/$env:SYSTEM_TEAMPROJECT/_apis/git/repositories/$env:BUILD_REPOSITORY_ID/pullRequests/$env:SYSTEM_PULLREQUEST_PULLREQUESTID/threads?api-version=6.0-preview.1"
        
        $message = @"
### Failed SonarQube Quality Gate - $SonarName

![Bug](https://{YOUR_SONARQUBE_URL}/static/developer-server/common/bug.svg) Bugs: $($sonarScan[0].status.bugs)
![Vulnerability](https://{YOUR_SONARQUBE_URL}/static/developer-server/common/vulnerability.svg) Vulnerabilities: $($sonarScan[0].status.vulnerabilities)
![Code Smell](https://{YOUR_SONARQUBE_URL}/static/developer-server/common/code_smell.svg) Code Smells: $($sonarScan[0].status.codeSmells)

[See it in SonarQube](https://{YOUR_SONARQUBE_URL}/dashboard?id=$SonarKey&pullRequest=$env:SYSTEM_PULLREQUEST_PULLREQUESTID)
"@

        $body = @{
            "comments" = @(
                @{
                    "parentCommentId" = 0
                    "content" = "$message"
                    "commentType" = 1
                }
            )
            status = 1
        } | ConvertTo-Json

        $body

        $header = @{Authorization="Bearer $env:SYSTEM_ACCESSTOKEN"}
        Invoke-RestMethod -Method Post -UseDefaultCredentials -ContentType application/json -Uri $vstsUri -Body $body -Headers $header
    }
} else {
    Write-Error "Unable to find pull request"
    exit 1
}
