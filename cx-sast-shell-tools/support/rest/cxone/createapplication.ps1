param(
    [Parameter(Mandatory=$true)]
    [hashtable]$session,
    [Parameter(Mandatory=$true)]
    [hashtable]$groupInput
)

. "support/rest_util.ps1"

$request_url = New-Object System.Uri $session.base_url, "/api/applications/"

Write-Debug "Applications API URL: $request_url"

$headers = GetRestHeadersForJsonRequest($session)
$body = $groupInput | ConvertTo-Json -Depth 10


$response = Invoke-RestMethod -Method 'Post' -Uri $request_url -Headers $headers -ContentType 'application/json' -Body $body
return $response