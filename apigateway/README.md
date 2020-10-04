# API Gateway
## Custom Domain with mTLS
### Create Hello API
### Request Free Domain Certificate
### Setup Trust Store
#### Create Cert
```console
sudo openssl req -x509 -nodes -days 365 -subj '/C=IN/ST=Bangalore/L=ECity/O=Subrata POC Client/OU=POC/CN=subratapocclient' -newkey rsa:2048 -keyout apigateway-client.key -out apigateway-client.crt
```

#### Verify Cert
```console
openssl x509 -in apigateway-client.crt -text -noout
```

#### Upload Certificate to S3
```console
aws s3 cp apigateway-client.crt s3://dev-test-apigateway-ts --profile devtest
```
#### Update Custom Domain

Update MTLS trust store as `s3://dev-test-apigateway-ts/apigateway-client.crt`
### Create Custom Domain with mTLS
aws apigatewayv2 create-domain-name --region us-east-2 \
    --domain-name api.cloudhandson.com \
    --domain-name-configurations CertificateArn=arn:aws:acm:us-east-1:xxxxxxxxxxxx:certificate/290ecefd-2b04-4612-81c0-7865a0d739eb
    --mutual-tls-authentication truststoreUri=s3://dev-test-apigateway-ts/apigateway-client.crt
### Create R53 Hosted Zone
### Update Registrarer NS records
### Create R53 A Record Set
### Test Without Client Certificate (SSL error expected)

```console

subratas-mbp  ~/workspace/aws-learning/apigateway   master  curl -v https://api.cloudhandson.com/petstore/pets/2

*   Trying 50.17.164.221...
* TCP_NODELAY set
* Connected to api.cloudhandson.com (50.17.164.221) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Request CERT (13):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to api.cloudhandson.com:443
* Closing connection 0
curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to api.cloudhandson.com:443
 ✘ subratas-mbp  ~/workspace/aws-learning/apigateway   master 
 ```

### Test With Client Certificate
```console

 subratas-mbp  ~/workspace/aws-learning/apigateway   master  curl -v --key ./apigateway-client.key --cert ./apigateway-client.crt https://api.cloudhandson.com/petstore/pets/2

*   Trying 50.17.164.221...
* TCP_NODELAY set
* Connected to api.cloudhandson.com (50.17.164.221) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Request CERT (13):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Certificate (11):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS handshake, CERT verify (15):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=cloudhandson.com
*  start date: Oct  3 00:00:00 2020 GMT
*  expire date: Nov  2 12:00:00 2021 GMT
*  subjectAltName: host "api.cloudhandson.com" matched cert's "*.cloudhandson.com"
*  issuer: C=US; O=Amazon; OU=Server CA 1B; CN=Amazon
*  SSL certificate verify ok.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x7ff2e5003a00)
> GET /petstore/pets/2 HTTP/2
> Host: api.cloudhandson.com
> User-Agent: curl/7.64.1
> Accept: */*
>
* Connection state changed (MAX_CONCURRENT_STREAMS == 128)!
< HTTP/2 200
< x-amzn-requestid: 6400129c-6561-41eb-adc6-8484bc6c1b53
< access-control-allow-origin: *
< x-amz-apigw-id: T3GfFEEAIAMF9kg=
< x-amzn-trace-id: Root=1-5f791dfa-fa7b12234d4ccd62600ec883
< content-type: application/json
< content-length: 49
< date: Sun, 04 Oct 2020 00:57:30 GMT
<
{
  "id": 2,
  "type": "cat",
  "price": 124.99
* Connection #0 to host api.cloudhandson.com left intact
}* Closing connection 0
```

### Disable API
```console
subratas-mbp  ~/workspace/aws-learning/apigateway   master ●  curl -i  https://pjb8w9p0h0.execute-api.us-east-1.amazonaws.com/test/pets/2
HTTP/2 200
date: Sun, 04 Oct 2020 01:16:09 GMT
content-type: application/json
content-length: 49
x-amzn-requestid: a71736ee-ee70-4f57-acd2-c5df623346cc
access-control-allow-origin: *
x-amz-apigw-id: T3JN7Ev8oAMFW8w=
x-amzn-trace-id: Root=1-5f792259-26a9fd92560d294b591ffb38

{
  "id": 2,
  "type": "cat",
  "price": 124.99
}
```
aws apigatewayv2 get-apis --region us-east-1 --profile devtest
aws apigatewayv2 get-apis --region ap-south-1 --profile devtest
aws apigatewayv2 get-api-mappings --domain-name api.cloudhandson.com --region us-east-1 --profile devtest 

```console
(Needs higher version of V2 CLI 2.0.54+)
aws apigatewayv2 update-api \
    --api-id pjb8w9p0h0 \
    --disable-execute-api-endpoint \
    --region us-east-1 \
    --profile devtest
```