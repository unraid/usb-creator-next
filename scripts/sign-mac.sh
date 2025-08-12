#! /bin/bash
cd USB_CREATOR_DIR
codesign --deep --force --verify --verbose --sign "$APPLE_SIGNING_KEY_ID" --options runtime unraid-usb-creator.app
mv unraid-usb-creator.app "Unraid USB Creator.app"
create-dmg \
--icon "Unraid USB Creator.app" 100 100 \
--app-drop-link 300 100 \
--window-pos 200 120 \
--window-size 600 400 \
"Unraid USB Creator.dmg" "Unraid USB Creator.app"

xcrun notarytool submit "Unraid USB Creator.dmg"  --apple-id "$APPLE_EMAIL_ADDRESS" --password "$APPLE_APP_PASSWORD" --team-id "$APPLE_TEAM_ID" --wait
xcrun stapler staple "Unraid USB Creator.dmg"