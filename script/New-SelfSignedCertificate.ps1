# https://qiita.com/Cotoletta/items/40638d0834470f40d187

$dns = "domain name"

# 「個人」に証明書を作成
$my = "cert:\CurrentUser\My"
$cert = New-SelfSignedCertificate -DnsName $dns -CertStoreLocation $my

# pfx を確保
$pfxfile  = "c:\domainname.pfx"
$password = "password"
$sspwd = ConvertTo-SecureString -String $password -Force -AsPlainText 
Export-PfxCertificate -Cert $cert -FilePath $pfxfile -Password $sspwd