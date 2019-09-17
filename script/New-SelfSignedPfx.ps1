$cert = New-SelfSignedCertificate -DnsName azuredemolabs.net -CertStoreLocation cert:\LocalMachine\My
$pwd = ConvertTo-SecureString -String "1234" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath C:\cert.pfx -Password $pwd