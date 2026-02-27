param(
    [Switch]$dbg
)

####CxOne Variables######
#Please update with the values for your environment and respective region
#update the url based on your login page. ex: https://ast.checkmarx.net, https://us.ast.checkmarx.net
#add an API key as the $PAT value
$cx1Tenant=""
$PAT=""
$cx1URL="https://us.ast.checkmarx.net/api"
$cx1TokenURL="https://us.iam.checkmarx.net/auth/realms/$cx1Tenant"
$cx1IamURL="https://us.iam.checkmarx.net/auth/admin/realms/$cx1Tenant"
$csv_path="projects-applications.csv"

. "support/debug.ps1"

setupDebug($dbg.IsPresent)

Add-Type -AssemblyName System.Web

#Generate token for CxOne
$cx1Session = &"support/rest/cxone/apiTokenLogin.ps1" $cx1TokenURL $cx1URL "$cx1IamURL" $cx1Tenant $PAT


$validationLine = 0


Import-Csv $csv_path | ForEach-Object {
    $validationLine++
    $projectName = $_.NAME

    
    #build scan request
    $projectDetails = @{
        projectName = $projectName
        groups = ''
        repoUrl = ''
        mainBranch = ''
        origin = ''
        tags = ''
        criticality = 3
    }

    #Send the project create request
    try{
        &"support/rest/cxone/createproject.ps1" $cx1Session $projectDetails
        Write-Output "Created a project $projectName, line $validationLine"
    }
    catch{
        $message = [String]::Format("Failed to create project: {0}", $projectName)
        Write-Output $message
    }
}