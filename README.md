# sonarqube-vsts-pull-request-decoration [WIP]

To use this, use something similar to the following in your VSTS YAML pipeline

```
- task: PowerShell@2
  displayName: 'Add comments to PR to display results from sonarqube'
  inputs:
    filePath: './build/scripts/sonarqube-pr-decoration.ps1'
    arguments: '-SonarKey "$(sonarKey)" -SonarName "$(sonarName)"'
  env:
    SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

Also replace "{YOUR_VSTS_ORG_NAME}" & "{YOUR_SONARQUBE_URL}" with their appropriate values

Todo:
* Remove the previous comment when the PR build is reran
