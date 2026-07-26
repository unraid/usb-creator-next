/*
 * SPDX-License-Identifier: Apache-2.0
 * Copyright (C) 2026 Lime Technology, Inc.
 *
 * UNRAID: which wizard steps this brand takes part in.
 *
 * Upstream's wizard already skips steps by data — nextStep() consults
 * secureBootAvailable, piConnectAvailable and ccRpiAvailable/ifAndFeaturesAvailable
 * before advancing. We reuse that machinery rather than deleting steps.
 *
 * Deleting the Raspberry Pi-only steps would mean re-resolving a large structural
 * diff in WizardContainer.qml on every upstream bump — precisely the failure mode
 * this migration exists to remove. Steps we do not use stay in the tree, are never
 * entered, and keep merging cleanly. See PORTING.md.
 */

pragma Singleton

import QtQuick

QtObject {
    // Raspberry Pi hardware features Unraid has no equivalent for. These gate
    // steps off; they are not deletions.
    readonly property bool secureBootAvailable: false
    readonly property bool piConnectAvailable: false
    readonly property bool interfacesAndFeaturesAvailable: false
    readonly property bool remoteAccessAvailable: false

    // Unraid sets its own locale/keyboard from the webGUI after first boot.
    readonly property bool localisationAvailable: false

    // Unraid does support Wi-Fi (etc/rc.d/rc.wireless), configured from
    // config/wireless.cfg on the flash, so the step is offered.
    readonly property bool wifiAvailable: true

    // Steps we repurpose. The upstream step is reused as-is structurally; only
    // its labels and the settings keys it writes are Unraid-specific.
    //
    //   Hostname -> Unraid server name          -> config/ident.cfg   NAME=
    //   User     -> addressing (DHCP/static)    -> config/network.cfg USE_DHCP/IPADDR/...
    //
    // Unraid has no username to choose (the account is always root) and the root
    // password is set from the webGUI on first boot, not written to the flash — so
    // upstream's User step is reused for network addressing rather than credentials.
    readonly property bool serverNameAvailable: true
    readonly property bool networkConfigAvailable: true

    // App Options rows that only make sense for Raspberry Pi. The telemetry pill
    // is rendered by QML regardless of the ENABLE_TELEMETRY build option (that
    // only gates the C++ reporting), so without this it would show a toggle that
    // does nothing on an Unraid build.
    readonly property bool connectForOrganisationsAvailable: false
    readonly property bool telemetryAvailable: false

    // Unraid images are always written to USB flash; other media cannot hold a
    // licence GUID, so the storage step filters to USB only.
    readonly property bool usbOnlyStorage: true

    // Labels for the steps we do use.
    readonly property string serverNameLabel: qsTr("Server name")
    readonly property string networkConfigLabel: qsTr("Network")
    readonly property string wifiLabel: qsTr("Wi\u2011Fi")
}
