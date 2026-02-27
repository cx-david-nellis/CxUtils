param(
    [Switch]$dbg
)

####CxOne Variable######
$cx1Tenant=""
$PAT=""
$cx1URL="https://us.ast.checkmarx.net/api"
$cx1TokenURL="https://us.iam.checkmarx.net/auth/realms/$cx1Tenant"
$cx1IamURL="https://us.iam.checkmarx.net/auth/admin/realms/$cx1Tenant"
$groupName = ""
$applicationName = ""
$cx1appId = ""
. "support/debug.ps1"

setupDebug($dbg.IsPresent)

Add-Type -AssemblyName System.Web

#Generate token for CxOne
$cx1Session = &"support/rest/cxone/apiTokenLogin.ps1" $cx1TokenURL $cx1URL "$cx1IamURL" $cx1Tenant $PAT

#Create Cx1 Application
$cx1ApplicationsResponse = &"support/rest/cxone/getapplications.ps1" $cx1Session
$cx1Applications = $cx1ApplicationsResponse.applications
$applicationDetails = @{
        name = $applicationName
    }

    try{
    $cx1ApplicationsResponse = &"support/rest/cxone/createapplication.ps1" $cx1Session $applicationDetails
    $cx1Applications = $cx1ApplicationsResponse
    
    $cx1appId = $cx1Applications.id
    
    #Waiting 3 seconds to give time for the application to be created and ready
    Start-Sleep -Seconds 3
    #Get list of CxOne groups
    $cx1Groups = &"support/rest/cxone/getgroups.ps1" $cx1Session
    $targetGroup = $cx1Groups | Where-Object {$_.name -eq $groupName}

    $assignmentDetails = @{
    entityID = $targetGroup.id
    entityType = "group"
    resourceID = $cx1appId
    resourceType = "application"
}

if ($targetGroup) {
    $cx1AuthorizeGroup = &"support/rest/cxone/createAssignment.ps1" $cx1Session $assignmentDetails
    Write-Output $cx1AuthorizeGroup, "Group added."
} else {
    Write-Output "Group did not exist, please check the group name."
}
    }
    catch{
        $message = [String]::Format("Failed to create app: $cx1ApplicationsResponse")
        Write-Output $message
    }




