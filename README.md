# sonarqube-pull-request-decoration

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
