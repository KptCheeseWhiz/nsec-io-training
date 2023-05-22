## Lab objective
In this lab we will set up logging of Azure Activity on the subscription level with forwarding to a Log Analytics Workspace.

We will then query the workspace to 

## Instructions
3. Log in to your Azure subscription.
4. Open Log Analytics Workspaces -> Select your subscription -> Resource Group (create new)
5. Name the Resource Group nsec-training-day1 -> Give it the name nsec-law-1 -> Select the region US East -> 'Review + Create' -> Click 'Create' once the validation has passed.
6. Go to the Subscription -> Activity Log -> Export Activity Logs
7. Add Diagnostic Settings -> Provide a Diagnostic Setting Name -> Select:
    * Administrative
    * Security
    * Alert
    * Policy
8. Provide the name 'nsec-diag-manual' and create the Diagnostic logging.
9. Explore the Bicep templates in the Bicep folder, inspect the different resources to try understand how they work.
10. Delete the manually configured resources and try to deploy the Bicep templates. Keep this for later. 
11. Explore the Log Analytics Workspace and try to query data

---
