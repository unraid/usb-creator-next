#! /bin/bash
cd USB_CREATOR_DIR
codesign --deep --force --verify --verbose --sign "$APPLE_SIGNING_KEY_ID" --options runtime unraid-usb-creator.app
mv unraid-usb-creator.app "Unraid USB Creator.app"
create-dmg "Unraid USB Creator.dmg" "Unraid USB Creator.app" 
mv Unraid\ USB\ Creator.dmg imager.dmg
xcrun notarytool submit "Unraid USB Creator.dmg"  --apple-id "$APPLE_EMAIL_ADDRESS" --password "$APPLE_APP_PASSWORD" --team-id "$APPLE_TEAM_ID" --wait
xcrun stapler staple "Unraid USB Creator.dmg"