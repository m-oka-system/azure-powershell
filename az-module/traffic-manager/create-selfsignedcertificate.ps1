# https://qiita.com/Cotoletta/items/40638d0834470f40d187

$dns = "www.m-okasystem.com"

# 「個人」に証明書を作成
$my = "cert:\CurrentUser\My"
$cert = New-SelfSignedCertificate -DnsName $dns -CertStoreLocation $my

# cer を確保
$root = "cert:\CurrentUser\Root"
$cerfile  = "c:\$($dns).cer"
Export-Certificate -Cert $cert -FilePath $cerfile

# [信頼されたルート証明機関]に cer を登録
Import-Certificate -FilePath $cerfile -CertStoreLocation $root

# pfx を確保
$pfxfile  = "c:\$($dns).pfx"
$password = "password"
$sspwd = ConvertTo-SecureString -String $password -Force -AsPlainText 
Export-PfxCertificate -Cert $cert -FilePath $pfxfile -Password $sspwd

# 「個人」の証明書を削除
Remove-Item -Path ($cert.PSPath)