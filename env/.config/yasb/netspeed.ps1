$data = & speedtest --format=json | ConvertFrom-Json
$speed = [math]::Round($data.download.bandwidth * 8 / 1000000, 0)
$ping = [math]::Round($data.ping.latency, 0)
$result = [PSCustomObject]@{
    speed = "$speed Mbps"
    ping = "$ping ms"
}
$result | ConvertTo-Json