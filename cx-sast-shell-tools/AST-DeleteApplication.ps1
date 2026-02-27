param(
    [string]$csv_path,
    [Switch]$dbg
)

####CxOne Variable######
$cx1Tenant=""
$PAT=""
$cx1URL="https://us.ast.checkmarx.net/api"
$cx1TokenURL="https://us.iam.checkmarx.net/auth/realms/$cx1Tenant"
$cx1IamURL="https://us.iam.checkmarx.net/auth/admin/realms/$cx1Tenant"
$csv_path="converted_applications.csv"

. "support/debug.ps1"

setupDebug($dbg.IsPresent)


#Generate token for CxOne
$cx1Session = &"support/rest/cxone/apiTokenLogin.ps1" $cx1TokenURL $cx1URL "$cx1IamURL" $cx1Tenant $PAT

#Get list of CxOne applications
$cx1ApplicationResponse = &"support/rest/cxone/getapplications.ps1" $cx1Session
$cx1Applications = $cx1ApplicationsResponse.applications



$validationLine = 0
Import-Csv $csv_path | ForEach-Object {
    $validationLine++
    $applicationId = $_.id
    

    try{
        &"support/rest/cxone/deleteapplication.ps1" $cx1Session $applicationId
        Write-Output "Found an Application Match $applicationId, line $validationLine"
    }
    catch{
        $message = [String]::Format("Failed to delete application: {0}", $applicationId)
        Write-Output $message
    }

    
}