param(
  [string]$Month = (Get-Date -Format "yyyy-MM")
)

$zoneCodes = @(
  "JHR01","JHR02","JHR03","JHR04","KDH01","KDH02","KDH03","KDH04","KDH05","KDH06","KDH07",
  "KTN01","KTN03","MLK01","NGS01","NGS02","PHG01","PHG02","PHG03","PHG04","PHG05","PHG06",
  "PLS01","PNG01","PRK01","PRK02","PRK03","PRK04","PRK05","PRK06","PRK07","SBH01","SBH02",
  "SBH03","SBH04","SBH05","SBH06","SBH07","SBH08","SBH09","SGR01","SGR02","SGR03","SWK01",
  "SWK02","SWK03","SWK04","SWK05","SWK06","SWK07","SWK08","SWK09","TRG01","TRG02","TRG03",
  "TRG04","WLY01","WLY02"
)

$rootDir = Split-Path $PSScriptRoot -Parent
$dataDir = Join-Path $rootDir "data"
$outputDir = Join-Path $dataDir "fallback"
$null = New-Item -ItemType Directory -Path $dataDir -Force
$null = New-Item -ItemType Directory -Path $outputDir -Force

$result = @{
  generatedAt = (Get-Date).ToString("s")
  month = $Month
  zones = @{}
}

foreach ($zone in $zoneCodes) {
  $url = "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=$zone&period=month"
  Write-Host "Fetching $zone"
  $response = Invoke-RestMethod $url
  $result.zones[$zone] = @{
    zone = $response.zone
    prayerTime = $response.prayerTime
  }
}

$outputPath = Join-Path $outputDir "$Month.json"
$result | ConvertTo-Json -Depth 8 | Set-Content -Path $outputPath -Encoding UTF8
Write-Host "Saved fallback data to $outputPath"
