# core-network-ios

## Setup

Create `CoreNetwork.plist` file and add the keys below:

| Key       | Type | Value
| ----------- | ----------- | ----------- |
| `LOG_LEVEL` | String | `NONE`, `BASIC`, `HEADERS` or `BODY`.
| `BASE_URL`  | String | any
| `TIMEOUT_INTERVAL_FOR_REQUEST` | Number | any
| `TIMEOUT_INTERVAL_FOR_RESOURCE` | Number | any

## Create public key hash

Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

```(shell)
openssl s_client -servername api.spotify.com -connect api.spotify.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```

https://developer.apple.com/news/?id=g9ejcf8y
