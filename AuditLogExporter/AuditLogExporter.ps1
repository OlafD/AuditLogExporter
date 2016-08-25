param (
    [string]$Url,
    [string]$Output
)

$start = Get-Date

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") | Out-Null

$site = New-Object Microsoft.SharePoint.SPSite($Url)
$web = $site.OpenWeb()

Write-Host $web.Title

$audit = $web.Audit
$auditEntries = $audit.GetEntries()
$auditEntriesCount = $auditEntries.Count

Write-Host "Found $auditEntriesCount entries in the audit log"
Write-Host ""

$xmlDoc = [System.Xml.XmlWriter]::Create($Output)

if ($xmlDoc -eq $null)
{
    Write-Host -ForegroundColor Red "Uups! Cannot create the output file $Output"
}
else
{
    $xmlDoc.WriteStartDocument()

    $xmlDoc.WriteStartElement("Audit")
    $xmlDoc.WriteAttributeString("Url", $Url)

    $xmlDoc.WriteStartElement("AuditData")

    for ($i = 0; $i -lt $auditEntriesCount; $i++)
    {
        $progress = $i * 100 / $auditEntriesCount
        $progress = [int]$progress

        Write-Host -NoNewline "`rProgress: $progress%"

        $auditEntry = $auditEntries[$i]

        $xmlDoc.WriteRaw($auditEntry.ToString())
    }

    Write-Host  "`rProgress: 100%"

    #$xmlDoc.WriteRaw($auditEntries.ToString())

    $xmlDoc.WriteEndElement()  # AuditData

    $xmlDoc.WriteEndElement()  # Audit

    $xmlDoc.WriteEndDocument()
    $xmlDoc.Flush()
    $xmlDoc.Close()

    $web.Dispose()
    $site.Dispose()

    $end = Get-Date

    $duration = $end - $start

    Write-Host "Duration: $duration"
    Write-Host "Audit log written to $Output"
}

Write-Host -ForegroundColor Green "Done."
