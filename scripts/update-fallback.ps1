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

function Invoke-JakimRequest {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $true)]
    [string]$Zone
  )

  $attempts = 4

  for ($attempt = 1; $attempt -le $attempts; $attempt++) {
    try {
      Write-Host "Fetching $Zone (attempt $attempt/$attempts)"
      return Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 45 -Headers @{
        "Accept" = "application/json"
        "User-Agent" = "WaktuSolatCacheBot/1.0 (GitHub Actions)"
      }
    } catch {
      if ($attempt -eq $attempts) {
        throw
      }

      $delay = 5 * $attempt
      Write-Warning "Request failed for $Zone. Retrying in $delay seconds. $($_.Exception.Message)"
      Start-Sleep -Seconds $delay
    }
  }
}

foreach ($zone in $zoneCodes) {
  $url = "https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=$zone&period=month"
  try {
    $response = Invoke-JakimRequest -Url $url -Zone $zone
    $result.zones[$zone] = @{
      zone = $response.zone
      prayerTime = $response.prayerTime
    }
  } catch {
    Write-Warning "Skipping $zone after repeated failures. $($_.Exception.Message)"
  }
}

if ($result.zones.Count -eq 0) {
  throw "Unable to refresh any JAKIM zones for $Month."
}

$outputPath = Join-Path $outputDir "$Month.json"
$result | ConvertTo-Json -Depth 8 | Set-Content -Path $outputPath -Encoding UTF8
Write-Host "Saved fallback data to $outputPath with $($result.zones.Count) zones."
