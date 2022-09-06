function Deg2Rad {
    Param ($deg)
    $deg * ([math]::pi/180)
}

function Rad2Deg {
    Param ($rad)

    $rad  / ([math]::pi/180)
}

function CalculateDistance {
    Param ([double] $latFrom, [double] $latTo, [double] $longFrom, [double] $longTo)

    $theta = $longFrom - $longTo;

    $latFromRad = Deg2Rad($latFrom)
    $latToRad = Deg2Rad($latTo)
    $longFromRad = Deg2Rad($longFrom)
    $longToRad = Deg2Rad($longTo)

    $dist = [math]::sin($latFromRad) * [math]::sin($latToRad) + [math]::cos($latFromRad) * [math]::cos($latToRad) * [math]::cos($theta)
    $dist = [math]::acos($dist);
    $dist = Rad2Deg($dist);
    return ($dist * 60 * 1.1515 * 1.609344)
}

function d1 {
    Param ([double] $num)

    return $num/10000000
}

Set-Location $PSScriptRoot\..

$dataJson = Get-Content -Path .\temp\Records.json -Raw | ConvertFrom-Json

$startDate = Get-Date -Year 2018 -Month 09 -Day 22
$endDate = Get-Date

$dayDistArray = @()

while ($endDate -ge $startDate) {
    Write-Host $startDate.ToString("yyyy-MM-dd")

    $locationData = $dataJson.locations `
        | select -first 200
        #| where timestamp -ge $startDate.ToString("yyyy-MM-dd") `
        #| where timestamp -le $startDate.AddDays(1).ToString("yyyy-MM-dd") `
    Write-Host "locationData = $locationData"
    $locationLoop = 0
    $dayDist = 0
    while($locationLoop -lt ($locationData.Length - 1)) {
        $from = $dayData[$locationLoop]
        If ($from.source -eq 'WIFI') {
            Continue
        }
        Write-Output "Calculating distance from $from"
        $to = $dayData[$locationLoop + 1]
        Write-Output "Calculating distance to $to"

        $dist = CalculateDistance (d1 $from.latitudeE7) (d1 $to.latitudeE7) (d1 $from.longitudeE7) (d1 $to.longitudeE7)
        $dayDist += $dist
        $dayDistArray += @{Date=$startDate;Distance=$dist}
        $dayLoop++
    }
    $startDate = $startDate.AddDays(1)
    break
}
