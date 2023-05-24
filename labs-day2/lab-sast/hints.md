##  Hints
1.  To install the modules: ` Install-Module -Name 'PSRule' -Repository PSGallery -Scope CurrentUser -Force ; Install-Module -Name 'PSRule.Rules.Azure' -Scope CurrentUser -Force ` 
2. To test the Rules locally on your Bicep templates ` Assert-PSRule -Module 'PSRule.Rules.Azure' -InputPath "./" -Baseline "Azure.Default" -Outcome Fail, Pass `
3.  Add a file "ps-rule.yaml" at the root directory containing the following configuration: 
```# YAML: Enable expansion for Bicep source files.
configuration:
    AZURE_BICEP_FILE_EXPANSION: true
```
