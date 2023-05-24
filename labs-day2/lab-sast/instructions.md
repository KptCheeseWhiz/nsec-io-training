## Lab objective
In this lab we will enable Static Code Analysis for our Bicep templates to look for insecure configurations or other errors. We will first try to scan locally, then enable a workflow using PSRules and GitHub Actions to automatically scan when new code it is pushed to the repository.


### Note: For this lab, you need to have a copy of the repository in your GitHub account.

### steps to import
1. Click the + in the upper right corner
2. import the repo https://github.com/karimelmel/nsec-io-training/tree/main
3. enable actions in Settings on the repository, then follow instructions below.

## Instructions
1. Install the PSRule and PSRule.Rules.Azure modules
2. Once the modules are installed, try to run it using Assert-PSRule command and specify the Azure.Default baseline. Make sure you have ps-rules.yaml configuration file specifying that it should expand Bicep. For more information: https://azure.github.io/PSRule.Rules.Azure/setup/configuring-options/ 
3. Have a look at the workflow file here: https://gist.github.com/karimelmel/3590ee60784bcb8bdd35f76343a98564 
4. Once the workflow is added, try to trigger it by pushing a code change to the repository. This can be any change.
5. Inspect the output of the action, what are some ways you could implement PSRule to enforce governance?

