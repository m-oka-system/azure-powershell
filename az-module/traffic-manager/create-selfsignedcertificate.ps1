# https://qiita.com/Cotoletta/items/40638d0834470f40d187

# 保護するドメイン名を指定
$domain = "your domain name"

# 「個人」の証明書ストアに証明書を作成
$my = "cert:\CurrentUser\My"
$cert = New-SelfSignedCertificate -DnsName $domain -CertStoreLocation $my

# cer (自己証明書)をエクスポート
$cerfile  = "c:\$($domain).cer"
Export-Certificate -Cert $cert -FilePath $cerfile

# 「信頼されたルート証明機関」に cer を登録
$root = "cert:\CurrentUser\Root"
Import-Certificate -FilePath $cerfile -CertStoreLocation $root

# pfx (SSL証明書)をエクスポート
$pfxfile  = "c:\$($domain).pfx"
$password = "password"
$sspwd = ConvertTo-SecureString -String $password -Force -AsPlainText 
Export-PfxCertificate -Cert $cert -FilePath $pfxfile -Password $sspwd

# 「個人」の証明書を削除
Remove-Item -Path ($cert.PSPath)