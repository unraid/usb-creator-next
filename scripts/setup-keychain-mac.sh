#!/bin/bash
# create variables
CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db# import certificate and provisioning profile from secrets
echo -n "$APPLE_BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH

security create-keychain -p "$APPLE_KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p "$APPLE_KEYCHAIN_PASSWORD" $KEYCHAIN_PATH# import certificate to keychain
security import $CERTIFICATE_PATH -P "$APPLE_BUILD_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
security set-key-partition-list -S apple-tool:,apple: -k "$APPLE_KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
security list-keychain -d user -s $KEYCHAIN_PATH# apply provisioning profile