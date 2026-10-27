<#
.SYNOPSIS
    Compiles the HTML project report to PDF using headless Chrome/Edge.
.EXAMPLE
    .\generate_pdf.ps1 -StudentName "John Doe" -Batch "Oct-2026"
#>
param(
    [string]$StudentName = "Aayush",
    [string]$Batch = "Batch-2026"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$htmlPath = Join-Path $projectDir "reports\Student_Project_Report.html"
$outputPdf = Join-Path $projectDir "reports\${StudentName}_EWB_VPC_Peering.pdf"
$rootPdf = Join-Path $projectDir "${StudentName}_EWB_VPC_Peering.pdf"

Write-Host "Updating HTML template with Student: $StudentName, Batch: $Batch..." -ForegroundColor Cyan
$content = Get-Content -Path $htmlPath -Raw
$content = $content -replace '\[Your Name Here\]', $StudentName
$content = $content -replace '\[Your Batch / Cohort\]', $Batch
Set-Content -Path $htmlPath -Value $content

$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}

if (Test-Path $chromePath) {
    Write-Host "Generating PDF using Google Chrome..." -ForegroundColor Green
    $tempPdf = "$env:TEMP\temp_report.pdf"
    Start-Process -FilePath $chromePath -ArgumentList "--headless=new", "--no-sandbox", "--disable-gpu", "--print-to-pdf=$tempPdf", "$htmlPath" -Wait -NoNewWindow
    if (Test-Path $tempPdf) {
        Copy-Item $tempPdf $outputPdf -Force
        Copy-Item $tempPdf $rootPdf -Force
        Remove-Item $tempPdf -Force
        Write-Host "PDF created successfully at:`n- $outputPdf`n- $rootPdf" -ForegroundColor Green
    }
} else {
    Write-Host "[WARNING] Google Chrome not found. You can open $htmlPath in your browser and press Ctrl+P -> Save as PDF." -ForegroundColor Yellow
}
