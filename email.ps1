$EmailFrom = "your@gmail.com"
$EmailTo = "your@gmail.com"
$Subject = "PC Info"
$Body = Get-Content "$env:TEMP\\sysinfo.txt" | Out-String
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
$Password = "your_16_char_app_password"

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PSCredential($EmailFrom, $SecurePassword)

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $Creds
